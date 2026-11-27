import UIKit
import GoogleMobileAds
import PrebidMobile
import VeonPrebidMobileGAMEventHandlers
import VeonPrebidMultiAdLoader

// MARK: - AdParameters

struct AdParameters {
    var configId: String?
    var adUnitId: String?
    var adType: String?
    var bannerWidth: Int
    var bannerHeight: Int
    var refreshInterval: Double

    init(configId: String? = nil,
         adUnitId: String? = nil,
         adType: String? = nil,
         bannerWidth: Int = 0,
         bannerHeight: Int = 0,
         refreshInterval: Double = 30.0) {
        self.configId = configId
        self.adUnitId = adUnitId
        self.adType = adType
        self.bannerWidth = bannerWidth
        self.bannerHeight = bannerHeight
        self.refreshInterval = refreshInterval
    }
}

/// Connects Prebid's rewarded auction to GAM. The GAM reward is forwarded only
/// from the SDK's userDidEarnRewardHandler, after the ad is shown.
final class ReactNativeRewardedEventHandler: NSObject, RewardedEventHandlerProtocol,
    GoogleMobileAds.AdMetadataDelegate, GoogleMobileAds.FullScreenContentDelegate {
    private let adUnitId: String
    private let onSourceSelected: (String) -> Void
    private let onPrebidUnavailable: (String) -> Void
    private let onGamFailure: (Error?) -> Void
    private let onGamImpression: () -> Void
    private let onPresentationFailure: (Error) -> Void
    private var loadedAd: GoogleMobileAds.RewardedAd?
    private var appEventTimer: Timer?
    private var hadPrebidBid = false
    private var awaitingPrebidEvent = false
    private var selectedSource: String?
    private var didEarnReward = false

    weak var loadingDelegate: InterstitialEventLoadingDelegate?
    weak var interactionDelegate: RewardedEventInteractionDelegate?

    var isReady: Bool { loadedAd != nil && selectedSource == "gam" }

    init(adUnitId: String, onSourceSelected: @escaping (String) -> Void,
         onPrebidUnavailable: @escaping (String) -> Void,
         onGamFailure: @escaping (Error?) -> Void,
         onGamImpression: @escaping () -> Void,
         onPresentationFailure: @escaping (Error) -> Void) {
        self.adUnitId = adUnitId
        self.onSourceSelected = onSourceSelected
        self.onPrebidUnavailable = onPrebidUnavailable
        self.onGamFailure = onGamFailure
        self.onGamImpression = onGamImpression
        self.onPresentationFailure = onPresentationFailure
        super.init()
    }

    func requestAd(with bidResponse: BidResponse?) {
        appEventTimer?.invalidate()
        appEventTimer = nil
        loadedAd = nil
        didEarnReward = false
        hadPrebidBid = bidResponse?.winningBid != nil
        awaitingPrebidEvent = hadPrebidBid
        selectedSource = nil

        if !hadPrebidBid {
            onPrebidUnavailable("Prebid did not return a winning bid, or the ConfigId is wrong")
        }

        let request = GoogleMobileAds.AdManagerRequest()
        GAMUtils.shared.prepareRequest(request, bidTargeting: bidResponse?.targetingInfo ?? [:])
        GoogleMobileAds.RewardedAd.load(with: adUnitId, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    self.awaitingPrebidEvent = false
                    self.markPrebidFallbackIfAvailable()
                    self.onGamFailure(error)
                    self.loadingDelegate?.failed(with: error)
                    return
                }
                guard let ad else {
                    let error = NSError(domain: "VeonPrebidReactNative", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "GAM returned no rewarded ad"])
                    self.awaitingPrebidEvent = false
                    self.markPrebidFallbackIfAvailable()
                    self.onGamFailure(error)
                    self.loadingDelegate?.failed(with: error)
                    return
                }
                self.loadedAd = ad
                ad.adMetadataDelegate = self
                ad.fullScreenContentDelegate = self
                if self.awaitingPrebidEvent {
                    self.checkPrebidAppEvent(ad)
                    if self.awaitingPrebidEvent {
                        self.appEventTimer = Timer.scheduledTimer(withTimeInterval: 0.6,
                                                                 repeats: false) { [weak self] _ in
                            self?.selectGam()
                        }
                    }
                } else {
                    self.selectGam()
                }
            }
        }
    }

    func show(from viewController: UIViewController?) {
        guard let ad = loadedAd, let viewController else { return }
        ad.present(from: viewController) { [weak self, weak ad] in
            guard let self, let ad, !self.didEarnReward else { return }
            self.didEarnReward = true
            let reward = PrebidReward()
            reward.type = ad.adReward.type
            reward.count = ad.adReward.amount
            self.interactionDelegate?.userDidEarnReward(reward)
        }
    }

    func trackImpression() {}

    func adMetadataDidChange(_ ad: GoogleMobileAds.AdMetadataProvider) {
        guard let loadedAd, (ad as AnyObject) === loadedAd else { return }
        checkPrebidAppEvent(loadedAd)
    }

    private func checkPrebidAppEvent(_ ad: GoogleMobileAds.RewardedAd) {
        guard awaitingPrebidEvent, selectedSource == nil,
              ad.adMetadata?[GADAdMetadataKey(rawValue: "AdTitle")] as? String
                == "PrebidAppEvent" else { return }
        appEventTimer?.invalidate()
        appEventTimer = nil
        awaitingPrebidEvent = false
        selectedSource = "prebid"
        onSourceSelected("prebid")
        loadingDelegate?.prebidDidWin()
    }

    private func selectGam() {
        guard loadedAd != nil, selectedSource == nil else { return }
        appEventTimer?.invalidate()
        appEventTimer = nil
        awaitingPrebidEvent = false
        selectedSource = "gam"
        if hadPrebidBid {
            NSLog("VeonPrebid iOS: GAM selected its own ad instead of the Prebid bid")
        }
        onSourceSelected("gam")
        loadingDelegate?.adServerDidWin()
    }

    private func markPrebidFallbackIfAvailable() {
        guard hadPrebidBid else { return }
        selectedSource = "prebid"
        onSourceSelected("prebid")
    }

    func adDidRecordClick(_ ad: GoogleMobileAds.FullScreenPresentingAd) {
        interactionDelegate?.didClickAd()
    }

    func adDidDismissFullScreenContent(_ ad: GoogleMobileAds.FullScreenPresentingAd) {
        loadedAd = nil
        interactionDelegate?.didDismissAd()
    }

    func adDidRecordImpression(_ ad: GoogleMobileAds.FullScreenPresentingAd) {
        guard selectedSource == "gam", let loadedAd, (ad as AnyObject) === loadedAd else { return }
        onGamImpression()
    }

    func ad(_ ad: GoogleMobileAds.FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        loadedAd = nil
        onPresentationFailure(error)
    }
}

