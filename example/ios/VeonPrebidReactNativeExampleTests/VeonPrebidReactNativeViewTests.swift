import XCTest
@testable import VeonPrebidReactNative

/// Tests that the native view correctly receives and stores props set via KVC,
/// and that all command methods are callable without crashing.
/// This verifies the JS → Native bridge on iOS: when React Native sets a prop
/// or dispatches a command, the native view processes it correctly.
class VeonPrebidReactNativeViewTests: XCTestCase {

    var view: VeonPrebidReactNativeView!

    override func setUp() {
        super.setUp()
        view = VeonPrebidReactNativeView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
    }

    override func tearDown() {
        view = nil
        super.tearDown()
    }

    // MARK: - Props via KVC (how Fabric ComponentView sets them)

    func testSetAdTypeViaKVC() {
        view.setValue("banner" as NSString, forKey: "adTypeValue")
        XCTAssertEqual(view.adParameters.adType, "banner")
    }

    func testSetConfigIdViaKVC() {
        view.setValue("config-123" as NSString, forKey: "configIdValue")
        XCTAssertEqual(view.adParameters.configId, "config-123")
    }

    func testSetAdUnitIdViaKVC() {
        view.setValue("/network/ad-unit" as NSString, forKey: "adUnitIdValue")
        XCTAssertEqual(view.adParameters.adUnitId, "/network/ad-unit")
    }

    func testSetWidthViaKVC() {
        view.setValue(NSNumber(value: 320), forKey: "widthValue")
        XCTAssertEqual(view.adParameters.bannerWidth, 320)
    }

    func testSetHeightViaKVC() {
        view.setValue(NSNumber(value: 250), forKey: "heightValue")
        XCTAssertEqual(view.adParameters.bannerHeight, 250)
    }

    func testSetRefreshIntervalViaKVC() {
        view.setValue(NSNumber(value: 60.0), forKey: "refreshIntervalValue")
        XCTAssertEqual(view.adParameters.refreshInterval, 60.0)
    }

    // MARK: - Props via direct property assignment (how ViewManager sets them)

    func testSetAdTypeDirectly() {
        view.adTypeValue = "interstitial"
        XCTAssertEqual(view.adParameters.adType, "interstitial")
    }

    func testSetConfigIdDirectly() {
        view.configIdValue = "my-config"
        XCTAssertEqual(view.adParameters.configId, "my-config")
    }

    func testSetAdUnitIdDirectly() {
        view.adUnitIdValue = "/test/unit"
        XCTAssertEqual(view.adParameters.adUnitId, "/test/unit")
    }

    func testSetWidthDirectly() {
        view.widthValue = 300
        XCTAssertEqual(view.adParameters.bannerWidth, 300)
    }

    func testSetHeightDirectly() {
        view.heightValue = 250
        XCTAssertEqual(view.adParameters.bannerHeight, 250)
    }

    func testSetRefreshIntervalDirectly() {
        view.refreshIntervalValue = 45
        XCTAssertEqual(view.adParameters.refreshInterval, 45.0)
    }

    // MARK: - Default values

    func testDefaultAdParameters() {
        XCTAssertNil(view.adParameters.adType)
        XCTAssertNil(view.adParameters.configId)
        XCTAssertNil(view.adParameters.adUnitId)
        XCTAssertEqual(view.adParameters.bannerWidth, 0)
        XCTAssertEqual(view.adParameters.bannerHeight, 0)
        XCTAssertEqual(view.adParameters.refreshInterval, 30.0)
    }

    // MARK: - Commands respond to selectors (how Fabric ComponentView dispatches them)

