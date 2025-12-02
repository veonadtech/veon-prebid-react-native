import UIKit
import GoogleMobileAds
import PrebidMobile
import PrebidMobileGAMEventHandlers

@objc(VeonPrebidReactNativeView)
class VeonPrebidReactNativeView: UIView {

    // MARK: - Properties

    /// Container view that holds ad views
    private var container: UIView!

    /// GAM Banner view
    internal var gamBanner: AdManagerBannerView?

    /// Prebid banner view
    private var prebidBannerView: PrebidMobile.BannerView?

    /// Prebid interstitial rendering ad unit
    private var prebidInterstitial: InterstitialRenderingAdUnit?

    /// Prebid reward ad unit
    private var rewardedAdUnit: RewardedAdUnit?

    /// Ad parameters
    internal var configId: String?
    internal var adUnitId: String?
    internal var adType: String?
    internal var bannerWidth: Int = 0
    internal var bannerHeight: Int = 0
    internal var refreshInterval: Double = 30.0

    // MARK: - React Native Props

    @objc var adTypeValue: NSString? {
        didSet {
            adType = adTypeValue as String?
            updateAdConfiguration()
        }
    }

    @objc var configIdValue: NSString? {
        didSet {
            configId = configIdValue as String?
            updateAdConfiguration()
        }
    }

    @objc var adUnitIdValue: NSString? {
        didSet {
            adUnitId = adUnitIdValue as String?
            updateAdConfiguration()
        }
    }

    @objc var widthValue: NSNumber? {
        didSet {
            if let width = widthValue?.intValue {
                bannerWidth = width
                updateAdConfiguration()
            }
        }
    }

    @objc var heightValue: NSNumber? {
        didSet {
            if let height = heightValue?.intValue {
                bannerHeight = height
                updateAdConfiguration()
            }
        }
    }

    @objc var refreshIntervalValue: NSNumber? {
        didSet {
            if let interval = refreshIntervalValue?.doubleValue {
                refreshInterval = interval
                updateAdConfiguration()
            }
        }
    }

    // MARK: - React Native Events

