package com.setupadprebidreactnative

import android.graphics.Color
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter

/**
 * ViewManager for Prebid ad views
 * Handles creation and management of banner and interstitial ads
 */
@ReactModule(name = VeonPrebidReactNativeViewManager.NAME)
class VeonPrebidReactNativeViewManager(
    private val reactContext: ReactApplicationContext
) : SimpleViewManager<VeonPrebidReactNativeView>() {

    private val TAG = "VeonPrebidViewManager"

    override fun getName(): String = NAME

    override fun createViewInstance(context: ThemedReactContext): VeonPrebidReactNativeView {
        Log.d(TAG, "Creating VeonPrebidReactNativeView instance")
        return VeonPrebidReactNativeView(context)
    }

    /**
     * Set ad type (banner, interstitial, rewardVideo)
     */
    @ReactProp(name = "adType")
    fun setAdType(view: VeonPrebidReactNativeView, adType: String) {
        Log.d(TAG, "Setting ad type: $adType")
        view.setAdType(adType)
    }

    /**
     * Set Prebid config ID
     */
    @ReactProp(name = "configId")
    fun setConfigId(view: VeonPrebidReactNativeView, configId: String) {
        Log.d(TAG, "Setting config ID: $configId")
        view.setConfigId(configId)
    }

    /**
     * Set Google Ad Manager ad unit ID
     */
    @ReactProp(name = "adUnitId")
    fun setAdUnitId(view: VeonPrebidReactNativeView, adUnitId: String) {
        Log.d(TAG, "Setting ad unit ID: $adUnitId")
        view.setAdUnitId(adUnitId)
    }

    /**
     * Set ad width
     */
    @ReactProp(name = "width")
    fun setWidth(view: VeonPrebidReactNativeView, width: Int) {
        Log.d(TAG, "Setting width: $width")
        view.setAdWidth(width)
    }

    /**
     * Set ad height
     */
    @ReactProp(name = "height")
    fun setHeight(view: VeonPrebidReactNativeView, height: Int) {
        Log.d(TAG, "Setting height: $height")
        view.setAdHeight(height)
    }

    /**
     * Set refresh interval in seconds (for banners)
     */
    @ReactProp(name = "refreshInterval")
    fun setRefreshInterval(view: VeonPrebidReactNativeView, refreshInterval: Int) {
        Log.d(TAG, "Setting refresh interval: $refreshInterval seconds")
        view.setRefreshInterval(refreshInterval)
    }

    /**
     * Define commands that can be called from JavaScript
     */
    override fun getCommandsMap(): Map<String, Int> = mapOf(
        "loadBanner" to COMMAND_LOAD_BANNER,
        "showBanner" to COMMAND_SHOW_BANNER,
        "hideBanner" to COMMAND_HIDE_BANNER,
        "loadInterstitial" to COMMAND_LOAD_INTERSTITIAL,
        "showInterstitial" to COMMAND_SHOW_INTERSTITIAL,
        "hideInterstitial" to COMMAND_HIDE_INTERSTITIAL,
        "pauseAuction" to COMMAND_PAUSE_AUCTION,
        "resumeAuction" to COMMAND_RESUME_AUCTION,
        "destroyAuction" to COMMAND_DESTROY_AUCTION
    )

    /**
     * Handle commands from JavaScript (new architecture - String command)
     */
    override fun receiveCommand(
        view: VeonPrebidReactNativeView,
        commandId: String,
        args: ReadableArray?
    ) {
        Log.d(TAG, "Received command (String): $commandId")

        when (commandId.toIntOrNull()) {
            COMMAND_LOAD_BANNER -> view.loadBanner()
            COMMAND_SHOW_BANNER -> view.showBanner()
            COMMAND_HIDE_BANNER -> view.hideBanner()
            COMMAND_LOAD_INTERSTITIAL -> view.loadInterstitial()
            COMMAND_SHOW_INTERSTITIAL -> view.showInterstitial()
            COMMAND_HIDE_INTERSTITIAL -> view.hideInterstitial()
            COMMAND_PAUSE_AUCTION -> view.pauseAuction()
            COMMAND_RESUME_AUCTION -> view.resumeAuction()
            COMMAND_DESTROY_AUCTION -> view.destroyAuction()
            else -> Log.w(TAG, "Unknown command: $commandId")
        }
    }

    /**
     * Handle commands from JavaScript (old architecture - Int command)
     */
    override fun receiveCommand(
        view: VeonPrebidReactNativeView,
        commandId: Int,
        args: ReadableArray?
    ) {
        Log.d(TAG, "Received command (Int): $commandId")

        when (commandId) {
            COMMAND_LOAD_BANNER -> view.loadBanner()
            COMMAND_SHOW_BANNER -> view.showBanner()
            COMMAND_HIDE_BANNER -> view.hideBanner()
            COMMAND_LOAD_INTERSTITIAL -> view.loadInterstitial()
            COMMAND_SHOW_INTERSTITIAL -> view.showInterstitial()
            COMMAND_HIDE_INTERSTITIAL -> view.hideInterstitial()
            COMMAND_PAUSE_AUCTION -> view.pauseAuction()
            COMMAND_RESUME_AUCTION -> view.resumeAuction()
            COMMAND_DESTROY_AUCTION -> view.destroyAuction()
            else -> Log.w(TAG, "Unknown command: $commandId")
        }
    }

    /**
     * Export event names for JavaScript
     */
    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> {
        return mapOf(
            "onAdLoaded" to mapOf("registrationName" to "onAdLoaded"),
            "onAdDisplayed" to mapOf("registrationName" to "onAdDisplayed"),
            "onAdFailed" to mapOf("registrationName" to "onAdFailed"),
            "onAdClicked" to mapOf("registrationName" to "onAdClicked"),
            "onAdClosed" to mapOf("registrationName" to "onAdClosed")
        )
    }

    /**
     * Cleanup when view is dropped
     */
    override fun onDropViewInstance(view: VeonPrebidReactNativeView) {
        Log.d(TAG, "Dropping view instance")
        view.destroyAuction()
        super.onDropViewInstance(view)
    }

    companion object {
        const val NAME = "VeonPrebidReactNativeView"

        // Command constants (starts from 0 to match iOS Old Architecture)
        private const val COMMAND_LOAD_BANNER = 0
        private const val COMMAND_SHOW_BANNER = 1
        private const val COMMAND_HIDE_BANNER = 2
        private const val COMMAND_LOAD_INTERSTITIAL = 3
        private const val COMMAND_SHOW_INTERSTITIAL = 4
        private const val COMMAND_HIDE_INTERSTITIAL = 5
        private const val COMMAND_PAUSE_AUCTION = 6
        private const val COMMAND_RESUME_AUCTION = 7
        private const val COMMAND_DESTROY_AUCTION = 8
    }
}
