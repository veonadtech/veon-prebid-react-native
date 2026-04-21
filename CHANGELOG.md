# CHANGELOG

## 0.2.8
* **fix(init):** `VeonPrebidSDK.initialize()` is now guaranteed to resolve or reject within `initTimeoutMillis` (default 15 s) — previously the promise could hang indefinitely on network stalls, causing publishers' splash screens to freeze.
  * iOS: `Prebid.initializeSDK` status/error parameters are now honoured — `.failed` rejects with `INIT_FAILED` (previously resolved as "successfully"); added 20 s native safety timer.
  * Android: removed `NO_ACTIVITY` hard-fail on cold-start splash (falls back to application context); reordered `setPbsDebug` / `setTimeoutMillis` / `setShareGeoLocation` / `checkGoogleMobileAdsCompatibility` to run **before** `initializeSdk`; added 20 s native safety timer; concurrent-init guard.
  * JS: added `initTimeoutMillis` to `PrebidConfig`; `initialize()` wraps the native call in `Promise.race` and clears the cached promise on any rejection so retries work.
  * New rejection codes: `INIT_TIMEOUT`, `INIT_TIMEOUT_NATIVE`, `INIT_IN_PROGRESS`, `NO_CONTEXT` (Android).
* iOS native dependencies upgraded: VeonPrebidMobile 0.0.5 → 0.1.0, VeonPrebidMobileGAMEventHandlers 0.0.5 → 0.1.0, Google-Mobile-Ads-SDK 12.3.0 → 13.0.0 (required by the new event handlers pod)
* Android SDK version updated to 0.3.0
## Fixed
* Make NativeDataAsset len optional like iOS
* hb_cache_id_local is not added to targetingKeywords if adObject is null
* Fix bar layout params is null
* Fix Adm native wrapper parsing
* Exception during looking for cache
* Fix Unit tests
## Changed
* Send ifa_type for IFA
* Resume refreshing for Mediation banner
* Readable exceptions and useless logs
* ORTB config for ad unit level (Aligns with iOS implementation)
* Reusable rendering API banner (removes the destruction of Prebid WebView when it is detached
  from the screen. So now the Prebid banner can be used in the RecyclerView and can be reused
  many times to show the advertisement faster.)
* minSdkVersion upgraded to 23
* GAM SDK upgraded to 25.1.0

## 0.2.7
### Fixed
* Android: "Could not find generated setter for class VeonPrebidReactNativeViewManager" — implemented Codegen-generated `VeonPrebidReactNativeViewManagerInterface` and `VeonPrebidReactNativeViewManagerDelegate` for Fabric (New Architecture) compatibility while preserving `@ReactProp` annotations for Old Architecture backward compatibility

### Added
* Android unit tests (46 tests) — ViewManager prop/command dispatch via delegate and Paper fallback
* iOS unit tests (32 tests) — native view KVC prop setting, selector-based command dispatch, event wiring
* JS unit tests (31 tests) — component prop forwarding, imperative command dispatch, event callbacks, VeonPrebidView ref forwarding, null ref safety after unmount

## 0.2.6
### Fixed
* Android: banner ad disappearing when navigating to another screen — added `onAttachedToWindow` to re-display banner after reattach and `onDetachedFromWindow` now pauses refresh to prevent stale view replacements

## 0.2.5
### Fixed
* iOS: The Ad with custom sizes is not loaded from GAM Admanager with error "Invalid ad width or height".
### Changed
* Android SDK bumped to ver 0.2.0

## 0.2.4
### Fixed
* Android: banner ad disappearing after navigating away and returning — removed premature `destroy()` call from `onDetachedFromWindow` (cleanup now handled by `ViewManager.onDropViewInstance()` only)
* Android: wrapped `receiveCommand` dispatches in `UiThreadUtil.runOnUiThread` to ensure command execution is serialized on the UI thread