    @objc var onAdLoaded: RCTDirectEventBlock?
    @objc var onAdDisplayed: RCTDirectEventBlock?
    @objc var onAdFailed: RCTDirectEventBlock?
    @objc var onAdClicked: RCTDirectEventBlock?
    @objc var onAdClosed: RCTDirectEventBlock?

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
        setupView()
    }

    private func setupView() {
        container = UIView(frame: bounds)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(container)

        NSLog("VeonPrebid iOS: View initialized")
    }

    // MARK: - Deinit

    deinit {
        cleanupAds()
    }

    private func cleanupAds() {
        prebidBannerView?.delegate = nil
        prebidBannerView = nil
        gamBanner?.delegate = nil
        gamBanner = nil
        prebidInterstitial?.delegate = nil
        prebidInterstitial = nil
        rewardedAdUnit?.delegate = nil
        rewardedAdUnit = nil
    }

    // MARK: - Configuration

    private func updateAdConfiguration() {
        // Only proceed if we have all required parameters
        guard let adType = adType,
              let configId = configId,
              let adUnitId = adUnitId else {
            return
        }

        NSLog("VeonPrebid iOS: Updating configuration - Type: \(adType), ConfigId: \(configId), AdUnitId: \(adUnitId)")

        // Setup ad based on type
        switch adType.lowercased() {
        case AdType.banner:
            if bannerWidth > 0 && bannerHeight > 0 {
                setupBannerAd(configId: configId, adUnitId: adUnitId)
            }
        case AdType.interstitial:
            setupInterstitialAd(configId: configId, adUnitId: adUnitId)
        case AdType.rewardVideo:
            setupRewardVideoAd(configId: configId, adUnitId: adUnitId)
        default:
            NSLog("VeonPrebid iOS: Unknown ad type: \(adType)")
        }
    }

    // MARK: - Ad Setup Methods

    private func setupBannerAd(configId: String, adUnitId: String) {
        NSLog("VeonPrebid iOS: Setting up banner ad - \(bannerWidth)x\(bannerHeight)")
        // Banner will be loaded when loadBanner() is called
    }

    private func setupInterstitialAd(configId: String, adUnitId: String) {
        NSLog("VeonPrebid iOS: Setting up interstitial ad")
        // Interstitial will be loaded when loadInterstitial() is called
    }

    private func setupRewardVideoAd(configId: String, adUnitId: String) {
        NSLog("VeonPrebid iOS: Setting up reward video ad")
        // Reward video will be loaded when loadInterstitial() is called
    }

    // MARK: - Public Methods (called from ViewManager)

    @objc func loadBanner() {
        guard let configId = configId,
              let adUnitId = adUnitId else {
            NSLog("VeonPrebid iOS: Cannot load banner - missing configId or adUnitId")
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
        guard let configId = configId,
              let adUnitId = adUnitId,
              let adType = adType else {
            NSLog("VeonPrebid iOS: Cannot load interstitial - missing parameters")
            return
        }

        NSLog("VeonPrebid iOS: Loading interstitial")

        if adType.lowercased() == AdType.rewardVideo {
            loadRewardVideo(configId: configId, adUnitId: adUnitId)
        } else {
            loadInterstitialRendering(configId: configId, adUnitId: adUnitId)
        }
    }

    @objc func showInterstitial() {
        NSLog("VeonPrebid iOS: Showing interstitial")

        if let prebidInterstitial = prebidInterstitial {
            let rootViewController = getRootViewController()
            let controllerToPresent = rootViewController.presentedViewController ?? rootViewController
            prebidInterstitial.show(from: controllerToPresent)
        } else if let rewardedAdUnit = rewardedAdUnit, rewardedAdUnit.isReady {
            rewardedAdUnit.show(from: getRootViewController())
        }
    }

    @objc func hideInterstitial() {
        NSLog("VeonPrebid iOS: Hiding interstitial")
        prebidInterstitial?.delegate = nil
        prebidInterstitial = nil
        rewardedAdUnit?.delegate = nil
        rewardedAdUnit = nil
    }

    @objc func pauseAuction() {
        NSLog("VeonPrebid iOS: Pausing auction")
        prebidBannerView?.stopRefresh()
    }

    @objc func resumeAuction() {
        NSLog("VeonPrebid iOS: Resuming auction")
        prebidBannerView?.refreshInterval = refreshInterval
    }

    @objc func destroyAuction() {
        NSLog("VeonPrebid iOS: Destroying auction")
        cleanupAds()
        container.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Banner Loading

    private func loadGamBanner(configId: String, adUnitId: String) {
        let adSize = CGSize(width: bannerWidth, height: bannerHeight)

        guard gamBanner == nil else {
            NSLog("VeonPrebid iOS: GAM Banner already exists")
            return
        }

        let adUnit = BannerAdUnit(configId: configId, size: adSize)

        // Configure banner parameters
        let parameters = BannerParameters()
        parameters.api = [Signals.Api.MRAID_2]
        adUnit.bannerParameters = parameters
        adUnit.setAutoRefreshMillis(time: refreshInterval * 1000)

        // Create a GAMBannerView
        gamBanner = AdManagerBannerView(adSize: adSizeFor(cgSize: adSize))
        gamBanner?.adUnitID = adUnitId
        gamBanner?.delegate = self
        gamBanner?.rootViewController = getRootViewController()

        // Make a bid request to Prebid Server
        let gamRequest = AdManagerRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            guard let self = self, let gamBanner = self.gamBanner else { return }
            NSLog("VeonPrebid iOS: Prebid demand fetch for GAM - \(resultCode.name())")

            // Load GAM Ad
            gamBanner.load(gamRequest)
        }
    }

    internal func loadPrebidBanner() {
        let adSize = CGSize(width: bannerWidth, height: bannerHeight)

        guard prebidBannerView == nil,
              let configId = configId else {
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
        prebidBannerView?.refreshInterval = refreshInterval

        // Load the banner ad
        prebidBannerView?.loadAd()
    }

    // MARK: - Interstitial Loading

    private func loadInterstitialRendering(configId: String, adUnitId: String) {
        let eventHandler = GAMInterstitialEventHandler(adUnitID: adUnitId)
        let size = CGSize(width: bannerWidth > 0 ? bannerWidth : 320,
                         height: bannerHeight > 0 ? bannerHeight : 480)

        prebidInterstitial = InterstitialRenderingAdUnit(
            configID: configId,
            minSizePercentage: size,
            eventHandler: eventHandler
        )
        prebidInterstitial?.delegate = self
        prebidInterstitial?.loadAd()
    }

    private func loadRewardVideo(configId: String, adUnitId: String) {
        let eventHandler = GAMRewardedAdEventHandler(adUnitID: adUnitId)
        rewardedAdUnit = RewardedAdUnit(configID: configId, eventHandler: eventHandler)
        rewardedAdUnit?.delegate = self
        rewardedAdUnit?.loadAd()
    }

    // MARK: - Utility Methods

    internal func getRootViewController() -> UIViewController {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            return rootViewController
        }
        return UIViewController()
    }

    private func addGamBannerViewToView(_ bannerView: AdManagerBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    private func addPrebidBannerViewToView(_ bannerView: PrebidMobile.BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
            bannerView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    internal func adSizeFor(cgSize: CGSize) -> AdSize {
        return AdSize(size: cgSize, flags: 0)
    }

}
