import UIKit
import GoogleMobileAds
import PrebidMobile
import VeonPrebidMobileGAMEventHandlers

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
         onGamFailure: @escaping (Error?) -> Void) {
        self.adUnitId = adUnitId
        self.onSourceSelected = onSourceSelected
        self.onPrebidUnavailable = onPrebidUnavailable
        self.onGamFailure = onGamFailure
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
            onPrebidUnavailable("Prebid did not return a winning bid")
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
            onPrebidUnavailable("GAM selected its own ad instead of the Prebid bid")
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

    func ad(_ ad: GoogleMobileAds.FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        onGamFailure(error)
    }
}

/// Reports the outcome of each source while retaining the SDK's GAM interstitial handler.
final class ReactNativeInterstitialEventHandler: NSObject, InterstitialEventHandlerProtocol,
    InterstitialEventLoadingDelegate {
    private let gamHandler: GAMInterstitialEventHandler
    private let onSourceSelected: (String) -> Void
    private let onPrebidUnavailable: (String) -> Void
    private let onGamFailure: (Error?) -> Void
    private let onGamServedPrebid: () -> Void
    private var hadPrebidBid = false

    weak var loadingDelegate: InterstitialEventLoadingDelegate?
    weak var interactionDelegate: InterstitialEventInteractionDelegate? {
        didSet { gamHandler.interactionDelegate = interactionDelegate }
    }

    var isReady: Bool { gamHandler.isReady }

    init(adUnitId: String, onSourceSelected: @escaping (String) -> Void,
         onPrebidUnavailable: @escaping (String) -> Void,
         onGamFailure: @escaping (Error?) -> Void,
         onGamServedPrebid: @escaping () -> Void) {
        gamHandler = GAMInterstitialEventHandler(adUnitID: adUnitId)
        self.onSourceSelected = onSourceSelected
        self.onPrebidUnavailable = onPrebidUnavailable
        self.onGamFailure = onGamFailure
        self.onGamServedPrebid = onGamServedPrebid
        super.init()
        gamHandler.loadingDelegate = self
    }

    func requestAd(with bidResponse: BidResponse?) {
        hadPrebidBid = bidResponse?.winningBid != nil
        if !hadPrebidBid {
            onPrebidUnavailable("Prebid did not return a winning bid")
        }
        gamHandler.requestAd(with: bidResponse)
    }

    func show(from viewController: UIViewController?) {
        gamHandler.show(from: viewController)
    }

    func prebidDidWin() {
        onGamServedPrebid()
        onSourceSelected("prebid")
        loadingDelegate?.prebidDidWin()
    }

    func adServerDidWin() {
        if hadPrebidBid {
            onPrebidUnavailable("GAM selected its own ad instead of the Prebid bid")
        }
        onSourceSelected("gam")
        loadingDelegate?.adServerDidWin()
    }

    func failed(with error: Error?) {
        if hadPrebidBid { onSourceSelected("prebid") }
        onGamFailure(error)
        loadingDelegate?.failed(with: error)
    }
}

@objc(VeonPrebidReactNativeView)
class VeonPrebidReactNativeView: UIView {

    // MARK: - Properties

    /// Container view that holds ad views
    private var container: UIView?

    /// GAM Banner view
    var gamBanner: AdManagerBannerView?

    /// Prebid banner view
    private var prebidBannerView: PrebidMobile.BannerView?

    /// Prebid banner ad unit (must be retained for auto-refresh to work)
    private var bannerAdUnit: BannerAdUnit?

