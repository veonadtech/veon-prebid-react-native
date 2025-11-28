/**
 * Ad type enumeration
 */
export enum AdType {
  BANNER = 'banner',
  INTERSTITIAL = 'interstitial',
  REWARD_VIDEO = 'rewardVideo',
}

/**
 * SDK type enumeration
 */
export enum SdkType {
  PREBID = 'PREBID',
  GAM = 'GAM',
}

/**
 * Ad size configuration
 */
export interface AdSize {
  width: number;
  height: number;
}

/**
 * Ad event data
 */
export interface AdEventData {
  adId?: string;
  sdk?: string;
  message?: string;
}

/**
 * Prebid SDK initialization configuration
 */
export interface PrebidConfig {
  /** Prebid server host URL (e.g., "https://prebid.veonadx.com/openrtb2/auction") */
  prebidHost: string;
  /** Configuration host URL */
  configHost: string;
  /** Prebid account ID */
  accountId: string;
  /** Timeout in milliseconds for bid requests (default: 3000) */
  timeoutMillis?: number;
  /** Enable debug mode (default: false) */
  pbsDebug?: boolean;
}

/**
 * Ad configuration for banner/interstitial/rewarded ads
 */
export interface AdConfig {
  /** Ad type: banner, interstitial, or rewardVideo */
  adType: AdType;
  /** Prebid config ID */
  configId: string;
  /** Google Ad Manager ad unit ID */
  adUnitId: string;
  /** Ad width (required for banners) */
  width?: number;
  /** Ad height (required for banners) */
  height?: number;
  /** Refresh interval in seconds (30-120, for banners only) */
  refreshInterval?: number;
}

/**
 * Event listener interface for ad events
 */
export interface AdEventListener {
  /**
   * Called when ad is successfully loaded
   * @param data - Event data containing ad ID and SDK type
   */
  onAdLoaded?: (data: AdEventData) => void;

  /**
   * Called when ad is displayed on screen
   * @param data - Event data containing ad ID and SDK type
   */
  onAdDisplayed?: (data: AdEventData) => void;

  /**
   * Called when ad fails to load or display
   * @param error - Error message
   */
  onAdFailed?: (error: string) => void;

  /**
   * Called when user clicks on the ad
   * @param data - Event data containing ad ID and SDK type
   */
  onAdClicked?: (data: AdEventData) => void;

  /**
   * Called when ad is closed
   * @param data - Event data containing ad ID and SDK type
   */
  onAdClosed?: (data: AdEventData) => void;
}

/**
 * Ad controller interface for programmatic ad control
 */
export interface AdController {
  /**
   * Load banner ad
   */
  loadBanner: () => void;

  /**
   * Show loaded banner ad
   */
  showBanner: () => void;

  /**
   * Hide banner ad
   */
  hideBanner: () => void;

  /**
   * Load interstitial ad
   */
  loadInterstitial: () => void;

  /**
   * Show loaded interstitial ad
   */
  showInterstitial: () => void;

  /**
   * Hide interstitial ad
   */
  hideInterstitial: () => void;

  /**
   * Pause ad auction (for banners)
   */
  pauseAuction: () => void;

  /**
   * Resume ad auction (for banners)
   */
  resumeAuction: () => void;

  /**
   * Destroy ad and free resources
   */
  destroyAuction: () => void;
}

/**
 * Props for VeonPrebidAd component
 */
export interface VeonPrebidAdProps extends AdConfig, AdEventListener {
  /** Optional style for the ad container */
  style?: any;
}
