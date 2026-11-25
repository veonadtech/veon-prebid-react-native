import UIKit
import PrebidMobile
import VeonPrebidMultiAdLoader
import VeonPrebidRemoteConfig

// MARK: - Multi Ad Loader delegates

extension VeonPrebidReactNativeView: VeonMultiBannerAdLoaderDelegate {

    func bannerLoader(_ loader: VeonMultiBannerAdLoader, didLoad view: UIView, from sdk: SdkType) {
        guard bannerLoader === loader else { return }
        let wasVisible = loadedBannerView?.superview != nil
        loadedBannerView?.removeFromSuperview()
        retiringBannerLoader?.delegate = nil
        retiringBannerLoader?.destroy()
        retiringBannerLoader = nil
        loadedBannerView = view
        if auctionPaused { (view as? PrebidMobile.BannerView)?.stopRefresh() }
        if wasVisible { showBanner() }
        NSLog("VeonPrebid iOS: Banner loaded from \(sdk.rawValue)")
        onAdLoaded?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func bannerLoader(_ loader: VeonMultiBannerAdLoader, didFailToLoad sdk: SdkType, error: Error?) {
        guard bannerLoader === loader else { return }
        let message = error?.localizedDescription ?? "Unknown error"
        NSLog("VeonPrebid iOS: Banner failed from \(sdk.rawValue): \(message)")
        onAdFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "error": message,
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func bannerLoaderDidFailAll(_ loader: VeonMultiBannerAdLoader) {
        guard bannerLoader === loader, let retiringBannerLoader else { return }
        loader.delegate = nil
        loader.destroy()
        bannerLoader = retiringBannerLoader
        self.retiringBannerLoader = nil
    }

    func bannerLoader(_ loader: VeonMultiBannerAdLoader, didRecordImpressionFrom sdk: SdkType) {
        guard bannerLoader === loader else { return }
        onAdDisplayed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func bannerLoader(_ loader: VeonMultiBannerAdLoader, didRecordClickFrom sdk: SdkType) {
        guard bannerLoader === loader else { return }
        emitBannerClick(from: sdk)
    }

    func bannerLoader(_ loader: VeonMultiBannerAdLoader, willLeaveApplication sdk: SdkType) {
        guard bannerLoader === loader else { return }
        emitBannerClick(from: sdk)
    }

    func bannerLoader(_ loader: VeonMultiBannerAdLoader, didDismissScreenFrom sdk: SdkType) {
        guard bannerLoader === loader else { return }
        onAdClosed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    private func emitBannerClick(from sdk: SdkType) {
        onAdClicked?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }
}

extension VeonPrebidReactNativeView: VeonMultiInterstitialAdLoaderDelegate {

    func interstitialLoader(_ loader: VeonMultiInterstitialAdLoader, didLoadFrom sdk: SdkType) {
        guard interstitialLoader === loader else { return }
        NSLog("VeonPrebid iOS: Interstitial loaded from \(sdk.rawValue)")
        onAdLoaded?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func interstitialLoader(_ loader: VeonMultiInterstitialAdLoader, didFailToLoad sdk: SdkType, error: Error?) {
        guard interstitialLoader === loader else { return }
        let message = error?.localizedDescription ?? "Unknown error"
        NSLog("VeonPrebid iOS: Interstitial failed from \(sdk.rawValue): \(message)")
        onAdFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "error": message,
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func interstitialLoader(_ loader: VeonMultiInterstitialAdLoader, willPresent sdk: SdkType) {
        guard interstitialLoader === loader else { return }
        onAdDisplayed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func interstitialLoader(_ loader: VeonMultiInterstitialAdLoader, didDismiss sdk: SdkType) {
        guard interstitialLoader === loader else { return }
        onAdClosed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func interstitialLoader(_ loader: VeonMultiInterstitialAdLoader, didClick sdk: SdkType) {
        guard interstitialLoader === loader else { return }
        onAdClicked?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "sdkType": sdk.rawValue.lowercased()
        ])
    }

    func interstitialLoader(_ loader: VeonMultiInterstitialAdLoader, didFailToShow sdk: SdkType, error: Error?) {
        guard interstitialLoader === loader else { return }
        onAdFailed?([
            "configId": adParameters.configId ?? "",
            "adUnitId": adParameters.adUnitId ?? "",
            "error": error?.localizedDescription ?? "Failed to show interstitial",
            "sdkType": sdk.rawValue.lowercased()
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

// End of VeonPrebidReactNativeView+Delegates.swift
