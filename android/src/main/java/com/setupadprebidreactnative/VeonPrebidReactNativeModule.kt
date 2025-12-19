package com.setupadprebidreactnative

import android.app.Activity
import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.android.gms.ads.MobileAds
import org.prebid.mobile.PrebidMobile
import org.prebid.mobile.api.data.InitializationStatus
import java.util.concurrent.CompletableFuture

/**
 * Native module for initializing Prebid SDK and handling SDK-level operations
 */
class VeonPrebidReactNativeModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    private val TAG = "VeonPrebidReactNative"
    private val activityFuture = CompletableFuture<Activity>()

    override fun getName(): String {
        return "VeonPrebidReactNativeModule"
    }

    /**
     * Initialize Prebid Mobile SDK
     * @param prebidHost - Prebid server host URL
     * @param configHost - Configuration host URL
     * @param accountId - Prebid account ID
     * @param timeoutMillis - Timeout in milliseconds for bid requests
     * @param pbsDebug - Enable/disable debug mode
     * @param promise - Promise to return initialization result
     */
    @ReactMethod
    fun initializeSDK(
        prebidHost: String,
        configHost: String,
        accountId: String,
        timeoutMillis: Int,
        pbsDebug: Boolean,
        promise: Promise
    ) {
        try {
            Log.d(TAG, "Initializing Prebid SDK")
            Log.d(TAG, "Host: $prebidHost")
            Log.d(TAG, "Config Host: $configHost")
            Log.d(TAG, "Account ID: $accountId")
            Log.d(TAG, "Timeout: $timeoutMillis ms")
            Log.d(TAG, "Debug: $pbsDebug")

            val activity = reactContext.currentActivity
            if (activity == null) {
                promise.reject("NO_ACTIVITY", "Activity is not available")
                return
            }

            // Set Prebid account ID
            PrebidMobile.setPrebidServerAccountId(accountId)

            // Initialize SDK
            PrebidMobile.initializeSdk(activity.applicationContext, prebidHost, configHost) { status ->
                when (status) {
                    InitializationStatus.SUCCEEDED -> {
                        Log.d(TAG, "Prebid Mobile SDK initialized successfully!")
                        sendEvent("prebidSdkInitialized", "successfully")
                        promise.resolve("successfully")
                    }
                    InitializationStatus.SERVER_STATUS_WARNING -> {
                        val message = "Server status warning: ${status.description}"
                        Log.w(TAG, message)
                        sendEvent("prebidSdkInitialized", message)
                        promise.resolve(message)
                    }
                    else -> {
                        val errorMessage = "Initialization error: ${status.description}"
                        Log.e(TAG, errorMessage)
                        sendEvent("prebidSdkInitializeFailed", errorMessage)
                        promise.reject("INIT_FAILED", errorMessage)
                    }
                }
            }

            // Set debug mode
            PrebidMobile.setPbsDebug(pbsDebug)

            // Check Google Mobile Ads compatibility
            PrebidMobile.checkGoogleMobileAdsCompatibility(MobileAds.getVersion().toString())

            // Set timeout
            PrebidMobile.setTimeoutMillis(timeoutMillis)

            // Enable geo location sharing
            PrebidMobile.setShareGeoLocation(true)

        } catch (e: Exception) {
            Log.e(TAG, "Error initializing Prebid SDK: ${e.message}", e)
            promise.reject("INIT_ERROR", "Failed to initialize SDK: ${e.message}", e)
        }
    }

    /**
     * Get Prebid SDK version
     */
    @ReactMethod
    fun getSDKVersion(promise: Promise) {
        try {
            val version = PrebidMobile.SDK_VERSION
            promise.resolve(version)
        } catch (e: Exception) {
            promise.reject("VERSION_ERROR", "Failed to get SDK version: ${e.message}", e)
        }
    }

    /**
     * Send event to JavaScript
     */
    private fun sendEvent(eventName: String, params: Any?) {
        try {
            reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                .emit(eventName, params)
        } catch (e: Exception) {
            Log.e(TAG, "Error sending event: ${e.message}", e)
        }
    }

    companion object {
        const val NAME = "VeonPrebidReactNativeModule"
    }
}
