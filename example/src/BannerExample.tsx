import React, { useRef, useEffect } from "react";
import { View } from "react-native";
import { VeonPrebidAd, AdType, type AdController, type AdEventData, type RewardData } from "setupad-prebid-react-native";

const InterstitialExample: React.FC = () => {

  const Constant = {
    adUnitId: "YOUR_GAM_AD_UNIT_ID", // Replace with the actual ID provided by your VEON AdTech manager
    configId: "YOUR_PREBID_CONFIG_ID"
  };

  const adRef = useRef<AdController>(null);

  useEffect(() => {
    // Load interstitial when component mounts
    const timer = setTimeout(() => {
      adRef.current?.loadInterstitial();
    }, 100);

    return () => clearTimeout(timer);
  }, []);

  const handleAdLoaded = () => {
    console.log("Ad loaded successfully.");
    adRef.current?.showInterstitial();
  };

  const handleAdFailed = (data: AdEventData) => {
    console.log(`Interstitial view did fail to receive ad with error: ${data.error}`);
  };

  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <VeonPrebidAd
        ref={adRef}
        adType={AdType.INTERSTITIAL}
        configId={Constant.configId}
        adUnitId={Constant.adUnitId}
        onAdLoaded={handleAdLoaded}
        onAdFailed={handleAdFailed}
      />
    </View>
  );
};

export const RewardedExample: React.FC = () => {

  const Constant = {
    adUnitId: "YOUR_GAM_REWARDED_AD_UNIT_ID", // Replace with the actual ID provided by your VEON AdTech manager
    configId: "YOUR_PREBID_REWARDED_CONFIG_ID"
  };

  const adRef = useRef<AdController>(null);

  useEffect(() => {
    // Load rewarded ad when component mounts
    const timer = setTimeout(() => {
      adRef.current?.loadRewarded();
    }, 100);

    return () => clearTimeout(timer);
  }, []);

  const handleAdLoaded = () => {
    console.log("Rewarded ad loaded successfully.");
    adRef.current?.showRewarded();
  };

  const handleAdFailed = (data: AdEventData) => {
    console.log(`Rewarded view did fail to receive ad with error: ${data.error}`);
  };

  const handleRewardEarned = (data: RewardData) => {
    console.log(`User earned reward — type: ${data.rewardType}, amount: ${data.rewardAmount}`);
  };

  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <VeonPrebidAd
        ref={adRef}
        adType={AdType.REWARD_VIDEO}
        configId={Constant.configId}
        adUnitId={Constant.adUnitId}
        onAdLoaded={handleAdLoaded}
        onAdFailed={handleAdFailed}
        onAdRewardEarned={handleRewardEarned}
      />
    </View>
  );
};

export default InterstitialExample;
