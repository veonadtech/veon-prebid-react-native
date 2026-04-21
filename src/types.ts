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
  onAdLoaded?: (event: { nativeEvent: { adId?: string; sdk?: string; message?: string } }) => void;
  onAdDisplayed?: (event: { nativeEvent: { adId?: string; sdk?: string; message?: string } }) => void;
  onAdFailed?: (event: { nativeEvent: { adId?: string; sdk?: string; message?: string } }) => void;
  onAdClicked?: (event: { nativeEvent: { adId?: string; sdk?: string; message?: string } }) => void;
  onAdClosed?: (event: { nativeEvent: { adId?: string; sdk?: string; message?: string } }) => void;
}

export interface AdEventData {
  configId?: string;
  adUnitId?: string;
  sdkType?: string;
  error?: string;
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
  onAdFailed?: (data: AdEventData) => void;
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
