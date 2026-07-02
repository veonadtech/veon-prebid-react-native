export const AdType = {
  BANNER: 'banner' as const,
  INTERSTITIAL: 'interstitial' as const,
  REWARD_VIDEO: 'rewardvideo' as const,
};

export type AdType = (typeof AdType)[keyof typeof AdType];

export interface VeonPrebidViewProps {
  adType: AdType;
  configId: string;
  adUnitId: string;
  width?: number;
  height?: number;
  refreshInterval?: number;
  style?: any;
  onAdLoaded?: (event: {
    nativeEvent: { adId?: string; sdk?: string; message?: string };
  }) => void;
  onAdDisplayed?: (event: {
    nativeEvent: { adId?: string; sdk?: string; message?: string };
  }) => void;
  onAdFailed?: (event: {
    nativeEvent: { adId?: string; sdk?: string; message?: string };
  }) => void;
  onAdClicked?: (event: {
    nativeEvent: { adId?: string; sdk?: string; message?: string };
  }) => void;
  onAdClosed?: (event: {
    nativeEvent: { adId?: string; sdk?: string; message?: string };
  }) => void;
  onAdRewardEarned?: (event: { nativeEvent: RewardData }) => void;
}

export interface AdEventData {
  configId?: string;
  adUnitId?: string;
  sdkType?: string;
  error?: string;
}

export interface RewardData {
  configId?: string;
  adUnitId?: string;
  sdkType?: string;
  rewardType?: string;
  rewardAmount?: number;
}

export interface AdController {
  loadBanner: () => void;
  showBanner: () => void;
  hideBanner: () => void;
  loadInterstitial: () => void;
  showInterstitial: () => void;
  hideInterstitial: () => void;
  loadRewarded: () => void;
  showRewarded: () => void;
  pauseAuction: () => void;
  resumeAuction: () => void;
  destroyAuction: () => void;
}

export interface VeonPrebidAdProps {
  adType: AdType;
  configId: string;
  adUnitId: string;
  width?: number;
  height?: number;
  refreshInterval?: number;
  style?: any;
  onAdLoaded?: (data: AdEventData) => void;
  onAdDisplayed?: (data: AdEventData) => void;
  onAdFailed?: (data: AdEventData) => void;
  onAdClicked?: (data: AdEventData) => void;
  onAdClosed?: (data: AdEventData) => void;
  onAdRewardEarned?: (data: RewardData) => void;
}

export interface PrebidConfig {
  prebidHost: string;
  configHost: string;
  accountId: string;
  /**
   * Bid-request timeout in milliseconds (applied inside the Prebid auction).
   * Default: 3000.
   */
  timeoutMillis?: number;
  /**
   * Max wall-clock time (ms) the `initialize()` promise may stay pending
   * before it rejects with `INIT_TIMEOUT`. Separate from `timeoutMillis`
   * (which governs bid requests, not init). Default: 15000.
   */
  initTimeoutMillis?: number;
  pbsDebug?: boolean;
}