@objc(VeonPrebidReactNativeView)
class VeonPrebidReactNativeView: UIView {

    // MARK: - Properties

    /// Container view that holds ad views
    private var container: UIView?

    var bannerLoader: VeonMultiBannerAdLoader?
    var retiringBannerLoader: VeonMultiBannerAdLoader?
    var loadedBannerView: UIView?
    var bannerSourceErrors: [String] = []
    var interstitialSourceErrors: [String] = []
    private var bannerConstraints: [NSLayoutConstraint] = []
    var interstitialLoader: VeonMultiInterstitialAdLoader?
    var auctionPaused = false

    /// Prebid reward ad unit
    private var rewardedAdUnit: RewardedAdUnit?

    /// Set by the rewarded event handler when Prebid or GAM wins.
    var rewardedSource: String?
    var rewardedPrebidUnavailable = false
    var rewardedGamFailed = false

    /// Ad parameters
    var adParameters = AdParameters()

    // MARK: - React Native Props

    @objc var adTypeValue: NSString? {
        didSet {
            adParameters.adType = adTypeValue as String?
            updateAdConfiguration()
        }
    }

    @objc var configIdValue: NSString? {
        didSet {
            adParameters.configId = configIdValue as String?
            updateAdConfiguration()
        }
    }

    @objc var adUnitIdValue: NSString? {
        didSet {
            adParameters.adUnitId = adUnitIdValue as String?
            updateAdConfiguration()
        }
    }

    @objc var widthValue: NSNumber? {
        didSet {
            if let width = widthValue?.intValue {
                adParameters.bannerWidth = width
                updateAdConfiguration()
            }
        }
    }

    @objc var heightValue: NSNumber? {
        didSet {
            if let height = heightValue?.intValue {
                adParameters.bannerHeight = height
                updateAdConfiguration()
            }
        }
    }

    @objc var refreshIntervalValue: NSNumber? {
        didSet {
            if let interval = refreshIntervalValue?.doubleValue {
                adParameters.refreshInterval = interval
                updateAdConfiguration()
            }
        }
    }

    // MARK: - React Native Events

    @objc var onAdLoaded: RCTDirectEventBlock?
    @objc var onAdDisplayed: RCTDirectEventBlock?
    @objc var onAdFailed: RCTDirectEventBlock?
    @objc var onAdSourceFailed: RCTDirectEventBlock?
    @objc var onAdClicked: RCTDirectEventBlock?
    @objc var onAdClosed: RCTDirectEventBlock?
    @objc var onAdRewardEarned: RCTDirectEventBlock?

