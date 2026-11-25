# Veon Prebid React Native

A React Native plugin for integrating Veon Prebid SDK with Google Ad Manager (GAM). Supports banner, interstitial, and rewarded video ads with Prebid bidding and GAM integration.

## Features

✅ **Banner Ads** - Standard and custom sizes
✅ **Interstitial Ads** - Full-screen ads
✅ **Rewarded Video Ads** - User-rewarded video ads
✅ **Prebid and GAM Integration** - Reports the ad source and source-specific load failures
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

3. After installing or updating this React Native package, resolve iOS dependencies:

```bash
cd ios && pod install
```

The adapter's podspec installs `VeonPrebidMobile`,
`VeonPrebidMobileGAMEventHandlers`, `VeonPrebidMultiAdLoader`,
`VeonPrebidMultiAdLoaderGAM`, and `VeonPrebidRemoteConfig` 0.5.3, plus
`Google-Mobile-Ads-SDK` 13.6.0. On iOS, banner and interstitial ads use
the Multi Ad Loader to request Prebid and GAM independently; rewarded ads use
the existing Prebid/GAM integration. `configHost` supplies the iOS remote
configuration URL for the loader's source priority. The SDK fetches it in the
background; until it arrives, the loader uses its default priority.
Do not add these pods separately to your Podfile. If your app uses
`use_frameworks!`, use static linkage (`use_frameworks! :linkage => :static`).

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

3. Set `kotlinVersion` to `2.3.0` in the Android project. The Prebid Android 0.5.5 dependencies contain Kotlin 2.3 metadata, which the previous Kotlin 2.1 compiler cannot read.

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
import React, { useEffect, useRef } from 'react';
import { VeonPrebidAd, AdType, AdController } from 'setupad-prebid-react-native';

function BannerExample() {
  const adRef = useRef<AdController>(null);

  useEffect(() => {
    adRef.current?.loadBanner();
  }, []);

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
        console.log('Banner loaded from', data.sdkType);
        adRef.current?.showBanner();
      }}
      onAdFailed={(data) => console.error(data.sdkType, data.error)}
    />
  );
}
```

### 3. Display Interstitial Ad

```typescript
import React, { useRef, useEffect } from 'react';
import { Button } from 'react-native';
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
        onAdLoaded={(data) => console.log('Interstitial loaded from', data.sdkType)}
        onAdFailed={(data) => console.error(data.sdkType, data.error)}
        onAdClosed={() => console.log('Interstitial closed')}
      />
      <Button title="Show Interstitial" onPress={showAd} />
    </>
  );
}
```

### 4. Display Rewarded Ad

```typescript
import React, { useRef } from 'react';
import { Button } from 'react-native';
import { VeonPrebidAd, AdType, type AdController } from 'setupad-prebid-react-native';

function RewardedExample() {
  const rewardedRef = useRef<AdController>(null);

  return (
    <>
      <VeonPrebidAd
        ref={rewardedRef}
        adType={AdType.REWARD_VIDEO}
        configId="YOUR_CONFIG_ID"
        adUnitId="/YOUR_NETWORK_ID/YOUR_REWARDED_AD_UNIT"
        onAdLoaded={(data) => console.log('Rewarded loaded from', data.sdkType)}
        onAdFailed={(data) => console.error(data.sdkType, data.error)}
        onAdRewardEarned={(reward) => {
          console.log('Reward earned:', reward.rewardType, reward.rewardAmount);
          // Grant the reward here, after the SDK reports that it was earned.
        }}
      />
      <Button title="Load rewarded" onPress={() => rewardedRef.current?.loadRewarded()} />
      <Button title="Show rewarded" onPress={() => rewardedRef.current?.showRewarded()} />
    </>
  );
}
```

### 5. Using Hooks

```typescript
import React, { useEffect } from 'react';
import { useVeonPrebidAd, AdType } from 'setupad-prebid-react-native';

