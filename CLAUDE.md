# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

React Native bridge library (`setupad-prebid-react-native`) for integrating the Veon Prebid SDK with Google Ad Manager (GAM). Supports three ad types: Banner, Interstitial, and Rewarded Video using a waterfall approach (Prebid first, GAM fallback).

## Common Commands

```bash
# Development
yarn install          # Install all dependencies (root + example workspaces)
yarn typecheck        # Run TypeScript type checking
yarn lint             # ESLint across all JS/TS/TSX files
yarn test             # Run Jest tests
yarn prepare          # Build library via react-native-builder-bob (outputs to /lib/)
yarn clean            # Remove build artifacts

# Example app
yarn example android  # Run example app on Android
yarn example ios      # Run example app on iOS
yarn example start    # Start Metro bundler

# Release
yarn release          # Bump version, tag, and publish via release-it
```

## Architecture

### JS/TypeScript Layer (`src/`)

- **`VeonPrebidModule.ts`** — Singleton class wrapping the native module for SDK initialization (`initializeSDK`, `getSDKVersion`). Communicates with native via `NativeModules`.
- **`VeonPrebidAd.tsx`** — Main React component for rendering ads. Uses `forwardRef` + `useImperativeHandle` to expose imperative methods (loadBanner, showBanner, loadInterstitial, etc.) to parent components.
- **`useVeonPrebidAd.ts`** — Hook for programmatic ad control via ref.
- **`VeonPrebidReactNativeViewNativeComponent.ts`** — Codegen-based native component definition (Fabric-compatible).
- **`Commands.ts`** — Command ID constants dispatched to native view managers (0=loadBanner through 8=destroyAuction).
- **`types.ts`** — Shared type definitions (`AdType`, event interfaces, config types).

### Native Layers

**iOS (`ios/`, Swift + Objective-C bridging):**
- `VeonPrebidReactNativeModule.swift` — RCTEventEmitter for SDK init; emits `prebidSdkInitialized`/`prebidSdkInitializeFailed`.
- `VeonPrebidReactNativeView.swift` — Main UIView managing banner/interstitial/rewarded ad units.
- `VeonPrebidReactNativeView+Delegates.swift` — Delegate implementations for interstitial and rewarded ad callbacks.
- `VeonPrebidReactNativeViewManager.swift` — Fabric-compatible view manager bridging React Native to UIView.

**Android (`android/src/main/java/com/setupadprebidreactnative/`, Kotlin):**
- `VeonPrebidReactNativeModule.kt` — Native module for SDK init with event emission.
- `VeonPrebidReactNativeView.kt` — FrameLayout-based view using `MultiBannerLoader`/`MultiInterstitialAdLoader` from Prebid SDK.
- `VeonPrebidReactNativeViewManager.kt` — SimpleViewManager handling props and command dispatch.
- `VeonPrebidReactNativePackage.kt` — Package registration.

### Data Flow

1. **Init**: JS `VeonPrebidSDK.initialize(config)` → Native module sets up Prebid SDK → emits init event back to JS.
2. **Ad rendering**: JS renders `<VeonPrebidAd>` → creates native view via Codegen → props configure ad parameters.
3. **Ad control**: JS calls imperative methods (e.g., `adRef.current.loadBanner()`) → dispatches UIManager commands to native → native runs Prebid auction with GAM fallback → emits result events (`onAdLoaded`, `onAdFailed`, etc.) back to JS.

## Build & Dependencies

- **Builder**: `react-native-builder-bob` (ESM + TypeScript targets, output in `/lib/`)
- **Monorepo**: Yarn workspaces (root + `example/`)
- **iOS deps**: PrebidMobile 0.0.4, Google-Mobile-Ads-SDK 12.3.0 (min iOS 12.0)
- **Android deps**: Prebid SDK 0.1.1 (JitPack), play-services-ads 22.2.0 (minSdk 21, compileSdk 35)
- **Pre-commit hooks**: Lefthook runs ESLint + typecheck on staged files
