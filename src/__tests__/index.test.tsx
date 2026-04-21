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
    // Reset singleton state between tests
    (VeonPrebidSDK as any).instance = undefined;
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

    it('should not call native initialize twice if initialization is in progress', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      mockInitialize.mockImplementation(
        () =>
          new Promise((resolve) =>
            setTimeout(() => resolve('successfully'), 100)
          )
      );

      const sdk = VeonPrebidSDK.getInstance();
      const config = {
        prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
        configHost: 'https://config.veonadx.com',
        accountId: 'test-account',
      };

      const promise1 = sdk.initialize(config);
      const promise2 = sdk.initialize(config);

      // Native module should only be called once
      expect(mockInitialize).toHaveBeenCalledTimes(1);

      // Both should resolve with same result
      const [result1, result2] = await Promise.all([promise1, promise2]);
      expect(result1).toBe('successfully');
      expect(result2).toBe('successfully');
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

    it('should reject with INIT_TIMEOUT when native never settles', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      // Native call hangs forever.
      mockInitialize.mockImplementation(() => new Promise(() => {}));

      const sdk = VeonPrebidSDK.getInstance();

      await expect(
        sdk.initialize({
          prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
          configHost: 'https://config.veonadx.com',
          accountId: 'test-account',
          initTimeoutMillis: 50,
        })
      ).rejects.toMatchObject({
        code: 'INIT_TIMEOUT',
        message: expect.stringContaining('50ms'),
      });

      expect(sdk.isSDKInitialized()).toBe(false);
    });

    it('should allow retry after a timeout (cache is cleared)', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;

      // First attempt hangs.
      mockInitialize.mockImplementationOnce(() => new Promise(() => {}));
      const sdk = VeonPrebidSDK.getInstance();
      const config = {
        prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
        configHost: 'https://config.veonadx.com',
        accountId: 'test-account',
        initTimeoutMillis: 50,
      };

      await expect(sdk.initialize(config)).rejects.toMatchObject({
        code: 'INIT_TIMEOUT',
      });

      // Second attempt succeeds — proves the cache was cleared.
      mockInitialize.mockResolvedValueOnce('successfully');
      await expect(sdk.initialize(config)).resolves.toBe('successfully');
      expect(mockInitialize).toHaveBeenCalledTimes(2);
      expect(sdk.isSDKInitialized()).toBe(true);
    });

    it('should use the default initTimeoutMillis (15000ms) when unspecified', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      // Resolve immediately so we never actually wait the default timeout.
      mockInitialize.mockResolvedValue('successfully');

      jest.useFakeTimers();
      try {
        const sdk = VeonPrebidSDK.getInstance();
        const p = sdk.initialize({
          prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
          configHost: 'https://config.veonadx.com',
          accountId: 'test-account',
        });
        // Fast-forward past the default 15s — timer must have been cleared
        // on success, so this should not produce any unhandled rejection.
        jest.advanceTimersByTime(20000);
        await expect(p).resolves.toBe('successfully');
      } finally {
        jest.useRealTimers();
      }
    });

    it('should propagate native rejection unchanged (not wrapped in INIT_TIMEOUT)', async () => {
      const mockInitialize = NativeModules.VeonPrebidReactNativeModule
        .initializeSDK as jest.Mock;
      const nativeError = Object.assign(new Error('INIT_FAILED native'), {
        code: 'INIT_FAILED',
      });
      mockInitialize.mockRejectedValue(nativeError);

      const sdk = VeonPrebidSDK.getInstance();

      await expect(
        sdk.initialize({
          prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
          configHost: 'https://config.veonadx.com',
          accountId: 'test-account',
          initTimeoutMillis: 5000,
        })
      ).rejects.toMatchObject({ code: 'INIT_FAILED' });

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
    expect(AdType.REWARD_VIDEO).toBe('rewardvideo');
  });
});
