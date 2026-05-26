import { useEffect, useRef, useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  Button,
  Alert,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import {
  VeonPrebidAd,
  VeonPrebidSDK,
  AdType,
  type AdController,
  type AdEventData,
  type RewardData,
} from 'setupad-prebid-react-native';

/**
 * Example App demonstrating Veon Prebid SDK usage
 */
export default function App() {
  const [sdkInitialized, setSdkInitialized] = useState(false);
  const [sdkVersion, setSdkVersion] = useState<string>('');

  // Banner ad refs
  const bannerAdRef = useRef<AdController>(null);

  // Interstitial ad refs
  const interstitialAdRef = useRef<AdController>(null);

  // Rewarded ad refs
  const rewardedAdRef = useRef<AdController>(null);

  /**
   * Initialize Prebid SDK on mount
   */
  useEffect(() => {
    const initializeSDK = async () => {
      try {
        console.log('Initializing Veon Prebid SDK...');

        await VeonPrebidSDK.getInstance().initialize({
          prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
          configHost: 'https://dcdn.veonadx.com/sdk/uz.beeline.odp/config.json',
          accountId: 'uz.beeline.odp', // Replace with your account ID
          timeoutMillis: 3000,
          pbsDebug: __DEV__,
        });

        setSdkInitialized(true);
        Alert.alert('Success', 'Prebid SDK initialized successfully');

        // Get SDK version
        const version = await VeonPrebidSDK.getInstance().getSDKVersion();
        setSdkVersion(version);
        console.log('SDK Version:', version);
      } catch (error) {
        console.error('Failed to initialize SDK:', error);
        Alert.alert('Error', 'Failed to initialize Prebid SDK');
      }
    };

    initializeSDK();
  }, []);

  /**
   * Banner Ad Event Handlers
   */
  const handleBannerLoaded = (data: AdEventData) => {
    console.log('Banner loaded:', data);
    Alert.alert('Banner', `Ad loaded from ${data.sdkType}`);
  };

  const handleBannerFailed = (data: AdEventData) => {
    console.error('Banner failed:', data.error, `SDK: ${data.sdkType}`);
    Alert.alert('Banner Error', `${data.error}\n\nSDK: ${data.sdkType}`);
  };

  const handleBannerClicked = (data: AdEventData) => {
    console.log('Banner clicked:', data);
  };

  /**
   * Interstitial Ad Event Handlers
   */
  const handleInterstitialLoaded = (data: AdEventData) => {
    console.log('Interstitial loaded:', data);
    Alert.alert('Interstitial', `Ad loaded from ${data.sdkType}`);
  };

  const handleInterstitialFailed = (data: AdEventData) => {
    console.error('Interstitial failed:', data.error, `SDK: ${data.sdkType}`);
    Alert.alert('Interstitial Error', `${data.error}\n\nSDK: ${data.sdkType}`);
  };

  const handleInterstitialClosed = (data: AdEventData) => {
    console.log('Interstitial closed:', data);
    Alert.alert('Interstitial', 'Ad closed');
  };

  /**
   * Rewarded Ad Event Handlers
   */
  const handleRewardedLoaded = (data: AdEventData) => {
    console.log('Rewarded loaded:', data);
    Alert.alert(
      'Rewarded',
      `Ad loaded from ${data.sdkType}. Tap "Show Rewarded" to play.`
    );
  };

  const handleRewardedFailed = (data: AdEventData) => {
    console.error('Rewarded failed:', data.error, `SDK: ${data.sdkType}`);
    Alert.alert('Rewarded Error', `${data.error}\n\nSDK: ${data.sdkType}`);
  };

  const handleRewardedClosed = (data: AdEventData) => {
    console.log('Rewarded closed:', data);
  };

  const handleRewardEarned = (data: RewardData) => {
    console.log('Reward earned:', data);
    Alert.alert(
      'Reward Earned!',
      `Type: ${data.rewardType || '(none)'}\nAmount: ${data.rewardAmount ?? 0}`
    );
  };

  /**
   * Banner Ad Controls
   */
  const loadBanner = () => {
    console.log('Loading banner...');
    bannerAdRef.current?.loadBanner();
  };

  const showBanner = () => {
    console.log('Showing banner...');
    bannerAdRef.current?.showBanner();
  };

  const hideBanner = () => {
    console.log('Hiding banner...');
    bannerAdRef.current?.hideBanner();
  };

  /**
   * Interstitial Ad Controls
   */
  const loadInterstitial = () => {
    console.log('Loading interstitial...');
    interstitialAdRef.current?.loadInterstitial();
  };

  const showInterstitial = () => {
    console.log('Showing interstitial...');
    interstitialAdRef.current?.showInterstitial();
  };

  /**
   * Rewarded Ad Controls
   */
  const loadRewarded = () => {
    console.log('Loading rewarded...');
    rewardedAdRef.current?.loadRewarded();
  };

  const showRewarded = () => {
    console.log('Showing rewarded...');
    rewardedAdRef.current?.showRewarded();
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" />
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.contentContainer}
      >
        <Text style={styles.title}>Veon Prebid React Native</Text>

        {sdkVersion && (
          <Text style={styles.subtitle}>SDK Version: {sdkVersion}</Text>
        )}

        {!sdkInitialized && (
          <View style={styles.loadingContainer}>
            <Text>Initializing Prebid SDK...</Text>
          </View>
        )}

        {sdkInitialized && (
          <>
            {/* Banner Ad Section */}
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Banner Ad (300x250)</Text>

              <View style={styles.adContainer}>
                <VeonPrebidAd
                  ref={bannerAdRef}
                  adType={AdType.BANNER}
                  configId="beeline_uz_android_manual_veon_test_320x50" // Replace with your config ID
                  adUnitId="ca-app-pub-3940256099942544/9214589741" // Replace with your ad unit ID
                  width={320}
                  height={50}
                  refreshInterval={30}
                  onAdLoaded={handleBannerLoaded}
                  onAdFailed={handleBannerFailed}
                  onAdClicked={handleBannerClicked}
                  style={styles.bannerAd}
                />
              </View>

              <View style={styles.buttonGroup}>
                <Button title="Load Banner" onPress={loadBanner} />
                <View style={styles.buttonSpacer} />
                <Button title="Show Banner" onPress={showBanner} />
                <View style={styles.buttonSpacer} />
                <Button title="Hide Banner" onPress={hideBanner} />
              </View>
            </View>

            {/* Interstitial Ad Section */}
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Interstitial Ad</Text>

              {/* Interstitial has minimal footprint */}
              <VeonPrebidAd
                ref={interstitialAdRef}
                adType={AdType.INTERSTITIAL}
                configId="beeline_uz_android_universal_interstitial" // Replace with your config ID
                adUnitId="ca-app-pub-3940256099942544/1033173712" // Replace with your ad unit ID
                onAdLoaded={handleInterstitialLoaded}
                onAdFailed={handleInterstitialFailed}
                onAdClosed={handleInterstitialClosed}
              />

              <View style={styles.buttonGroup}>
                <Button title="Load Interstitial" onPress={loadInterstitial} />
                <View style={styles.buttonSpacer} />
                <Button title="Show Interstitial" onPress={showInterstitial} />
              </View>
            </View>

            {/* Rewarded Video Ad Section */}
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Rewarded Video Ad</Text>

              <VeonPrebidAd
                ref={rewardedAdRef}
                adType={AdType.REWARD_VIDEO}
                configId="prebid-demo-video-rewarded-endcard-time-close-button" // Replace with your config ID
                adUnitId="ca-app-pub-3940256099942544/5224354917" // Replace with your ad unit ID
                onAdLoaded={handleRewardedLoaded}
                onAdFailed={handleRewardedFailed}
                onAdClosed={handleRewardedClosed}
                onAdRewardEarned={handleRewardEarned}
              />

              <View style={styles.buttonGroup}>
                <Button title="Load Rewarded" onPress={loadRewarded} />
                <View style={styles.buttonSpacer} />
                <Button title="Show Rewarded" onPress={showRewarded} />
              </View>
            </View>
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  container: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
    color: '#333',
  },
  subtitle: {
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 20,
    color: '#666',
  },
  loadingContainer: {
    padding: 20,
    alignItems: 'center',
  },
  section: {
    marginBottom: 30,
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
  },
  adContainer: {
    alignItems: 'center',
    marginBottom: 15,
    backgroundColor: '#f9f9f9',
    padding: 10,
    borderRadius: 8,
  },
  bannerAd: {
    backgroundColor: '#e0e0e0',
  },
  buttonGroup: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  buttonSpacer: {
    width: 10,
  },
  instructionsTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 10,
    color: '#333',
  },
  instructions: {
    fontSize: 14,
    lineHeight: 22,
    color: '#666',
  },
});
