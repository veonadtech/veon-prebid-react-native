import React, { useRef, useEffect } from "react";
import { View } from "react-native";
import { VeonPrebidAd, AdType, type AdController, type AdEventData } from "setupad-prebid-react-native";

const InterstitialExample: React.FC = () => {

  const Constant = {
    adUnitId: "ca-app-pub-3940256099942544/1033173712 asdsa", // Replace with the actual ID provided by your VEON AdTech manager
    configId: "asilbek_react_interstitial_300x250"
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

export default InterstitialExample;
