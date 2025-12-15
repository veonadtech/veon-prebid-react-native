import React from 'react';
import VeonPrebidReactNativeViewNative from './VeonPrebidReactNativeViewNativeComponent';
import type { VeonPrebidViewProps } from './types';

export const VeonPrebidView = React.forwardRef<any, VeonPrebidViewProps>(
  (props, ref) => {
    return <VeonPrebidReactNativeViewNative ref={ref} {...props} />;
  }
);

VeonPrebidView.displayName = 'VeonPrebidView';

export default VeonPrebidView;
