export enum AdType {
  BANNER = 'banner',
  INTERSTITIAL = 'interstitial',
  REWARD_VIDEO = 'rewardvideo',
}

export interface PrebidConfig {
  prebidHost: string;
  configHost: string;
  accountId: string;
  timeoutMillis?: number;
  pbsDebug?: boolean;
}

export interface AdEventData {
  configId?: string;
  adUnitId?: string;
  error?: string;
  sdkType?: string;
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

export interface VeonPrebidViewProps {
  adType: AdType | string;
  configId: string;
  adUnitId: string;
  width?: number;
  height?: number;
  refreshInterval?: number;
  style?: any;
  onAdLoaded?: (event: { nativeEvent: AdEventData }) => void;
  onAdDisplayed?: (event: { nativeEvent: AdEventData }) => void;
  onAdFailed?: (event: { nativeEvent: AdEventData }) => void;
  onAdClicked?: (event: { nativeEvent: AdEventData }) => void;
  onAdClosed?: (event: { nativeEvent: AdEventData }) => void;
}
