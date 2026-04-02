import { createRef } from 'react';
import { render, act } from '@testing-library/react-native';
import VeonPrebidAd from '../VeonPrebidAd';
import { Commands } from '../VeonPrebidReactNativeViewNativeComponent';
import type { AdController } from '../types';

// Mock the native component — renders a plain View with all props forwarded
jest.mock('../VeonPrebidReactNativeViewNativeComponent', () => {
  const { forwardRef } = require('react');
  const { View } = require('react-native');

  const MockNativeComponent = forwardRef((props: any, ref: any) => (
    <View ref={ref} {...props} testID="native-view" />
  ));
  MockNativeComponent.displayName = 'MockVeonPrebidReactNativeView';

  return {
    __esModule: true,
    default: MockNativeComponent,
    Commands: {
      loadBanner: jest.fn(),
      showBanner: jest.fn(),
      hideBanner: jest.fn(),
      loadInterstitial: jest.fn(),
      showInterstitial: jest.fn(),
      hideInterstitial: jest.fn(),
      pauseAuction: jest.fn(),
      resumeAuction: jest.fn(),
      destroyAuction: jest.fn(),
    },
  };
});

describe('VeonPrebidAd', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('props forwarding to native view', () => {
    it('should forward all ad props to native component', () => {
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="banner"
          configId="test-config-123"
          adUnitId="/network/ad-unit"
          width={320}
          height={50}
          refreshInterval={60}
        />
      );

      const nativeView = getByTestId('native-view');
      expect(nativeView.props.adType).toBe('banner');
      expect(nativeView.props.configId).toBe('test-config-123');
      expect(nativeView.props.adUnitId).toBe('/network/ad-unit');
      expect(nativeView.props.width).toBe(320);
      expect(nativeView.props.height).toBe(50);
      expect(nativeView.props.refreshInterval).toBe(60);
    });

    it('should use default refreshInterval of 30', () => {
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="banner"
          configId="test-config"
          adUnitId="/test/unit"
          width={300}
          height={250}
        />
      );

      const nativeView = getByTestId('native-view');
      expect(nativeView.props.refreshInterval).toBe(30);
    });

    it('should forward interstitial props without width/height', () => {
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="interstitial"
          configId="interstitial-config"
          adUnitId="/test/interstitial"
        />
      );

      const nativeView = getByTestId('native-view');
      expect(nativeView.props.adType).toBe('interstitial');
      expect(nativeView.props.configId).toBe('interstitial-config');
      expect(nativeView.props.adUnitId).toBe('/test/interstitial');
    });
  });

  describe('imperative commands dispatch to native', () => {
    it('should dispatch loadBanner command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      act(() => {
        ref.current?.loadBanner();
      });

      expect(Commands.loadBanner).toHaveBeenCalledTimes(1);
    });

    it('should dispatch showBanner command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      act(() => {
        ref.current?.showBanner();
      });

      expect(Commands.showBanner).toHaveBeenCalledTimes(1);
    });

    it('should dispatch hideBanner command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      act(() => {
        ref.current?.hideBanner();
      });

      expect(Commands.hideBanner).toHaveBeenCalledTimes(1);
    });

    it('should dispatch loadInterstitial command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="interstitial"
          configId="test"
          adUnitId="/test/unit"
        />
      );

      act(() => {
        ref.current?.loadInterstitial();
      });

      expect(Commands.loadInterstitial).toHaveBeenCalledTimes(1);
    });

    it('should dispatch showInterstitial command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="interstitial"
          configId="test"
          adUnitId="/test/unit"
        />
      );

      act(() => {
        ref.current?.showInterstitial();
      });

      expect(Commands.showInterstitial).toHaveBeenCalledTimes(1);
    });

    it('should dispatch hideInterstitial command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="interstitial"
          configId="test"
          adUnitId="/test/unit"
        />
      );

      act(() => {
        ref.current?.hideInterstitial();
      });

      expect(Commands.hideInterstitial).toHaveBeenCalledTimes(1);
    });

    it('should dispatch pauseAuction command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      act(() => {
        ref.current?.pauseAuction();
      });

      expect(Commands.pauseAuction).toHaveBeenCalledTimes(1);
    });

    it('should dispatch resumeAuction command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      act(() => {
        ref.current?.resumeAuction();
      });

      expect(Commands.resumeAuction).toHaveBeenCalledTimes(1);
    });

    it('should dispatch destroyAuction command', () => {
      const ref = createRef<AdController>();
      render(
        <VeonPrebidAd
          ref={ref}
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      act(() => {
        ref.current?.destroyAuction();
      });

      expect(Commands.destroyAuction).toHaveBeenCalledTimes(1);
    });
  });

  describe('event callbacks', () => {
    it('should call onAdLoaded when native emits event', () => {
      const onAdLoaded = jest.fn();
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
          onAdLoaded={onAdLoaded}
        />
      );

      const nativeView = getByTestId('native-view');
      act(() => {
        nativeView.props.onAdLoaded({
          nativeEvent: { sdkType: 'PREBID', configId: 'test' },
        });
      });

      expect(onAdLoaded).toHaveBeenCalledTimes(1);
      expect(onAdLoaded).toHaveBeenCalledWith(
        expect.objectContaining({ sdkType: 'PREBID' })
      );
    });

    it('should call onAdFailed when native emits error event', () => {
      const onAdFailed = jest.fn();
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
          onAdFailed={onAdFailed}
        />
      );

      const nativeView = getByTestId('native-view');
      act(() => {
        nativeView.props.onAdFailed({
          nativeEvent: { error: 'No fill', sdkType: 'GAM' },
        });
      });

      expect(onAdFailed).toHaveBeenCalledTimes(1);
      expect(onAdFailed).toHaveBeenCalledWith(
        expect.objectContaining({ error: 'No fill', sdkType: 'GAM' })
      );
    });

    it('should call onAdClicked when native emits click event', () => {
      const onAdClicked = jest.fn();
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
          onAdClicked={onAdClicked}
        />
      );

      const nativeView = getByTestId('native-view');
      act(() => {
        nativeView.props.onAdClicked({
          nativeEvent: { sdkType: 'PREBID' },
        });
      });

      expect(onAdClicked).toHaveBeenCalledTimes(1);
    });

    it('should call onAdClosed when native emits close event', () => {
      const onAdClosed = jest.fn();
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="interstitial"
          configId="test"
          adUnitId="/test/unit"
          onAdClosed={onAdClosed}
        />
      );

      const nativeView = getByTestId('native-view');
      act(() => {
        nativeView.props.onAdClosed({
          nativeEvent: { sdkType: 'GAM' },
        });
      });

      expect(onAdClosed).toHaveBeenCalledTimes(1);
    });

    it('should call onAdDisplayed when native emits display event', () => {
      const onAdDisplayed = jest.fn();
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="interstitial"
          configId="test"
          adUnitId="/test/unit"
          onAdDisplayed={onAdDisplayed}
        />
      );

      const nativeView = getByTestId('native-view');
      act(() => {
        nativeView.props.onAdDisplayed({
          nativeEvent: { sdkType: 'PREBID' },
        });
      });

      expect(onAdDisplayed).toHaveBeenCalledTimes(1);
    });

    it('should not crash when event callbacks are not provided', () => {
      const { getByTestId } = render(
        <VeonPrebidAd
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      const nativeView = getByTestId('native-view');

      // Should not throw
      expect(() => {
        act(() => {
          nativeView.props.onAdLoaded({
            nativeEvent: { sdkType: 'PREBID' },
          });
          nativeView.props.onAdFailed({
            nativeEvent: { error: 'test' },
          });
        });
      }).not.toThrow();
    });
  });

  describe('container sizing', () => {
    it('should set container size to width/height for banner ads', () => {
      const { toJSON } = render(
        <VeonPrebidAd
          adType="banner"
          configId="test"
          adUnitId="/test/unit"
          width={320}
          height={50}
        />
      );

      const tree = toJSON() as any;
      const containerStyle = tree.props.style;
      expect(containerStyle).toEqual(
        expect.objectContaining({ width: 320, height: 50 })
      );
    });

    it('should set container size to 1x1 for interstitial ads', () => {
      const { toJSON } = render(
        <VeonPrebidAd
          adType="interstitial"
          configId="test"
          adUnitId="/test/unit"
        />
      );

      const tree = toJSON() as any;
      const containerStyle = tree.props.style;
      expect(containerStyle).toEqual(
        expect.objectContaining({ width: 1, height: 1 })
      );
    });
  });
});
