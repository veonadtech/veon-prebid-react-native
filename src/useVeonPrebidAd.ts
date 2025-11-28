import { useRef, useCallback, useEffect } from 'react';
import type { AdController, AdConfig, AdEventListener } from './types';

/**
 * Hook for managing Veon Prebid ads programmatically
 *
 * @param config - Ad configuration
 * @param eventListener - Optional event listener
 * @returns AdController reference and helper functions
 *
 * @example
 * ```typescript
 * function MyComponent() {
 *   const { adRef, loadBanner, showBanner } = useVeonPrebidAd(
 *     {
 *       adType: AdType.BANNER,
 *       configId: 'YOUR_CONFIG_ID',
 *       adUnitId: 'YOUR_AD_UNIT_ID',
 *       width: 300,
 *       height: 250,
 *     },
 *     {
 *       onAdLoaded: (data) => console.log('Ad loaded', data),
 *       onAdFailed: (error) => console.error('Ad failed', error),
 *     }
 *   );
 *
 *   useEffect(() => {
 *     loadBanner();
 *   }, []);
 *
 *   return (
 *     <VeonPrebidAd
 *       ref={adRef}
 *       {...config}
 *       {...eventListener}
 *     />
 *   );
 * }
 * ```
 */
export function useVeonPrebidAd(
  config: AdConfig,
  _eventListener?: AdEventListener
) {
  const adRef = useRef<AdController>(null);

  /**
   * Load banner ad
   */
  const loadBanner = useCallback(() => {
    if (config.adType !== 'banner') {
      console.warn('loadBanner called but ad type is not banner');
      return;
    }
    adRef.current?.loadBanner();
  }, [config.adType]);

  /**
   * Show banner ad
   */
  const showBanner = useCallback(() => {
    if (config.adType !== 'banner') {
      console.warn('showBanner called but ad type is not banner');
      return;
    }
    adRef.current?.showBanner();
  }, [config.adType]);

  /**
   * Hide banner ad
   */
  const hideBanner = useCallback(() => {
    if (config.adType !== 'banner') {
      console.warn('hideBanner called but ad type is not banner');
      return;
    }
    adRef.current?.hideBanner();
  }, [config.adType]);

  /**
   * Load interstitial ad
   */
  const loadInterstitial = useCallback(() => {
    if (config.adType !== 'interstitial') {
      console.warn('loadInterstitial called but ad type is not interstitial');
      return;
    }
    adRef.current?.loadInterstitial();
  }, [config.adType]);

  /**
   * Show interstitial ad
   */
  const showInterstitial = useCallback(() => {
    if (config.adType !== 'interstitial') {
      console.warn('showInterstitial called but ad type is not interstitial');
      return;
    }
    adRef.current?.showInterstitial();
  }, [config.adType]);

  /**
   * Hide interstitial ad
   */
  const hideInterstitial = useCallback(() => {
    if (config.adType !== 'interstitial') {
      console.warn('hideInterstitial called but ad type is not interstitial');
      return;
    }
    adRef.current?.hideInterstitial();
  }, [config.adType]);

  /**
   * Pause ad auction (for banners)
   */
  const pauseAuction = useCallback(() => {
    adRef.current?.pauseAuction();
  }, []);

  /**
   * Resume ad auction (for banners)
   */
  const resumeAuction = useCallback(() => {
    adRef.current?.resumeAuction();
  }, []);

  /**
   * Destroy ad and free resources
   */
  const destroyAuction = useCallback(() => {
    adRef.current?.destroyAuction();
  }, []);

  /**
   * Cleanup on unmount
   */
  useEffect(() => {
    return () => {
      // Optional: destroy ad on unmount
      // adRef.current?.destroyAuction();
    };
  }, []);

  return {
    adRef,
    loadBanner,
    showBanner,
    hideBanner,
    loadInterstitial,
    showInterstitial,
    hideInterstitial,
    pauseAuction,
    resumeAuction,
    destroyAuction,
  };
}
