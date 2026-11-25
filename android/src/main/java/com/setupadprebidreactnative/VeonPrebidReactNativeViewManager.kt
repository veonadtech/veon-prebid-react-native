package com.setupadprebidreactnative

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.VeonPrebidReactNativeViewManagerDelegate
import com.facebook.react.viewmanagers.VeonPrebidReactNativeViewManagerInterface

/**
 * ViewManager for Prebid ad views
 * Handles creation and management of banner and interstitial ads
 */
@ReactModule(name = VeonPrebidReactNativeViewManager.NAME)
class VeonPrebidReactNativeViewManager(
    private val reactContext: ReactApplicationContext
) : SimpleViewManager<VeonPrebidReactNativeView>(),
    VeonPrebidReactNativeViewManagerInterface<VeonPrebidReactNativeView> {

    private val TAG = "VeonPrebidViewManager"

    private val delegate = VeonPrebidReactNativeViewManagerDelegate(this)

    override fun getDelegate(): ViewManagerDelegate<VeonPrebidReactNativeView> = delegate

    override fun getName(): String = NAME

    override fun createViewInstance(context: ThemedReactContext): VeonPrebidReactNativeView {
        Log.d(TAG, "Creating VeonPrebidReactNativeView instance")
        return VeonPrebidReactNativeView(context)
    }

    // region Props

    /**
     * Set ad type (banner, interstitial, rewardVideo)
     */
    @ReactProp(name = "adType")
    override fun setAdType(view: VeonPrebidReactNativeView, adType: String?) {
        Log.d(TAG, "Setting ad type: $adType")
        view.setAdType(adType ?: return)
    }

    /**
     * Set Prebid config ID
     */
    @ReactProp(name = "configId")
    override fun setConfigId(view: VeonPrebidReactNativeView, configId: String?) {
        Log.d(TAG, "Setting config ID: $configId")
        view.setConfigId(configId ?: return)
    }

    /**
     * Set Google Ad Manager ad unit ID
     */
    @ReactProp(name = "adUnitId")
    override fun setAdUnitId(view: VeonPrebidReactNativeView, adUnitId: String?) {
        Log.d(TAG, "Setting ad unit ID: $adUnitId")
        view.setAdUnitId(adUnitId ?: return)
    }

    /**
     * Set ad width
     */
    @ReactProp(name = "width")
    override fun setWidth(view: VeonPrebidReactNativeView, width: Int) {
        Log.d(TAG, "Setting width: $width")
        view.setAdWidth(width)
    }

    /**
     * Set ad height
     */
    @ReactProp(name = "height")
    override fun setHeight(view: VeonPrebidReactNativeView, height: Int) {
        Log.d(TAG, "Setting height: $height")
        view.setAdHeight(height)
    }

    /**
     * Set refresh interval in seconds (for banners)
     */
    @ReactProp(name = "refreshInterval")
    override fun setRefreshInterval(view: VeonPrebidReactNativeView, refreshInterval: Int) {
        Log.d(TAG, "Setting refresh interval: $refreshInterval seconds")
        view.setRefreshInterval(refreshInterval)
    }

    override fun loadBanner(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.loadBanner() }
    }

    override fun showBanner(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.showBanner() }
    }

    override fun hideBanner(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.hideBanner() }
    }

    override fun loadInterstitial(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.loadInterstitial() }
    }

    override fun showInterstitial(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.showInterstitial() }
    }

    override fun hideInterstitial(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.hideInterstitial() }
    }

    override fun loadRewarded(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.loadRewarded() }
    }

    override fun showRewarded(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.showRewarded() }
    }

    override fun pauseAuction(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.pauseAuction() }
    }

    override fun resumeAuction(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.resumeAuction() }
    }

    override fun destroyAuction(view: VeonPrebidReactNativeView) {
        UiThreadUtil.runOnUiThread { view.destroyAuction() }
    }

    /**
     * Handle commands from JavaScript (old architecture - Int command)
     */
    @Deprecated("Deprecated in Java")
    override fun receiveCommand(
        view: VeonPrebidReactNativeView,
        commandId: Int,
        args: ReadableArray?
    ) {
        Log.d(TAG, "Received command (Int): $commandId")
        UiThreadUtil.runOnUiThread {
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
                COMMAND_LOAD_REWARDED -> view.loadRewarded()
                COMMAND_SHOW_REWARDED -> view.showRewarded()
                else -> Log.w(TAG, "Unknown command: $commandId")
            }
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
            "onAdClosed" to mapOf("registrationName" to "onAdClosed"),
            "onAdRewardEarned" to mapOf("registrationName" to "onAdRewardEarned")
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
        private const val COMMAND_LOAD_REWARDED = 9
        private const val COMMAND_SHOW_REWARDED = 10
    }
}