    /// Prebid interstitial rendering ad unit
    private var prebidInterstitial: InterstitialRenderingAdUnit?
    var interstitialSource: String?
    var interstitialPrebidUnavailable = false
    var interstitialGamFailed = false

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
    @objc var onDemandResult: RCTDirectEventBlock?
    @objc var onAdDisplayed: RCTDirectEventBlock?
    @objc var onAdFailed: RCTDirectEventBlock?
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
        bannerAdUnit?.stopAutoRefresh()
        bannerAdUnit = nil
        prebidBannerView?.delegate = nil
        prebidBannerView = nil
        gamBanner?.delegate = nil
        gamBanner = nil
        prebidInterstitial?.delegate = nil
        prebidInterstitial = nil
        interstitialSource = nil
        interstitialPrebidUnavailable = false
        interstitialGamFailed = false
        rewardedAdUnit?.delegate = nil
        rewardedAdUnit = nil
        rewardedSource = nil
        rewardedPrebidUnavailable = false
        rewardedGamFailed = false
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
        loadGamBanner(configId: configId, adUnitId: adUnitId)
    }

    @objc func showBanner() {
        NSLog("VeonPrebid iOS: Showing banner")
        if let gamBanner = gamBanner {
            addGamBannerViewToView(gamBanner)
        }
        if let prebidBannerView = prebidBannerView {
            addPrebidBannerViewToView(prebidBannerView)
        }
    }

    @objc func hideBanner() {
        NSLog("VeonPrebid iOS: Hiding banner")
        prebidBannerView?.removeFromSuperview()
        gamBanner?.removeFromSuperview()
        prebidBannerView?.delegate = nil
        prebidBannerView = nil
        gamBanner?.delegate = nil
        gamBanner = nil
    }

    @objc func loadInterstitial() {
        guard let configId = adParameters.configId,
              let adUnitId = adParameters.adUnitId else {
            emitFailure("Missing configId or adUnitId")
            return
        }

        NSLog("VeonPrebid iOS: Loading interstitial")
        loadInterstitialRendering(configId: configId, adUnitId: adUnitId)
    }

    @objc func showInterstitial() {
        NSLog("VeonPrebid iOS: Showing interstitial")

        guard let prebidInterstitial = prebidInterstitial else {
            emitFailure("No interstitial loaded yet")
            return
        }
        let rootViewController = getRootViewController()
        let controllerToPresent = rootViewController.presentedViewController ?? rootViewController
        prebidInterstitial.show(from: controllerToPresent)
    }

    @objc func hideInterstitial() {
        NSLog("VeonPrebid iOS: Hiding interstitial")
        prebidInterstitial?.delegate = nil
        prebidInterstitial = nil
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
        prebidBannerView?.stopRefresh()
    }

    @objc func resumeAuction() {
        NSLog("VeonPrebid iOS: Resuming auction")
        prebidBannerView?.refreshInterval = adParameters.refreshInterval
    }

    @objc func destroyAuction() {
        NSLog("VeonPrebid iOS: Destroying auction")
        cleanupAds()
        container?.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Banner Loading

    private func loadGamBanner(configId: String, adUnitId: String) {
        let adSize = CGSize(width: adParameters.bannerWidth, height: adParameters.bannerHeight)

        guard gamBanner == nil else {
            NSLog("VeonPrebid iOS: GAM Banner already exists")
            return
        }

        // Store as property so it stays alive for auto-refresh
        bannerAdUnit = BannerAdUnit(configId: configId, size: adSize)

        // Configure banner parameters
        let parameters = BannerParameters()
        parameters.api = [Signals.Api.MRAID_2]
        bannerAdUnit?.bannerParameters = parameters
        bannerAdUnit?.setAutoRefreshMillis(time: adParameters.refreshInterval * 1000)

        // Create a GAMBannerView
        gamBanner = AdManagerBannerView(adSize: adSizeFor(cgSize: adSize))
        gamBanner?.adUnitID = adUnitId
        gamBanner?.delegate = self
        gamBanner?.rootViewController = getRootViewController()

        // Make a bid request to Prebid Server
        let gamRequest = AdManagerRequest()
        bannerAdUnit?.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            guard let self = self, let gamBanner = self.gamBanner else { return }
            NSLog("VeonPrebid iOS: Prebid demand fetch for GAM - \(resultCode.name())")

            self.onDemandResult?([
                "configId": configId,
                "adUnitId": adUnitId,
                "sdkType": "prebid",
                "message": resultCode.name(),
                "error": resultCode == .prebidDemandFetchSuccess ? "" : resultCode.name()
            ])

            // Load GAM Ad
            gamBanner.load(gamRequest)
        }
    }

    internal func loadPrebidBanner() {
        let adSize = CGSize(width: adParameters.bannerWidth, height: adParameters.bannerHeight)

        guard prebidBannerView == nil,
              let configId = adParameters.configId else {
            return
        }

        prebidBannerView = BannerView(
            frame: CGRect(origin: .zero, size: adSize),
            configID: configId,
            adSize: adSize
        )

        // Configure the BannerView
        prebidBannerView?.delegate = self
        prebidBannerView?.adFormat = .banner
        prebidBannerView?.refreshInterval = adParameters.refreshInterval

        // Load the banner ad
        prebidBannerView?.loadAd()
    }

    // MARK: - Interstitial Loading

    private func loadInterstitialRendering(configId: String, adUnitId: String) {
        prebidInterstitial?.delegate = nil
        prebidInterstitial = nil
        interstitialSource = nil
        interstitialPrebidUnavailable = false
        interstitialGamFailed = false

        let eventHandler = ReactNativeInterstitialEventHandler(
            adUnitId: adUnitId,
            onSourceSelected: { [weak self] source in
                self?.interstitialSource = source
                NSLog("VeonPrebid iOS: Interstitial source selected - \(source)")
            },
            onPrebidUnavailable: { [weak self] message in
                guard let self else { return }
                self.interstitialPrebidUnavailable = true
                NSLog("VeonPrebid iOS: Prebid interstitial unavailable - \(message)")
                self.onAdFailed?([
                    "configId": configId,
                    "adUnitId": adUnitId,
                    "error": message,
                    "sdkType": "prebid"
                ])
            },
            onGamFailure: { [weak self] error in
                guard let self else { return }
                self.interstitialGamFailed = true
                let message = error?.localizedDescription ?? "Unknown GAM error"
                NSLog("VeonPrebid iOS: GAM interstitial failed - \(message)")
                self.onAdFailed?([
                    "configId": configId,
                    "adUnitId": adUnitId,
                    "error": message,
                    "sdkType": "gam"
                ])
            },
            onGamServedPrebid: { [weak self] in
                self?.onDemandResult?([
                    "configId": configId,
                    "adUnitId": adUnitId,
                    "sdkType": "gam",
                    "message": "GAM request succeeded; Prebid line item won"
                ])
            }
        )
        let size = CGSize(width: adParameters.bannerWidth, height: adParameters.bannerHeight)

        prebidInterstitial = InterstitialRenderingAdUnit(
            configID: configId,
            minSizePercentage: size,
            eventHandler: eventHandler
        )
        prebidInterstitial?.delegate = self
        prebidInterstitial?.loadAd()
    }

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
                NSLog("VeonPrebid iOS: Prebid rewarded unavailable - \(message)")
                self.onAdFailed?([
                    "configId": configId,
                    "adUnitId": adUnitId,
                    "error": message,
                    "sdkType": "prebid"
                ])
            },
            onGamFailure: { [weak self] error in
                guard let self = self else { return }
                self.rewardedGamFailed = true
                let message = error?.localizedDescription ?? "Unknown GAM error"
                NSLog("VeonPrebid iOS: GAM rewarded failed - \(message)")
                self.onAdFailed?([
                    "configId": configId,
                    "adUnitId": adUnitId,
                    "error": message,
                    "sdkType": "gam"
                ])
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
    private func emitFailure(_ message: String) {
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

    private func addGamBannerViewToView(_ bannerView: AdManagerBannerView) {
        guard let container = container else { return }
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    private func addPrebidBannerViewToView(_ bannerView: PrebidMobile.BannerView) {
        guard let container = container else { return }
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
            bannerView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

}
