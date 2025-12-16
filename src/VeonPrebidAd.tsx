import { useRef, useImperativeHandle, forwardRef, useCallback } from 'react';
import {
  UIManager,
  findNodeHandle,
  StyleSheet,
  View,
  type ViewStyle,
} from 'react-native';
import VeonPrebidReactNativeView from './VeonPrebidReactNativeViewNativeComponent';
import type { VeonPrebidAdProps, AdController, AdEventData } from './types';

// Command IDs - must match ViewManager
const Commands = {
  loadBanner: 1,
  showBanner: 2,
  hideBanner: 3,
  loadInterstitial: 4,
  showInterstitial: 5,
  hideInterstitial: 6,
  pauseAuction: 7,
  resumeAuction: 8,
  destroyAuction: 9,
} as const;

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

    const executeCommand = useCallback(
      (commandName: string, commandId: number) => {
        const node = findNodeHandle(viewRef.current);
        if (!node) {
          console.warn(`Cannot execute ${commandName} - view not mounted`);
          return;
        }

        console.log(
          `Executing ${commandName} (ID: ${commandId}) on node: ${node}`
        );
        UIManager.dispatchViewManagerCommand(node, commandId, []);
      },
      []
    );

    useImperativeHandle(
      ref,
      () => ({
        loadBanner: () => executeCommand('loadBanner', Commands.loadBanner),
        showBanner: () => executeCommand('showBanner', Commands.showBanner),
        hideBanner: () => executeCommand('hideBanner', Commands.hideBanner),
        loadInterstitial: () =>
          executeCommand('loadInterstitial', Commands.loadInterstitial),
        showInterstitial: () =>
          executeCommand('showInterstitial', Commands.showInterstitial),
        hideInterstitial: () =>
          executeCommand('hideInterstitial', Commands.hideInterstitial),
        pauseAuction: () =>
          executeCommand('pauseAuction', Commands.pauseAuction),
        resumeAuction: () =>
          executeCommand('resumeAuction', Commands.resumeAuction),
        destroyAuction: () =>
          executeCommand('destroyAuction', Commands.destroyAuction),
      }),
      [executeCommand]
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
        const error = event.nativeEvent.error || 'Unknown error';
        console.error('Ad failed:', error);
        onAdFailed?.(error);
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
