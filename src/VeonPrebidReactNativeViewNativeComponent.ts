import type { ViewProps } from 'react-native';
import { codegenNativeComponent } from 'react-native';

/**
 * Event payload for ad events
 */
export interface AdEventPayload {
  adId?: string;
  sdk?: string;
  message?: string;
}

/**
 * Event handler type for direct events
 */
type DirectEventHandler<T> = (event: { nativeEvent: T }) => void;

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
  width?: number;

  /** Ad height (required for banners) */
  height?: number;

  /** Refresh interval in seconds (30-120, for banners only) */
  refreshInterval?: number;

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
