package com.setupadprebidreactnative

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.android.gms.ads.MobileAds
import org.prebid.mobile.PrebidMobile
import org.prebid.mobile.api.data.InitializationStatus
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Native module for initializing Prebid SDK and handling SDK-level operations
 */
class VeonPrebidReactNativeModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    private val TAG = "VeonPrebidReactNative"

    @Volatile private var isInitialized = false
    @Volatile private var isInitializing = false

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
        if (isInitialized) {
            promise.resolve("already initialized")
            return
        }
        if (isInitializing) {
            promise.reject("INIT_IN_PROGRESS", "Prebid SDK initialization already in progress")
            return
        }
        isInitializing = true

        Log.d(TAG, "Initializing Prebid SDK")
        Log.d(TAG, "Host: $prebidHost")
        Log.d(TAG, "Config Host: $configHost")
        Log.d(TAG, "Account ID: $accountId")
        Log.d(TAG, "Timeout: $timeoutMillis ms")
        Log.d(TAG, "Debug: $pbsDebug")

        // Prefer the current activity when available; fall back to app context so
        // cold-start splash screens (where no activity is attached yet) still work.
        val context: Context =
            reactContext.currentActivity?.applicationContext ?: reactContext.applicationContext

        val mainHandler = Handler(Looper.getMainLooper())
        val didSettle = AtomicBoolean(false)

        val settleSuccess: (String) -> Unit = { result ->
            if (didSettle.compareAndSet(false, true)) {
                isInitializing = false
                isInitialized = true
                sendEvent("prebidSdkInitialized", result)
                promise.resolve(result)
            }
        }

        val settleFailure: (String, String, Throwable?) -> Unit = { code, message, error ->
            if (didSettle.compareAndSet(false, true)) {
                isInitializing = false
                sendEvent("prebidSdkInitializeFailed", message)
                if (error != null) promise.reject(code, message, error) else promise.reject(code, message)
            }
        }

        // Defense-in-depth native safety timer (behind the JS-layer guard).
        val timeoutRunnable = Runnable {
            settleFailure(
                "INIT_TIMEOUT_NATIVE",
                "Prebid SDK initialization exceeded ${NATIVE_INIT_TIMEOUT_MS}ms (native guard)",
                null
            )
        }
        mainHandler.postDelayed(timeoutRunnable, NATIVE_INIT_TIMEOUT_MS)

        // Apply settings BEFORE init so they govern the first auction.
        mainHandler.post {
            try {
                PrebidMobile.setPrebidServerAccountId(accountId)
                PrebidMobile.setPbsDebug(pbsDebug)
                PrebidMobile.setTimeoutMillis(timeoutMillis)
                PrebidMobile.setShareGeoLocation(true)
                PrebidMobile.checkGoogleMobileAdsCompatibility(MobileAds.getVersion().toString())

                PrebidMobile.initializeSdk(context, prebidHost, configHost) { status ->
                    mainHandler.removeCallbacks(timeoutRunnable)
                    when (status) {
                        InitializationStatus.SUCCEEDED -> {
                            Log.d(TAG, "Prebid Mobile SDK initialized successfully!")
                            settleSuccess("successfully")
                        }
                        InitializationStatus.SERVER_STATUS_WARNING -> {
                            val message = "warning: ${status.description}"
                            Log.w(TAG, message)
                            settleSuccess(message)
                        }
                        else -> {
                            val errorMessage = "Initialization error: ${status.description}"
                            Log.e(TAG, errorMessage)
                            settleFailure("INIT_FAILED", errorMessage, null)
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error initializing Prebid SDK: ${e.message}", e)
                mainHandler.removeCallbacks(timeoutRunnable)
                settleFailure("INIT_ERROR", "Failed to initialize SDK: ${e.message}", e)
            }
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
        private const val NATIVE_INIT_TIMEOUT_MS = 20_000L
    }
}
