import { useEffect, useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  SafeAreaView,
  StatusBar,
  ActivityIndicator,
} from 'react-native';
import { VeonPrebidSDK } from 'setupad-prebid-react-native';
import InterstitialExample from './Interstitial';

export default function App() {
  const [sdkInitialized, setSdkInitialized] = useState(false);

  /**
   * Initialize Prebid SDK on mount
   */
  useEffect(() => {
    const initializeSDK = async () => {
      try {
        console.log('Initializing Veon Prebid SDK...');

        await VeonPrebidSDK.getInstance().initialize({
          prebidHost: 'https://ssp.veonadx.com/bid/prebid',
          configHost: 'https://dcdn.veonadx.com/sdk/uz.beeline.odp/config.json',
          accountId: 'uz.jahonov.prebid.reactnative.demo', // Replace with your account ID
          timeoutMillis: 3000,
          pbsDebug: __DEV__,
        });

        setSdkInitialized(true);
        console.log('SDK initialized successfully');
      } catch (error) {
        console.error('Failed to initialize SDK:', error);
      }
    };

    initializeSDK();
  }, []);

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" />
      {sdkInitialized ? (
        <InterstitialExample />
      ) : (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#333" />
          <Text style={styles.loadingText}>Initializing Prebid SDK...</Text>
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingText: {
    marginTop: 12,
    fontSize: 14,
    color: '#666',
  },
});
