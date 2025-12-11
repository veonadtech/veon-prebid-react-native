import { NativeModules } from 'react-native';
import VeonPrebidSDK from '../VeonPrebidModule';
import { AdType } from '../types';

// Mock NativeModules
jest.mock('react-native', () => ({
  NativeModules: {
    VeonPrebidReactNativeModule: {
      initializeSDK: jest.fn(),
      getSDKVersion: jest.fn(),
    },
  },
  NativeEventEmitter: jest.fn(() => ({
    addListener: jest.fn(),
    removeAllListeners: jest.fn(),
  })),
  Platform: {
    OS: 'ios',
  },
  UIManager: {
    getViewManagerConfig: jest.fn(() => ({
      Commands: {
        loadBanner: 0,
        showBanner: 1,
        hideBanner: 2,
        loadInterstitial: 3,
        showInterstitial: 4,
        hideInterstitial: 5,
        pauseAuction: 6,
        resumeAuction: 7,
        destroyAuction: 8,
      },
    })),
    dispatchViewManagerCommand: jest.fn(),
  },
  findNodeHandle: jest.fn(() => 1),
  requireNativeComponent: jest.fn(() => 'VeonPrebidReactNativeView'),
}));

describe('VeonPrebidSDK', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('initialize', () => {
    it('should initialize SDK with correct parameters', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      mockInitialize.mockResolvedValue('successfully');

      const sdk = VeonPrebidSDK.getInstance();
      const result = await sdk.initialize({
        prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
        configHost: 'https://config.veonadx.com',
        accountId: 'test-account',
        timeoutMillis: 3000,
        pbsDebug: true,
      });

      expect(mockInitialize).toHaveBeenCalledWith(
        'https://prebid.veonadx.com/openrtb2/auction',
        'https://config.veonadx.com',
        'test-account',
        3000,
        true
      );
      expect(result).toBe('successfully');
      expect(sdk.isSDKInitialized()).toBe(true);
    });

    it('should use default values for optional parameters', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      mockInitialize.mockResolvedValue('successfully');

      const sdk = VeonPrebidSDK.getInstance();
      await sdk.initialize({
        prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
        configHost: 'https://config.veonadx.com',
        accountId: 'test-account',
      });

      expect(mockInitialize).toHaveBeenCalledWith(
        'https://prebid.veonadx.com/openrtb2/auction',
        'https://config.veonadx.com',
        'test-account',
        3000, // default timeoutMillis
        false // default pbsDebug
      );
    });

    it('should return existing promise if initialization is in progress', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      mockInitialize.mockImplementation(
        () =>
          new Promise((resolve) =>
            setTimeout(() => resolve('successfully'), 100)
          )
      );

      const sdk = VeonPrebidSDK.getInstance();
      const promise1 = sdk.initialize({
        prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
        configHost: 'https://config.veonadx.com',
        accountId: 'test-account',
      });
      const promise2 = sdk.initialize({
        prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
        configHost: 'https://config.veonadx.com',
        accountId: 'test-account',
      });

      expect(promise1).toBe(promise2);
      expect(mockInitialize).toHaveBeenCalledTimes(1);

      await promise1;
    });

    it('should handle initialization errors', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      mockInitialize.mockRejectedValue(new Error('Initialization failed'));

      const sdk = VeonPrebidSDK.getInstance();

      await expect(
        sdk.initialize({
          prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
          configHost: 'https://config.veonadx.com',
          accountId: 'test-account',
        })
      ).rejects.toThrow('Initialization failed');

      expect(sdk.isSDKInitialized()).toBe(false);
    });
  });

  describe('getSDKVersion', () => {
    it('should return SDK version', async () => {
      const mockGetVersion = NativeModules.VeonPrebidReactNativeModule
        .getSDKVersion as jest.Mock;
      mockGetVersion.mockResolvedValue('0.1.0');

      const sdk = VeonPrebidSDK.getInstance();
      const version = await sdk.getSDKVersion();

      expect(version).toBe('0.1.0');
      expect(mockGetVersion).toHaveBeenCalled();
    });

    it('should handle version fetch errors', async () => {
      const mockGetVersion = NativeModules.VeonPrebidReactNativeModule
        .getSDKVersion as jest.Mock;
      mockGetVersion.mockRejectedValue(new Error('Version fetch failed'));

      const sdk = VeonPrebidSDK.getInstance();

      await expect(sdk.getSDKVersion()).rejects.toThrow('Version fetch failed');
    });
  });

  describe('singleton pattern', () => {
    it('should return same instance', () => {
      const instance1 = VeonPrebidSDK.getInstance();
      const instance2 = VeonPrebidSDK.getInstance();

      expect(instance1).toBe(instance2);
    });
  });
});

describe('AdType enum', () => {
  it('should have correct values', () => {
    expect(AdType.BANNER).toBe('banner');
    expect(AdType.INTERSTITIAL).toBe('interstitial');
    expect(AdType.REWARD_VIDEO).toBe('rewardVideo');
  });
});
