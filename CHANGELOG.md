# CHANGELOG

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
