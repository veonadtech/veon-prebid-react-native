import { useRef, useImperativeHandle, forwardRef, useCallback } from 'react';
import {
  StyleSheet,
  View,
  type ViewStyle,
} from 'react-native';
import VeonPrebidReactNativeView, { Commands } from './VeonPrebidReactNativeViewNativeComponent';
import type { VeonPrebidAdProps, AdController, AdEventData } from './types';

const VeonPrebidAd = forwardRef<AdController, VeonPrebidAdProps>(
  (props, ref) => {
    const {
      adType,
      configId,
      adUnitId,
      width,
      height,
      refreshInterval = 30,
      onAdLoaded,
      onAdDisplayed,
      onAdFailed,
      onAdClicked,
      onAdClosed,
      style,
    } = props;

    const viewRef = useRef<any>(null);

    useImperativeHandle(
      ref,
      () => ({
        loadBanner: () => {
          if (viewRef.current) Commands.loadBanner(viewRef.current);
        },
        showBanner: () => {
          if (viewRef.current) Commands.showBanner(viewRef.current);
        },
        hideBanner: () => {
          if (viewRef.current) Commands.hideBanner(viewRef.current);
        },
        loadInterstitial: () => {
          if (viewRef.current) Commands.loadInterstitial(viewRef.current);
        },
        showInterstitial: () => {
          if (viewRef.current) Commands.showInterstitial(viewRef.current);
        },
        hideInterstitial: () => {
          if (viewRef.current) Commands.hideInterstitial(viewRef.current);
        },
        pauseAuction: () => {
          if (viewRef.current) Commands.pauseAuction(viewRef.current);
        },
        resumeAuction: () => {
          if (viewRef.current) Commands.resumeAuction(viewRef.current);
        },
        destroyAuction: () => {
          if (viewRef.current) Commands.destroyAuction(viewRef.current);
        },
      }),
      []
    );

    const handleAdLoaded = useCallback(
      (event: any) => {
        const data: AdEventData = event.nativeEvent;
        console.log('Ad loaded:', data);
        onAdLoaded?.(data);
      },
      [onAdLoaded]
    );

    const handleAdDisplayed = useCallback(
      (event: any) => {
        const data: AdEventData = event.nativeEvent;
        console.log('Ad displayed:', data);
        onAdDisplayed?.(data);
      },
      [onAdDisplayed]
    );

    const handleAdFailed = useCallback(
      (event: any) => {
        const data: AdEventData = event.nativeEvent;
        console.error('Ad failed:', data.error, `SDK: ${data.sdkType}`);
        onAdFailed?.(data);
      },
      [onAdFailed]
    );

    const handleAdClicked = useCallback(
      (event: any) => {
        const data: AdEventData = event.nativeEvent;
        console.log('Ad clicked:', data);
        onAdClicked?.(data);
      },
      [onAdClicked]
    );

    const handleAdClosed = useCallback(
      (event: any) => {
        const data: AdEventData = event.nativeEvent;
        console.log('Ad closed:', data);
        onAdClosed?.(data);
      },
      [onAdClosed]
    );

    const containerStyle: ViewStyle = {
      overflow: 'hidden',
      ...(adType === 'banner' && width && height
        ? { width, height }
        : { width: 1, height: 1 }),
      ...(style || {}),
    };

    return (
      <View style={containerStyle}>
        <VeonPrebidReactNativeView
          ref={viewRef}
          style={StyleSheet.absoluteFill}
          adType={adType}
          configId={configId}
          adUnitId={adUnitId}
          width={width as number}
          height={height as number}
          refreshInterval={refreshInterval as number}
          onAdLoaded={handleAdLoaded}
          onAdDisplayed={handleAdDisplayed}
          onAdFailed={handleAdFailed}
          onAdClicked={handleAdClicked}
          onAdClosed={handleAdClosed}
        />
      </View>
    );
  }
);

VeonPrebidAd.displayName = 'VeonPrebidAd';

export default VeonPrebidAd;
