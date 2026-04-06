import { renderHook, act } from '@testing-library/react-native';
import { useVeonPrebidAd } from '../useVeonPrebidAd';

// Spy on console.warn to verify guard warnings
const warnSpy = jest.spyOn(console, 'warn').mockImplementation(() => {});

describe('useVeonPrebidAd', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('banner commands', () => {
    it('should expose all banner control functions', () => {
      const { result } = renderHook(() =>
        useVeonPrebidAd({
          adType: 'banner',
          configId: 'test-config',
          adUnitId: '/test/unit',
          width: 320,
          height: 50,
        })
      );

      expect(result.current.loadBanner).toBeDefined();
      expect(result.current.showBanner).toBeDefined();
      expect(result.current.hideBanner).toBeDefined();
      expect(result.current.loadInterstitial).toBeDefined();
      expect(result.current.showInterstitial).toBeDefined();
      expect(result.current.hideInterstitial).toBeDefined();
      expect(result.current.pauseAuction).toBeDefined();
      expect(result.current.resumeAuction).toBeDefined();
      expect(result.current.destroyAuction).toBeDefined();
      expect(result.current.adRef).toBeDefined();
    });

    it('should warn when calling interstitial methods with banner adType', () => {
      const { result } = renderHook(() =>
        useVeonPrebidAd({
          adType: 'banner',
          configId: 'test-config',
          adUnitId: '/test/unit',
          width: 320,
          height: 50,
        })
      );

      act(() => {
        result.current.loadInterstitial();
      });

      expect(warnSpy).toHaveBeenCalledWith(
        'loadInterstitial called but ad type is not interstitial'
      );
    });
  });

  describe('interstitial commands', () => {
    it('should warn when calling banner methods with interstitial adType', () => {
      const { result } = renderHook(() =>
        useVeonPrebidAd({
          adType: 'interstitial',
          configId: 'test-config',
          adUnitId: '/test/unit',
        })
      );

      act(() => {
        result.current.loadBanner();
      });

      expect(warnSpy).toHaveBeenCalledWith(
        'loadBanner called but ad type is not banner'
      );
    });

    it('should not warn for showBanner on banner type', () => {
      const { result } = renderHook(() =>
        useVeonPrebidAd({
          adType: 'banner',
          configId: 'test-config',
          adUnitId: '/test/unit',
          width: 320,
          height: 50,
        })
      );

      act(() => {
        result.current.showBanner();
      });

      expect(warnSpy).not.toHaveBeenCalled();
    });
  });

  describe('auction lifecycle', () => {
    it('should allow pauseAuction/resumeAuction for any ad type', () => {
      const { result } = renderHook(() =>
        useVeonPrebidAd({
          adType: 'banner',
          configId: 'test-config',
          adUnitId: '/test/unit',
          width: 320,
          height: 50,
        })
      );

      // These should not warn regardless of adType
      act(() => {
        result.current.pauseAuction();
        result.current.resumeAuction();
        result.current.destroyAuction();
      });

      expect(warnSpy).not.toHaveBeenCalled();
    });
  });
});
