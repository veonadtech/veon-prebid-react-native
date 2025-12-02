export const AdType = {
  BANNER: 'banner' as const,
  INTERSTITIAL: 'interstitial' as const,
  REWARD_VIDEO: 'rewardvideo' as const,
};

export type AdType = typeof AdType[keyof typeof AdType];

export interface VeonPrebidViewProps {
  adType: AdType;
  configId: string;
  adUnitId: string;
  width?: number;
  height?: number;
  refreshInterval?: number;
  style?: any;
  onAdLoaded?: (event: { nativeEvent: { configId?: string; adUnitId?: string } }) => void;
  onAdDisplayed?: (event: { nativeEvent: { configId?: string; adUnitId?: string } }) => void;
  onAdFailed?: (event: { nativeEvent: { error: string } }) => void;
  onAdClicked?: (event: { nativeEvent: { configId?: string; adUnitId?: string } }) => void;
  onAdClosed?: (event: { nativeEvent: { configId?: string; adUnitId?: string } }) => void;
}

export interface AdEventData {
  configId?: string;
  adUnitId?: string;
  sdk?: string;
}

export interface AdController {
  loadBanner: () => void;
  showBanner: () => void;
  hideBanner: () => void;
  loadInterstitial: () => void;
  showInterstitial: () => void;
  hideInterstitial: () => void;
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
  onAdFailed?: (error: string) => void;
  onAdClicked?: (data: AdEventData) => void;
  onAdClosed?: (data: AdEventData) => void;
}

export interface PrebidConfig {
  prebidHost: string;
  configHost: string;
  accountId: string;
  timeoutMillis?: number;
  pbsDebug?: boolean;
}