    // MARK: - Constants

    private enum AdType {
        static let banner = "banner"
        static let interstitial = "interstitial"
        static let rewardVideo = "rewardvideo"
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupView() {
        container = UIView(frame: bounds)
        container?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let container = container {
            addSubview(container)
        }

        NSLog("VeonPrebid iOS: View initialized")
    }

    // MARK: - Deinit

    deinit {
        cleanupAds()
    }

    private func cleanupAds() {
        NSLayoutConstraint.deactivate(bannerConstraints)
        bannerConstraints.removeAll()
        loadedBannerView?.removeFromSuperview()
        loadedBannerView = nil
        bannerLoader?.delegate = nil
        bannerLoader?.destroy()
        bannerLoader = nil
        retiringBannerLoader?.delegate = nil
        retiringBannerLoader?.destroy()
        retiringBannerLoader = nil
        auctionPaused = false
        interstitialLoader?.delegate = nil
        interstitialLoader?.destroy()
        interstitialLoader = nil
        rewardedAdUnit?.delegate = nil
        rewardedAdUnit = nil
        rewardedSource = nil
        rewardedPrebidUnavailable = false
        rewardedGamFailed = false
        bannerSourceErrors.removeAll()
        interstitialSourceErrors.removeAll()
    }

    // MARK: - Configuration

    private func updateAdConfiguration() {
        // Only proceed if we have all required parameters
        guard let adType = adParameters.adType,
              let configId = adParameters.configId,
              let adUnitId = adParameters.adUnitId else {
            return
        }

        NSLog("VeonPrebid iOS: Updating configuration - Type: \(adType), ConfigId: \(configId), AdUnitId: \(adUnitId)")
    }

    // MARK: - Public Methods (called from ViewManager)

    @objc func loadBanner() {
        guard let configId = adParameters.configId,
              let adUnitId = adParameters.adUnitId else {
            emitFailure("Missing configId or adUnitId")
            return
        }

        NSLog("VeonPrebid iOS: Loading banner")
        bannerSourceErrors.removeAll()
        if loadedBannerView?.superview != nil {
            // Keep the displayed ad alive until its replacement wins the race.
            if retiringBannerLoader == nil {
                retiringBannerLoader = bannerLoader
            } else {
                bannerLoader?.delegate = nil
                bannerLoader?.destroy()
            }
        } else {
            loadedBannerView?.removeFromSuperview()
            loadedBannerView = nil
            bannerLoader?.delegate = nil
            bannerLoader?.destroy()
        }
        let size = CGSize(width: adParameters.bannerWidth, height: adParameters.bannerHeight)
        bannerLoader = VeonMultiBannerAdLoader(
            rootViewController: getRootViewController(),
            adSize: size,
            refreshInterval: auctionPaused ? nil : adParameters.refreshInterval,
            configId: configId,
            gamAdUnitId: adUnitId,
            yandexAdUnitId: nil
        )
        bannerLoader?.delegate = self
        bannerLoader?.loadAd()
    }

    @objc func showBanner() {
        NSLog("VeonPrebid iOS: Showing banner")
        guard let container, let loadedBannerView else { return }
        guard loadedBannerView.superview !== container else { return }
        NSLayoutConstraint.deactivate(bannerConstraints)
        bannerConstraints.removeAll()
        loadedBannerView.removeFromSuperview()
        loadedBannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(loadedBannerView)
        bannerConstraints = [
            loadedBannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            loadedBannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            loadedBannerView.widthAnchor.constraint(equalToConstant: CGFloat(adParameters.bannerWidth)),
            loadedBannerView.heightAnchor.constraint(equalToConstant: CGFloat(adParameters.bannerHeight))
        ]
        NSLayoutConstraint.activate(bannerConstraints)
    }

    @objc func hideBanner() {
        NSLog("VeonPrebid iOS: Hiding banner")
        NSLayoutConstraint.deactivate(bannerConstraints)
        bannerConstraints.removeAll()
        loadedBannerView?.removeFromSuperview()
        loadedBannerView = nil
        bannerLoader?.delegate = nil
        bannerLoader?.destroy()
        bannerLoader = nil
        retiringBannerLoader?.delegate = nil
        retiringBannerLoader?.destroy()
        retiringBannerLoader = nil
    }

    @objc func loadInterstitial() {
        guard let configId = adParameters.configId,
              let adUnitId = adParameters.adUnitId else {
            emitFailure("Missing configId or adUnitId")
            return
        }

        NSLog("VeonPrebid iOS: Loading interstitial")
        interstitialSourceErrors.removeAll()
        interstitialLoader?.delegate = nil
        interstitialLoader?.destroy()
        interstitialLoader = VeonMultiInterstitialAdLoader(
            configId: configId, gamAdUnitId: adUnitId, yandexAdUnitId: nil
        )
        interstitialLoader?.delegate = self
        interstitialLoader?.loadAd()
    }

