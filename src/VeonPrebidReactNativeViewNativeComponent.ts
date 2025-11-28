import type { ViewProps } from 'react-native';
import type {
  Int32,
  DirectEventHandler,
} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

/**
 * Event payload for ad events
 */
export interface AdEventPayload {
  adId?: string;
  sdk?: string;
  message?: string;
}

/**
 * Native Props for VeonPrebidReactNativeView
 */
export interface NativeProps extends ViewProps {
  /** Ad type: banner, interstitial, or rewardVideo */
  adType?: string;

  /** Prebid config ID */
  configId?: string;

  /** Google Ad Manager ad unit ID */
  adUnitId?: string;

  /** Ad width (required for banners) */
  width?: Int32;

  /** Ad height (required for banners) */
  height?: Int32;

  /** Refresh interval in seconds (30-120, for banners only) */
  refreshInterval?: Int32;

  // Event handlers
  onAdLoaded?: DirectEventHandler<AdEventPayload>;
  onAdDisplayed?: DirectEventHandler<AdEventPayload>;
  onAdFailed?: DirectEventHandler<AdEventPayload>;
  onAdClicked?: DirectEventHandler<AdEventPayload>;
  onAdClosed?: DirectEventHandler<AdEventPayload>;
}

/**
 * Native component for Veon Prebid ads
 */
export default codegenNativeComponent<NativeProps>('VeonPrebidReactNativeView');
