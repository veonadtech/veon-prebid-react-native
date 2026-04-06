import { createRef } from 'react';
import { render } from '@testing-library/react-native';
import { VeonPrebidView } from '../VeonPrebidView';

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
  };
});

describe('VeonPrebidView', () => {
  it('should render native component', () => {
    const { getByTestId } = render(
      <VeonPrebidView
        adType="banner"
        configId="test-config"
        adUnitId="/test/unit"
      />
    );

    expect(getByTestId('native-view')).toBeTruthy();
  });

  it('should forward all props to native component', () => {
    const onAdLoaded = jest.fn();
    const onAdFailed = jest.fn();

    const { getByTestId } = render(
      <VeonPrebidView
        adType="interstitial"
        configId="config-abc"
        adUnitId="/network/interstitial"
        width={320}
        height={480}
        refreshInterval={90}
        onAdLoaded={onAdLoaded}
        onAdFailed={onAdFailed}
      />
    );

    const nativeView = getByTestId('native-view');
    expect(nativeView.props.adType).toBe('interstitial');
    expect(nativeView.props.configId).toBe('config-abc');
    expect(nativeView.props.adUnitId).toBe('/network/interstitial');
    expect(nativeView.props.width).toBe(320);
    expect(nativeView.props.height).toBe(480);
    expect(nativeView.props.refreshInterval).toBe(90);
    expect(nativeView.props.onAdLoaded).toBe(onAdLoaded);
    expect(nativeView.props.onAdFailed).toBe(onAdFailed);
  });

  it('should forward ref to native component', () => {
    const ref = createRef<any>();

    render(
      <VeonPrebidView
        ref={ref}
        adType="banner"
        configId="test"
        adUnitId="/test/unit"
      />
    );

    expect(ref.current).toBeTruthy();
  });

  it('should have correct displayName', () => {
    expect(VeonPrebidView.displayName).toBe('VeonPrebidView');
  });
});
