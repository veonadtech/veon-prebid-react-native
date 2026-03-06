# CHANGELOG

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
