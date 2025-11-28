export type AdType = 'banner' | 'interstitial' | 'rewardvideo';

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