    @objc func showInterstitial() {
        NSLog("VeonPrebid iOS: Showing interstitial")

        guard let interstitialLoader, interstitialLoader.isReady else {
            emitFailure("No interstitial loaded yet")
            return
        }
        let rootViewController = getRootViewController()
        let controllerToPresent = rootViewController.presentedViewController ?? rootViewController
        interstitialLoader.show(from: controllerToPresent)
    }

    @objc func hideInterstitial() {
        NSLog("VeonPrebid iOS: Hiding interstitial")
        interstitialLoader?.delegate = nil
        interstitialLoader?.destroy()
        interstitialLoader = nil
    }

    @objc func loadRewarded() {
        guard let configId = adParameters.configId,
              let adUnitId = adParameters.adUnitId else {
            emitFailure("Missing configId or adUnitId")
            return
        }

        NSLog("VeonPrebid iOS: Loading rewarded")
        loadRewardVideo(configId: configId, adUnitId: adUnitId)
    }

    @objc func showRewarded() {
        NSLog("VeonPrebid iOS: Showing rewarded")

        guard let rewardedAdUnit = rewardedAdUnit, rewardedAdUnit.isReady else {
            emitFailure("No rewarded loaded yet or not ready")
            return
        }
        let rootViewController = getRootViewController()
        let controllerToPresent = rootViewController.presentedViewController ?? rootViewController
        rewardedAdUnit.show(from: controllerToPresent)
    }

    @objc func pauseAuction() {
        NSLog("VeonPrebid iOS: Pausing auction")
        auctionPaused = true
        (loadedBannerView as? PrebidMobile.BannerView)?.stopRefresh()
    }

    @objc func resumeAuction() {
        NSLog("VeonPrebid iOS: Resuming auction")
        auctionPaused = false
        (loadedBannerView as? PrebidMobile.BannerView)?.refreshInterval = adParameters.refreshInterval
    }

    @objc func destroyAuction() {
        NSLog("VeonPrebid iOS: Destroying auction")
        cleanupAds()
        container?.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Rewarded Loading

    private func loadRewardVideo(configId: String, adUnitId: String) {
        // Detach any prior delegate to prevent in-flight callbacks from a stale unit
        rewardedAdUnit?.delegate = nil
        rewardedAdUnit = nil

        rewardedSource = nil
        rewardedPrebidUnavailable = false
        rewardedGamFailed = false

        let eventHandler = ReactNativeRewardedEventHandler(
            adUnitId: adUnitId,
            onSourceSelected: { [weak self] source in
                self?.rewardedSource = source
                NSLog("VeonPrebid iOS: Rewarded source selected - \(source)")
            },
            onPrebidUnavailable: { [weak self] message in
                guard let self else { return }
                self.rewardedPrebidUnavailable = true
                self.emitSourceFailure(message, sdkType: "prebid")
                NSLog("VeonPrebid iOS: Prebid rewarded unavailable - \(message)")
            },
            onGamFailure: { [weak self] error in
                guard let self = self else { return }
                self.rewardedGamFailed = true
                let message = error?.localizedDescription ?? "Unknown GAM error"
                self.emitSourceFailure(message, sdkType: "gam")
                NSLog("VeonPrebid iOS: GAM rewarded failed - \(message)")
            },
            onGamImpression: { [weak self] in
                guard let self else { return }
                self.onAdDisplayed?([
                    "configId": configId,
                    "adUnitId": adUnitId,
                    "sdkType": "gam"
                ])
            },
            onPresentationFailure: { [weak self] error in
                self?.emitFailure(error.localizedDescription)
            }
        )
        rewardedAdUnit = RewardedAdUnit(configID: configId, eventHandler: eventHandler)
        rewardedAdUnit?.delegate = self
        rewardedAdUnit?.loadAd()
    }

    // MARK: - Utility Methods

    /// Emits onAdFailed to JS with a developer-supplied error message, so JS callers
    /// see a feedback event for validation/state failures (missing params, no ad ready, etc.)
    /// instead of a silent no-op.
    func emitSourceFailure(_ message: String, sdkType: String) {
        onAdSourceFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "error": message,
            "sdkType": sdkType
        ])
    }

    func emitFailure(_ message: String) {
        NSLog("VeonPrebid iOS: \(message)")
        onAdFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "error": message
        ])
    }

    func getRootViewController() -> UIViewController {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            return rootViewController
        }
        return UIViewController()
    }

}