## 0.2.3
### Fixed
* Android: string command handler now matches by name (`"loadBanner"`) with numeric string fallback (`"0"`)

## 0.2.2
### Fixed
* iOS: `failed to verify module interface of 'PrebidMobileGAMEventHandlers'` — added `-no-verify-emitted-module-interface` and `DEFINES_MODULE` to native pod (0.0.5) podspec
* iOS: `'Commands' is a reserved export` — added clean JS generator (`scripts/generate-native-component-js.js`) to strip TypeScript syntax from codegen spec output
* Metro: `Could not find component config for native component` — added `"react-native": "./src/index.tsx"` to package.json `exports` so Metro loads TypeScript source directly
* Android: `Unknown command` — string command handler now matches by name (`"loadBanner"`) with numeric string fallback (`"0"`)

### Changed
* Dropped Expo support — SDK now targets bare React Native CLI only
* Removed `app.plugin.js` (Expo config plugin)
* Removed `ios/veon_prebid_helper.rb` (post-install helper no longer needed)
* Removed `@expo/config-plugins` from dependencies
* iOS native dependencies upgraded: VeonPrebidMobile 0.0.4 → 0.0.5, VeonPrebidMobileGAMEventHandlers 0.0.4 → 0.0.5
* Simplified example Podfile — redundant pod declarations removed (auto-linked via podspec)
* Updated installation docs for bare RN CLI (EN + RU)

## 0.1.9
### Changed
* Expo config plugin now writes `use_frameworks! :linkage => :static` directly to Podfile for reliable iOS builds
* Simplified `app.plugin.js` — removed redundant Podfile.properties.json approach

## 0.1.8
### Added
* `error` and `sdkType` fields to Fabric event payload (Codegen spec + ComponentView.mm)
* `@expo/config-plugins` as optional peer dependency
* `./app.plugin.js` and `./app.plugin` to package.json `exports`

## 0.1.7
### Added
* iOS static frameworks support in Expo config plugin (`use_frameworks! :linkage => :static`)
* Post-install hook for VeonPrebidMobile Swift module resolution

## 0.1.6
### Added
* Native commands for banner and interstitial actions via UIManager dispatch
* Fabric migration for iOS — `VeonPrebidReactNativeViewComponentView.mm` command handling

### Changed
* Refactored `VeonPrebidAd.tsx` to use imperative commands via Codegen
* Updated `VeonPrebidReactNativeViewNativeComponent.ts` with command definitions

## 0.1.5
### Added
* Expo config plugin (`app.plugin.js`) for automatic iOS build configuration
* CocoaPods dependencies and Swift module setup via plugin

### Changed
* Simplified `VeonPrebidReactNativeViewComponentView.mm` event bridging
* Updated podspec with improved dependency management
* Android `compileSdk` and `targetSdk` upgraded

## 0.1.4
### Fixed
* Android: Prebid UI operations now run on the main thread to prevent threading issues

### Changed
* Updated podspec with additional pod dependencies
* Updated peer dependencies

## 0.1.3
### Fixed
* iOS build failure (`'react/utils/fnv1a.h' file not found`) when using `use_frameworks! :linkage => :static` on React Native 0.76+
* TypeScript build errors preventing `npm publish` (duplicate `AdType` export, missing `AdConfig`/`AdEventListener` types, `onAdFailed` type mismatch with native component)

### Changed
* Added `HEADER_SEARCH_PATHS` to podspec for React Native Fabric framework headers when `USE_FRAMEWORKS` is enabled
* Aligned `VeonPrebidViewProps` event signatures with native `AdEventPayload` (`adId`, `sdk`, `message`)
* Set minimum peer dependency to `react-native >= 0.76.0`

### Removed
* Lefthook pre-commit hooks
* `package-lock.json` and `Podfile.lock` from git tracking

## 0.1.1
### Changed
* Android SDK version updated to 0.1.1

## 0.1.0
* Initial release
