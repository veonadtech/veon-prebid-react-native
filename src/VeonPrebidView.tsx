import React from 'react';
import {
  requireNativeComponent,
  UIManager,
  Platform,
  ViewStyle,
} from 'react-native';
import type { VeonPrebidViewProps } from './types';

const LINKING_ERROR =
  `The package 'setupad-prebid-react-native' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- Run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ComponentName = 'VeonPrebidReactNativeView';

const VeonPrebidReactNativeViewNative =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<VeonPrebidViewProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };

export const VeonPrebidView = React.forwardRef<any, VeonPrebidViewProps>(
  (props, ref) => {
    return <VeonPrebidReactNativeViewNative ref={ref} {...props} />;
  }
);

VeonPrebidView.displayName = 'VeonPrebidView';

export default VeonPrebidView;
