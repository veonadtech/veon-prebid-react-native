import type { HostComponent, ViewProps } from 'react-native';
import type {
  Int32,
  DirectEventHandler,
} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';

/**
 * Event payload for ad events
 */
export interface AdEventPayload {
  adId?: string;
  sdk?: string;
  message?: string;
  error?: string;
  sdkType?: string;
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

type ComponentType = HostComponent<NativeProps>;

export interface NativeCommands {
  loadBanner: (viewRef: React.ElementRef<ComponentType>) => void;
  showBanner: (viewRef: React.ElementRef<ComponentType>) => void;
  hideBanner: (viewRef: React.ElementRef<ComponentType>) => void;
  loadInterstitial: (viewRef: React.ElementRef<ComponentType>) => void;
  showInterstitial: (viewRef: React.ElementRef<ComponentType>) => void;
  hideInterstitial: (viewRef: React.ElementRef<ComponentType>) => void;
  pauseAuction: (viewRef: React.ElementRef<ComponentType>) => void;
  resumeAuction: (viewRef: React.ElementRef<ComponentType>) => void;
  destroyAuction: (viewRef: React.ElementRef<ComponentType>) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    'loadBanner',
    'showBanner',
    'hideBanner',
    'loadInterstitial',
    'showInterstitial',
    'hideInterstitial',
    'pauseAuction',
    'resumeAuction',
    'destroyAuction',
  ],
});

/**
 * Native component for Veon Prebid ads
 */
export default codegenNativeComponent<NativeProps>('VeonPrebidReactNativeView');
