import UIKit
import GoogleMobileAds
import PrebidMobile

// MARK: - InterstitialAdUnitDelegate

extension VeonPrebidReactNativeView: InterstitialAdUnitDelegate {

    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial ad loaded")
        onAdLoaded?(["configId": adParameters.configId ?? ""])
    }

    func interstitial(_ interstitial: InterstitialRenderingAdUnit, didFailToReceiveAdWithError error: Error?) {
        let errorMsg = error?.localizedDescription ?? "Unknown error"
        NSLog("VeonPrebid iOS: Interstitial failed to load - \(errorMsg)")
        onAdFailed?(["error": errorMsg])
    }

    func interstitialWillLeaveApplication(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial will leave application")
        onAdClicked?(["configId": adParameters.configId ?? ""])
    }

    func interstitialDidClickAd(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial clicked")
        onAdClicked?(["configId": adParameters.configId ?? ""])
    }

    func interstitialDidCloseAd(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial closed")
        onAdClosed?(["configId": adParameters.configId ?? ""])
    }

    func interstitialWillPresentAd(_ interstitial: InterstitialRenderingAdUnit) {
        NSLog("VeonPrebid iOS: Interstitial displayed")
        onAdDisplayed?(["configId": adParameters.configId ?? ""])
    }
}

// MARK: - BannerViewDelegate

extension VeonPrebidReactNativeView: PrebidMobile.BannerViewDelegate {

    func bannerViewPresentationController() -> UIViewController? {
        return getRootViewController()
    }

    func bannerView(_ bannerView: PrebidMobile.BannerView, didReceiveAdWithAdSize adSize: CGSize) {
        NSLog("VeonPrebid iOS: Prebid banner loaded successfully")
        let configId = bannerView.configID
        onAdLoaded?(["configId": configId])
    }

    func bannerView(_ bannerView: PrebidMobile.BannerView, didFailToReceiveAdWith error: Error) {
        let errorMsg = error.localizedDescription
        NSLog("VeonPrebid iOS: Prebid banner failed to load - \(errorMsg)")
        onAdFailed?(["error": errorMsg])
    }

    func bannerViewDidRecordImpression(_ bannerView: PrebidMobile.BannerView) {
        NSLog("VeonPrebid iOS: Banner recorded impression")
    }

    func bannerViewWillLeaveApplication(_ bannerView: PrebidMobile.BannerView) {
        NSLog("VeonPrebid iOS: Banner will leave application")
        let configId = bannerView.configID
        onAdClicked?(["configId": configId])
    }

    func bannerViewWillPresentModal(_ bannerView: PrebidMobile.BannerView) {
        let configId = bannerView.configID
        onAdDisplayed?(["configId": configId])
    }
}

// MARK: - RewardedAdUnitDelegate

extension VeonPrebidReactNativeView: RewardedAdUnitDelegate {

    func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad received")
        onAdLoaded?(["configId": adParameters.configId ?? ""])

        if rewardedAd.isReady {
            rewardedAd.show(from: getRootViewController())
        }
    }

    func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        let errorMsg = error?.localizedDescription ?? "Unknown error"
        NSLog("VeonPrebid iOS: Rewarded ad failed to load - \(errorMsg)")
        onAdFailed?(["error": errorMsg])
    }

    func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit, reward: PrebidReward) {
        let rewardType = reward.type ?? ""
        let rewardCount = reward.count ?? 0
        NSLog("VeonPrebid iOS: User earned reward - type: \(rewardType), count: \(rewardCount)")
    }

    func rewardedAdWillPresentAd(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad will present")
        onAdDisplayed?(["configId": adParameters.configId ?? ""])
    }

    func rewardedAdDidDismissAd(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad dismissed")
        onAdClosed?(["configId": adParameters.configId ?? ""])
    }

    func rewardedAdDidClickAd(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad clicked")
        onAdClicked?(["configId": adParameters.configId ?? ""])
    }

    func rewardedAdWillLeaveApplication(_ rewardedAd: RewardedAdUnit) {
        NSLog("VeonPrebid iOS: Rewarded ad will leave application")
        onAdClicked?(["configId": adParameters.configId ?? ""])
    }
}

// MARK: - GADBannerViewDelegate

extension VeonPrebidReactNativeView: GoogleMobileAds.BannerViewDelegate {

    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        NSLog("VeonPrebid iOS: GAM banner loaded successfully")
        onAdLoaded?(["adUnitId": bannerView.adUnitID ?? ""])
    }

    func bannerView(_ bannerView: GoogleMobileAds.BannerView,
                    didFailToReceiveAdWithError error: Error) {
        let errorMsg = error.localizedDescription
        NSLog("VeonPrebid iOS: GAM banner failed to load - \(errorMsg)")
        onAdFailed?(["error": errorMsg])

        // Fallback to Prebid ad when GAM fails
        gamBanner = nil
        loadPrebidBanner()
    }
}

// End of VeonPrebidReactNativeView+Delegates.swift
