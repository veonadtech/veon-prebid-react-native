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

  const handleBannerFailed = (error: string) => {
    console.error('Banner failed:', error);
    Alert.alert('Banner Error', error);
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

  const handleInterstitialFailed = (error: string) => {
    console.error('Interstitial failed:', error);
    Alert.alert('Interstitial Error', error);
  };

  const handleInterstitialClosed = (data: AdEventData) => {
    console.log('Interstitial closed:', data);
    Alert.alert('Interstitial', 'Ad closed');
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
                  configId="beeline_uz_android_universal_300x250" // Replace with your config ID
                  adUnitId="ca-app-pub-3940256099942544/9214589741" // Replace with your ad unit ID
                  width={300}
                  height={250}
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
                configId="beeline_uz_android_wheel_interstitial_test" // Replace with your config ID
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