function HookExample() {
  const config = {
    adType: AdType.BANNER,
    configId: 'YOUR_CONFIG_ID',
    adUnitId: '/YOUR_NETWORK_ID/YOUR_AD_UNIT',
    width: 300,
    height: 250,
  } as const;
  const { adRef, loadBanner, showBanner } = useVeonPrebidAd(config);

  useEffect(() => {
    loadBanner();
  }, [loadBanner]);

  return <VeonPrebidAd ref={adRef} {...config} onAdLoaded={showBanner} />;
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
| `adType` | `AdType` | ✅ | Ad type: `banner`, `interstitial`, or `rewardvideo` |
| `configId` | `string` | ✅ | Prebid config ID |
| `adUnitId` | `string` | ✅ | Google Ad Manager ad unit ID |
| `width` | `number` | For banners | Ad width in pixels |
| `height` | `number` | For banners | Ad height in pixels |
| `refreshInterval` | `number` | ❌ | Refresh interval (30-120 seconds, default: 30) |
| `onAdLoaded` | `function` | ❌ | Called when ad is loaded |
| `onAdDisplayed` | `function` | ❌ | Called when ad is displayed |
| `onAdFailed` | `function` | ❌ | Reports a source failure or a Prebid bid that did not win, with `error` and, when known, `sdkType` |
| `onAdClicked` | `function` | ❌ | Called when ad is clicked |
| `onAdClosed` | `function` | ❌ | Called when ad is closed |
| `onAdRewardEarned` | `function` | ❌ | Reports a rewarded ad reward after the SDK confirms it was earned |

`onAdLoaded` identifies the loaded ad. A failure from one source can be followed by a successful load from the other source. Treat `onAdRewardEarned` as the reward signal; loading or closing the ad does not grant a reward.

#### Ref Methods (AdController)

```typescript
interface AdController {
  loadBanner(): void;
  showBanner(): void;
  hideBanner(): void;
  loadInterstitial(): void;
  showInterstitial(): void;
  hideInterstitial(): void;
  loadRewarded(): void;
  showRewarded(): void;
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
  loadRewarded,
  showRewarded,
  pauseAuction,
  resumeAuction,
  destroyAuction,
} = useVeonPrebidAd(config);
```

## Types

```typescript
const AdType = {
  BANNER: 'banner',
  INTERSTITIAL: 'interstitial',
  REWARD_VIDEO: 'rewardvideo',
} as const;

interface PrebidConfig {
  prebidHost: string;
  configHost: string;
  accountId: string;
  timeoutMillis?: number;
  initTimeoutMillis?: number;
  pbsDebug?: boolean;
}

interface AdEventData {
  configId?: string;
  adUnitId?: string;
  sdkType?: string; // 'prebid' or 'gam' when known
  message?: string;
  error?: string;
}

interface RewardData {
  configId?: string;
  adUnitId?: string;
  sdkType?: string;
  rewardType?: string;
  rewardAmount?: number;
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
**Solution:** Check LogCat for `VeonPrebidRN` logs. A GAM `network error` is the Android Next-Gen SDK's general message for its network error code; it does not include the original request failure. Check the GAM ad unit ID and network setup.

### iOS

**Issue:** Build fails with "Module not found"
**Solution:** Run `cd ios && pod install`

**Issue:** React Native 0.81 with Xcode 26 fails while compiling `fmt 11.0.2` with a `consteval` error.

**Solution:** In your existing Podfile `post_install` block, after `react_native_post_install`, compile only the `fmt` pod as C++17:

```ruby
installer.pods_project.targets.each do |target|
  next unless target.name == 'fmt'

  target.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
  end
end
```

Then run `cd ios && pod install` again. This workaround is for that React Native and Xcode combination; the Veon SDK pods do not require it.

**Issue:** Ads not showing
**Solution:** Check Xcode console for `VeonPrebid iOS` messages.

## Example App

See the `example/` directory for banner, interstitial, and rewarded ad examples.

```bash
cd example
npm install
npm run ios
# or
npm run android
```

## Requirements

- React Native >= 0.76
- iOS >= 15.1 (React Native 0.76+)
- Android minSdkVersion >= 24

## License

MIT

## Support

For issues and questions, please visit:
- GitHub Issues: [veonadtech/veon_prebid_react_native](https://github.com/veonadtech/veon_prebid_react_native/issues)
- Documentation: [docs.veonadx.com](https://docs.veonadx.com)
