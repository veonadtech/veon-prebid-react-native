# Veon Prebid React Native

A React Native plugin for integrating Veon Prebid SDK with Google Ad Manager (GAM). Supports banner, interstitial, and rewarded video ads with waterfall approach (Prebid → GAM fallback).

## Features

✅ **Banner Ads** - Standard and custom sizes  
✅ **Interstitial Ads** - Full-screen ads  
✅ **Rewarded Video Ads** - User-rewarded video ads  
✅ **Waterfall Approach** - Prebid first, GAM fallback  
✅ **Explicit Control** - Manual load/show/hide methods  
✅ **TypeScript Support** - Full type definitions  
✅ **React Hooks** - `useVeonPrebidAd` hook for easy integration  

## Installation

```bash
npm install setupad-prebid-react-native
# or
yarn add setupad-prebid-react-native
```

### iOS Setup

1. Add Google Ad Manager App ID to `Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-################~##########</string>
```

2. Add SKAdNetworkItems (see [Google's documentation](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start#update_your_infoplist))

3. Install pods:

```bash
cd ios && pod install
```

### Android Setup

1. Add Google Ad Manager App ID to `AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-################~##########"/>
</application>
```

2. Add JitPack repository to `android/build.gradle`:

```gradle
allprojects {
    repositories {
        maven { url 'https://jitpack.io' }
    }
}
```

## Usage

### 1. Initialize SDK

```typescript
import { VeonPrebidSDK } from 'setupad-prebid-react-native';

try {
  // Initialize once at app startup. The returned promise is guaranteed to
  // settle (resolve or reject) — it will never stay pending indefinitely.
  await VeonPrebidSDK.getInstance().initialize({
    prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
    configHost: 'https://config.veonadx.com',
    accountId: 'YOUR_ACCOUNT_ID',
    timeoutMillis: 3000,      // bid-request timeout
    initTimeoutMillis: 15000, // optional; max wait for init (default 15s)
    pbsDebug: __DEV__,
  });
} catch (error) {
  // Publisher is responsible for deciding whether to proceed without ads,
  // retry, or surface the error — the promise will never hang.
  console.error('Prebid init failed:', error);
}
```

#### `initialize()` contract

The returned promise always settles within `initTimeoutMillis` (default **15000 ms**).

Resolve values: `"successfully"`, `"already initialized"`, `"warning: ..."`, `"skipped"`.

Rejection codes (on `error.code`):

| Code | Meaning |
|------|---------|
| `INIT_TIMEOUT` | JS-layer timeout fired (the canonical safety net). |
| `INIT_TIMEOUT_NATIVE` | Native-layer safety timer fired (rare; behind the JS guard). |
| `INIT_FAILED` | Prebid SDK reported a failure status. |
| `INIT_ERROR` | Unexpected exception during initialization. |
| `INIT_IN_PROGRESS` | `initialize()` was called again while a previous call was still running. |
| `NO_CONTEXT` (Android only) | Neither current activity nor application context was available. |

After any rejection, `initialize()` may be called again — the internal cache is cleared on every failure so publishers can safely retry.

### 2. Display Banner Ad

```typescript
import React, { useRef } from 'react';
import { VeonPrebidAd, AdType, AdController } from 'setupad-prebid-react-native';

function BannerExample() {
  const adRef = useRef<AdController>(null);

  return (
    <VeonPrebidAd
      ref={adRef}
      adType={AdType.BANNER}
      configId="YOUR_CONFIG_ID"
      adUnitId="/YOUR_NETWORK_ID/YOUR_AD_UNIT"
      width={300}
      height={250}
      refreshInterval={60}
      onAdLoaded={(data) => {
        console.log('Banner loaded from', data.sdk);
        adRef.current?.showBanner();
      }}
      onAdFailed={(error) => console.error('Banner failed:', error)}
    />
  );
}
```

### 3. Display Interstitial Ad

```typescript
import React, { useRef, useEffect } from 'react';
import { VeonPrebidAd, AdType, AdController } from 'setupad-prebid-react-native';

function InterstitialExample() {
  const adRef = useRef<AdController>(null);

  useEffect(() => {
    // Load interstitial on mount
    adRef.current?.loadInterstitial();
  }, []);

  const showAd = () => {
    adRef.current?.showInterstitial();
  };

  return (
    <>
      <VeonPrebidAd
        ref={adRef}
        adType={AdType.INTERSTITIAL}
        configId="YOUR_CONFIG_ID"
        adUnitId="/YOUR_NETWORK_ID/YOUR_AD_UNIT"
        onAdLoaded={(data) => console.log('Interstitial loaded')}
        onAdClosed={() => console.log('Interstitial closed')}
      />
      <Button title="Show Interstitial" onPress={showAd} />
    </>
  );
}
```

### 4. Using Hooks

```typescript
import { useVeonPrebidAd, AdType } from 'setupad-prebid-react-native';

function HookExample() {
  const { adRef, loadBanner, showBanner } = useVeonPrebidAd(
    {
      adType: AdType.BANNER,
      configId: 'YOUR_CONFIG_ID',
      adUnitId: '/YOUR_NETWORK_ID/YOUR_AD_UNIT',
      width: 300,
      height: 250,
    },
    {
      onAdLoaded: (data) => {
        console.log('Ad loaded:', data);
        showBanner();
      },
    }
  );

  useEffect(() => {
    loadBanner();
  }, []);

  return <VeonPrebidAd ref={adRef} />;
}
```

## API Reference

### VeonPrebidSDK

Singleton class for SDK initialization.

#### Methods

**`initialize(config: PrebidConfig): Promise<string>`**
- Initialize Prebid SDK
- Should be called once at app startup

**`getSDKVersion(): Promise<string>`**
- Get SDK version

**`isSDKInitialized(): boolean`**
- Check if SDK is initialized

### VeonPrebidAd Component

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `adType` | `AdType` | ✅ | Ad type: `banner`, `interstitial`, or `rewardVideo` |
| `configId` | `string` | ✅ | Prebid config ID |
| `adUnitId` | `string` | ✅ | Google Ad Manager ad unit ID |
| `width` | `number` | For banners | Ad width in pixels |
| `height` | `number` | For banners | Ad height in pixels |
| `refreshInterval` | `number` | ❌ | Refresh interval (30-120 seconds, default: 30) |
| `onAdLoaded` | `function` | ❌ | Called when ad is loaded |
| `onAdDisplayed` | `function` | ❌ | Called when ad is displayed |
| `onAdFailed` | `function` | ❌ | Called when ad fails |
| `onAdClicked` | `function` | ❌ | Called when ad is clicked |
| `onAdClosed` | `function` | ❌ | Called when ad is closed |

#### Ref Methods (AdController)

```typescript
interface AdController {
  loadBanner(): void;
  showBanner(): void;
  hideBanner(): void;
  loadInterstitial(): void;
  showInterstitial(): void;
  hideInterstitial(): void;
  pauseAuction(): void;
  resumeAuction(): void;
  destroyAuction(): void;
}
```

### useVeonPrebidAd Hook

```typescript
const {
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
} = useVeonPrebidAd(config, eventListener);
```

## Types

```typescript
enum AdType {
  BANNER = 'banner',
  INTERSTITIAL = 'interstitial',
  REWARD_VIDEO = 'rewardVideo',
}

interface PrebidConfig {
  prebidHost: string;
  configHost: string;
  accountId: string;
  timeoutMillis?: number;
  pbsDebug?: boolean;
}

interface AdEventData {
  adId?: string;
  sdk?: string; // 'PREBID' or 'GAM'
  message?: string;
}
```

## Best Practices

### Banner Ads
1. Load banner: `adRef.current?.loadBanner()`
2. Show when loaded: `onAdLoaded={() => adRef.current?.showBanner()}`
3. Hide if needed: `adRef.current?.hideBanner()`

### Interstitial Ads
1. Load early: `useEffect(() => adRef.current?.loadInterstitial(), [])`
2. Show on user action: `adRef.current?.showInterstitial()`
3. Reload after close: `onAdClosed={() => adRef.current?.loadInterstitial()}`

### Lifecycle Management
- Pause banner refresh when app goes background: `pauseAuction()`
- Resume when app comes foreground: `resumeAuction()`
- Destroy when unmounting: `destroyAuction()`

## Troubleshooting

### Android

**Issue:** Build fails with "Maven repository not found"  
**Solution:** Add JitPack repository to `android/build.gradle`

**Issue:** Ads not showing  
**Solution:** Check LogCat for "VeonPrebidView" logs

### iOS

**Issue:** Build fails with "Module not found"  
**Solution:** Run `cd ios && pod install`

**Issue:** Ads not showing  
**Solution:** Check Xcode console for "LOG:" messages

## Example App

See the `example/` directory for a complete working example with banner and interstitial ads.

```bash
cd example
npm install
npm run ios
# or
npm run android
```

## Requirements

- React Native >= 0.70
- iOS >= 11.0
- Android minSdkVersion >= 21

## License

MIT

## Support

For issues and questions, please visit:
- GitHub Issues: [veonadtech/veon_prebid_react_native](https://github.com/veonadtech/veon_prebid_react_native/issues)
- Documentation: [docs.veonadx.com](https://docs.veonadx.com)
