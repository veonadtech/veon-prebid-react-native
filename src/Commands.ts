import type { Int32 } from 'react-native/Libraries/Types/CodegenTypes';

export interface VeonPrebidCommands {
  readonly loadBanner: Int32;
  readonly showBanner: Int32;
  readonly hideBanner: Int32;
  readonly loadInterstitial: Int32;
  readonly showInterstitial: Int32;
  readonly hideInterstitial: Int32;
  readonly pauseAuction: Int32;
  readonly resumeAuction: Int32;
  readonly destroyAuction: Int32;
}

export const VeonPrebidCommands: VeonPrebidCommands = {
  loadBanner: 1,
  showBanner: 2,
  hideBanner: 3,
  loadInterstitial: 4,
  showInterstitial: 5,
  hideInterstitial: 6,
  pauseAuction: 7,
  resumeAuction: 8,
  destroyAuction: 9,
};
