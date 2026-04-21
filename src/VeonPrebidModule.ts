import { NativeModules, NativeEventEmitter } from 'react-native';
import type { PrebidConfig } from './types';

const LINKING_ERROR =
  `The package 'setupad-prebid-react-native' doesn't seem to be linked. Make sure: \n\n` +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// Native Module
const VeonPrebidReactNativeModule = NativeModules.VeonPrebidReactNativeModule
  ? NativeModules.VeonPrebidReactNativeModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

// Event Emitter for SDK events
const eventEmitter = new NativeEventEmitter(VeonPrebidReactNativeModule);

/**
 * Veon Prebid SDK Module
 * Handles SDK initialization and global SDK operations
 */
class VeonPrebidSDK {
  private static instance: VeonPrebidSDK;
  private isInitialized: boolean = false;
  private initializationPromise: Promise<string> | null = null;

  private constructor() {}

  /**
   * Get singleton instance
   */
  public static getInstance(): VeonPrebidSDK {
    if (!VeonPrebidSDK.instance) {
      VeonPrebidSDK.instance = new VeonPrebidSDK();
    }
    return VeonPrebidSDK.instance;
  }

  /**
   * Initialize Prebid Mobile SDK
   *
   * @param config - Prebid configuration
   * @returns Promise that resolves when SDK is initialized
   *
   * @example
   * ```typescript
   * await VeonPrebidSDK.getInstance().initialize({
   *   prebidHost: 'https://prebid.veonadx.com/openrtb2/auction',
   *   configHost: 'https://config.veonadx.com',
   *   accountId: 'YOUR_ACCOUNT_ID',
   *   timeoutMillis: 3000,
   *   pbsDebug: __DEV__,
   * });
   * ```
   */
  public async initialize(config: PrebidConfig): Promise<string> {
    // Return existing initialization if in progress
    if (this.initializationPromise !== null) {
      return this.initializationPromise;
    }

    // Return immediately if already initialized
    if (this.isInitialized) {
      return Promise.resolve('already initialized');
    }

    const {
      prebidHost,
      configHost,
      accountId,
      timeoutMillis = 3000,
      pbsDebug = false,
    } = config;

    console.log('Initializing Veon Prebid SDK...', {
      prebidHost,
      configHost,
      accountId,
      timeoutMillis,
      pbsDebug,
    });

    const promise = VeonPrebidReactNativeModule.initializeSDK(
      prebidHost,
      configHost,
      accountId,
      timeoutMillis,
      pbsDebug
    )
      .then((result: string) => {
        console.log('Veon Prebid SDK initialized successfully:', result);
        this.isInitialized = true;
        this.initializationPromise = null;
        return result;
      })
      .catch((error: any) => {
        console.error('Failed to initialize Veon Prebid SDK:', error);
        this.initializationPromise = null;
        throw error;
      });

    this.initializationPromise = promise;
    return promise;
  }

  /**
   * Get Prebid SDK version
   *
   * @returns Promise that resolves with SDK version string
   */
  public async getSDKVersion(): Promise<string> {
    try {
      return await VeonPrebidReactNativeModule.getSDKVersion();
    } catch (error) {
      console.error('Failed to get SDK version:', error);
      throw error;
    }
  }

  /**
   * Check if SDK is initialized
   */
  public isSDKInitialized(): boolean {
    return this.isInitialized;
  }

  /**
   * Add listener for SDK initialization events
   *
   * @param event - Event name ('prebidSdkInitialized' or 'prebidSdkInitializeFailed')
   * @param listener - Callback function
   * @returns Subscription object with remove() method
   */
  public addListener(
    event: 'prebidSdkInitialized' | 'prebidSdkInitializeFailed',
    listener: (data: any) => void
  ) {
    return eventEmitter.addListener(event, listener);
  }

  /**
   * Remove all listeners for specific event
   *
   * @param event - Event name
   */
  public removeAllListeners(
    event: 'prebidSdkInitialized' | 'prebidSdkInitializeFailed'
  ) {
    eventEmitter.removeAllListeners(event);
  }
}

export default VeonPrebidSDK;
