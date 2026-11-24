import UIKit
import GoogleMobileAds
import PrebidMobile

// MARK: - InterstitialAdUnitDelegate

extension VeonPrebidReactNativeView: InterstitialAdUnitDelegate {

    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        let source = interstitialSource ?? "prebid"
        NSLog("VeonPrebid iOS: Interstitial ad loaded from \(source)")
        onAdLoaded?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": source
        ])
    }

    func interstitial(_ interstitial: InterstitialRenderingAdUnit, didFailToReceiveAdWithError error: Error?) {
        if interstitialPrebidUnavailable && interstitialGamFailed { return }
        let errorMsg = error?.localizedDescription ?? "Unknown error"
        NSLog("VeonPrebid iOS: Interstitial failed to load - \(errorMsg)")
        onAdFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "error": errorMsg,
            "sdkType": interstitialSource ?? "prebid"
        ])
    }

    func interstitialWillLeaveApplication(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial will leave application")
        onAdClicked?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": interstitialSource ?? "prebid"
        ])
    }

    func interstitialDidClickAd(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial clicked")
        onAdClicked?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": interstitialSource ?? "prebid"
        ])
    }

    func interstitialDidCloseAd(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial closed")
        onAdClosed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": interstitialSource ?? "prebid"
        ])
    }

    func interstitialWillPresentAd(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial displayed")
        onAdDisplayed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": interstitialSource ?? "prebid"
        ])
    }
}

// MARK: - BannerViewDelegate

extension VeonPrebidReactNativeView: PrebidMobile.BannerViewDelegate {

    func bannerViewPresentationController() -> UIViewController? {
        return getRootViewController()
    }

    func bannerView(_ bannerView: PrebidMobile.BannerView, didReceiveAdWithAdSize adSize: CGSize) {
        NSLog("VeonPrebid iOS: Prebid banner loaded successfully")
        onAdLoaded?([
            "configId": bannerView.configID,
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": "prebid"
        ])
    }

    func bannerView(_ bannerView: PrebidMobile.BannerView, didFailToReceiveAdWith error: Error) {
        let errorMsg = error.localizedDescription
        NSLog("VeonPrebid iOS: Prebid banner failed to load - \(errorMsg)")
        onAdFailed?([
            "configId": bannerView.configID,
            "adUnitId": adParameters.adUnitId ?? "",
            "error": errorMsg,
            "sdkType": "prebid"
        ])
    }

    func bannerViewDidRecordImpression(_ bannerView: PrebidMobile.BannerView) {
        NSLog("VeonPrebid iOS: Banner recorded impression")
    }

    func bannerViewWillLeaveApplication(_ bannerView: PrebidMobile.BannerView) {
        NSLog("VeonPrebid iOS: Banner will leave application")
        onAdClicked?([
            "configId": bannerView.configID,
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": "prebid"
        ])
    }

    func bannerViewWillPresentModal(_ bannerView: PrebidMobile.BannerView) {
        onAdDisplayed?([
            "configId": bannerView.configID,
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": "prebid"
        ])
    }
}

// MARK: - RewardedAdUnitDelegate
// The event handler records the winner before these RewardedAdUnit callbacks run.

extension VeonPrebidReactNativeView: RewardedAdUnitDelegate {

    func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
        let source = rewardedSource ?? "unknown"
        NSLog("VeonPrebid iOS: Rewarded ad received from \(source)")
        onAdLoaded?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": source
        ])
    }

    func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        // Both source failures were already emitted with their own SDK labels.
        if rewardedPrebidUnavailable && rewardedGamFailed { return }
        let errorMsg = error?.localizedDescription ?? "Unknown error"
        NSLog("VeonPrebid iOS: Rewarded ad failed to load - \(errorMsg)")
        onAdFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "error": errorMsg,
            "sdkType": rewardedSource ?? "prebid"
        ])
    }

    func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit, reward: PrebidReward) {
        let rewardType = reward.type ?? ""
        let rewardCount = reward.count ?? 0
        NSLog("VeonPrebid iOS: User earned reward - type: \(rewardType), count: \(rewardCount)")
        onAdRewardEarned?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": rewardedSource ?? "unknown",
            "rewardType": rewardType,
            "rewardAmount": rewardCount
        ])
    }

    func rewardedAdWillPresentAd(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad will present")
        onAdDisplayed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": rewardedSource ?? "unknown"
        ])
    }

    func rewardedAdDidDismissAd(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad dismissed")
        onAdClosed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": rewardedSource ?? "unknown"
        ])
    }

    func rewardedAdDidClickAd(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad clicked")
        onAdClicked?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": rewardedSource ?? "unknown"
        ])
    }

    func rewardedAdWillLeaveApplication(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad will leave application")
        onAdClicked?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": rewardedSource ?? "unknown"
        ])
    }
}

// MARK: - GADBannerViewDelegate

extension VeonPrebidReactNativeView: GoogleMobileAds.BannerViewDelegate {

    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        NSLog("VeonPrebid iOS: GAM banner loaded successfully")
        onAdLoaded?([
            "configId": adParameters.configId ?? "",
            "adUnitId": bannerView.adUnitID ?? "",
            "sdkType": "gam"
        ])
    }

    func bannerView(_ bannerView: GoogleMobileAds.BannerView,
                    didFailToReceiveAdWithError error: Error) {
        let errorMsg = error.localizedDescription
        NSLog("VeonPrebid iOS: GAM banner failed to load - \(errorMsg)")
        onAdFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": bannerView.adUnitID ?? "",
            "error": errorMsg,
            "sdkType": "gam"
        ])

        // Fallback to Prebid ad when GAM fails
        gamBanner = nil
        loadPrebidBanner()
    }
}

// End of VeonPrebidReactNativeView+Delegates.swift