    func testRespondsToLoadBanner() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.loadBanner)))
    }

    func testRespondsToShowBanner() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.showBanner)))
    }

    func testRespondsToHideBanner() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.hideBanner)))
    }

    func testRespondsToLoadInterstitial() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.loadInterstitial)))
    }

    func testRespondsToShowInterstitial() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.showInterstitial)))
    }

    func testRespondsToHideInterstitial() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.hideInterstitial)))
    }

    func testRespondsToPauseAuction() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.pauseAuction)))
    }

    func testRespondsToResumeAuction() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.resumeAuction)))
    }

    func testRespondsToDestroyAuction() {
        XCTAssertTrue(view.responds(to: #selector(VeonPrebidReactNativeView.destroyAuction)))
    }

    // MARK: - Commands callable via performSelector (exact path Fabric uses)

    func testPerformSelectorLoadBanner() {
        // Should not crash — missing configId/adUnitId will just log and return
        view.perform(#selector(VeonPrebidReactNativeView.loadBanner))
    }

    func testPerformSelectorShowBanner() {
        view.perform(#selector(VeonPrebidReactNativeView.showBanner))
    }

    func testPerformSelectorHideBanner() {
        view.perform(#selector(VeonPrebidReactNativeView.hideBanner))
    }

    func testPerformSelectorLoadInterstitial() {
        view.perform(#selector(VeonPrebidReactNativeView.loadInterstitial))
    }

    func testPerformSelectorShowInterstitial() {
        view.perform(#selector(VeonPrebidReactNativeView.showInterstitial))
    }

    func testPerformSelectorHideInterstitial() {
        view.perform(#selector(VeonPrebidReactNativeView.hideInterstitial))
    }

    func testPerformSelectorPauseAuction() {
        view.perform(#selector(VeonPrebidReactNativeView.pauseAuction))
    }

    func testPerformSelectorResumeAuction() {
        view.perform(#selector(VeonPrebidReactNativeView.resumeAuction))
    }

    func testPerformSelectorDestroyAuction() {
        view.perform(#selector(VeonPrebidReactNativeView.destroyAuction))
    }

    // MARK: - Event blocks exist as KVC-settable properties

    func testEventBlocksSettableViaKVC() {
        let block: RCTDirectEventBlock = { _ in }

        // Should not crash — these are the exact keys Fabric ComponentView uses
        view.setValue(block, forKey: "onAdLoaded")
        view.setValue(block, forKey: "onAdDisplayed")
        view.setValue(block, forKey: "onAdFailed")
        view.setValue(block, forKey: "onAdClicked")
        view.setValue(block, forKey: "onAdClosed")
    }

    // MARK: - Event callback wiring

    func testOnAdFailedBlockIsAssignable() {
        var callbackFired = false
        view.onAdFailed = { _ in callbackFired = true }

        // Verify block was assigned (not nil)
        XCTAssertNotNil(view.onAdFailed)

        // Invoke directly to verify wiring
        view.onAdFailed?([:])
        XCTAssertTrue(callbackFired)
    }

    // MARK: - DestroyAuction cleanup

    func testDestroyAuctionCleansUp() {
        view.adTypeValue = "banner"
        view.configIdValue = "test"
        view.adUnitIdValue = "/test/unit"

        view.destroyAuction()

        // After destroy, internal ad objects should be nil
        XCTAssertNil(view.gamBanner)
    }

    // MARK: - Multiple prop updates

    func testMultiplePropsSetCorrectly() {
        view.adTypeValue = "banner"
        view.configIdValue = "config-456"
        view.adUnitIdValue = "/network/banner-unit"
        view.widthValue = 728
        view.heightValue = 90
        view.refreshIntervalValue = 120

        XCTAssertEqual(view.adParameters.adType, "banner")
        XCTAssertEqual(view.adParameters.configId, "config-456")
        XCTAssertEqual(view.adParameters.adUnitId, "/network/banner-unit")
        XCTAssertEqual(view.adParameters.bannerWidth, 728)
        XCTAssertEqual(view.adParameters.bannerHeight, 90)
        XCTAssertEqual(view.adParameters.refreshInterval, 120.0)
    }
}
