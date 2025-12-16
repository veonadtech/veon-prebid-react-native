package com.setupadprebidreactnative

import android.content.Context
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.RCTEventEmitter
import org.prebid.mobile.AdSize
import org.prebid.mobile.api.data.SdkType
import org.prebid.mobile.api.multiadloader.MultiBannerLoader
import org.prebid.mobile.api.multiadloader.MultiInterstitialAdLoader
import org.prebid.mobile.api.multiadloader.listeners.MultiBannerViewListener
import org.prebid.mobile.api.multiadloader.listeners.MultiInterstitialAdListener
import org.prebid.mobile.api.rendering.BannerView

class VeonPrebidReactNativeView(private val reactContext: ReactContext) : FrameLayout(reactContext) {
  private val TAG = "VeonPrebidRN"

  // Ad loaders
  private var bannerLoader: MultiBannerLoader? = null
  private var interstitialLoader: MultiInterstitialAdLoader? = null

  // Ad parameters - stored individually for compatibility with ViewManager
  private var adType: String? = null
  private var configId: String? = null
  private var adUnitId: String? = null
  private var width: Int = 0
  private var height: Int = 0
  private var refreshInterval: Int = 30

  // Banner view reference
  private var bannerView: BannerView? = null
  private var adView: View? = null

  // Track if parameters are complete
  private var paramsComplete = false

  init {
    Log.d(TAG, "VeonPrebidReactNativeView initialized")

    // Set layout params for the container
    val params = LayoutParams(
      LayoutParams.MATCH_PARENT,
      LayoutParams.WRAP_CONTENT
    )
    params.gravity = Gravity.CENTER
    layoutParams = params
  }

  // Individual setters for React Native props
  fun setAdType(type: String) {
    this.adType = type
    Log.d(TAG, "AdType set: $type")
    checkAndCreateLoader()
  }

  fun setConfigId(id: String) {
    this.configId = id
    Log.d(TAG, "ConfigId set: $id")
    checkAndCreateLoader()
  }

  fun setAdUnitId(id: String) {
    this.adUnitId = id
    Log.d(TAG, "AdUnitId set: $id")
    checkAndCreateLoader()
  }

  fun setAdWidth(w: Int) {
    this.width = w
    Log.d(TAG, "Width set: $w")
    checkAndCreateLoader()
  }

  fun setAdHeight(h: Int) {
    this.height = h
    Log.d(TAG, "Height set: $h")
    checkAndCreateLoader()
  }

  fun setRefreshInterval(interval: Int) {
    this.refreshInterval = interval
    Log.d(TAG, "RefreshInterval set: $interval")
    checkAndCreateLoader()
  }

  // Check if all required params are set and create loader
  private fun checkAndCreateLoader() {
    if (adType != null && configId != null && adUnitId != null &&
      width > 0 && height > 0 && !paramsComplete) {

      paramsComplete = true
      Log.d(TAG, "All params set - type=$adType, configId=$configId, adUnitId=$adUnitId, size=${width}x${height}, refresh=$refreshInterval")

      // Auto-create loader based on ad type
      when (adType?.lowercase()) {
        "banner" -> {
          Log.d(TAG, "Auto-creating banner loader")
          if (bannerLoader == null) {
            createBannerLoader()
          }
        }
        "interstitial" -> {
          Log.d(TAG, "Auto-creating interstitial loader")
          if (interstitialLoader == null) {
            createInterstitialLoader()
          }
        }
      }
    }
  }

  fun loadBanner() {
    Log.d(TAG, "loadBanner called - configId=$configId, adUnitId=$adUnitId")

    if (configId == null || adUnitId == null) {
      Log.e(TAG, "Cannot load banner: configId or adUnitId is null")
      sendEvent("onAdFailed", "Config ID or Ad Unit ID is null")
      return
    }

    if (bannerLoader == null) {
      Log.d(TAG, "Banner loader is null, creating new one")
      createBannerLoader()
    }

    Log.d(TAG, "Calling bannerLoader.loadAd()")
    bannerLoader?.loadAd()
  }

  fun showBanner() {
    Log.d(TAG, "showBanner called - adView=$adView, size before: ${adView?.width}x${adView?.height}")

    adView?.let { view ->
      if (view.parent != null) {
        Log.d(TAG, "Removing view from old parent: ${view.parent}")
        (view.parent as? FrameLayout)?.removeView(view)
      }

      Log.d(TAG, "Adding banner view to container - size: ${width}x${height}dp")

      // Convert dp to pixels for layout
      val density = resources.displayMetrics.density
      val widthPx = (width * density).toInt()
      val heightPx = (height * density).toInt()

      // Set layout params on the ad view itself
      view.layoutParams = LayoutParams(widthPx, heightPx)

      val params = LayoutParams(widthPx, heightPx)
      params.gravity = Gravity.CENTER
      addView(view, params)

      visibility = View.VISIBLE

      // Force layout and measure
      view.measure(
        View.MeasureSpec.makeMeasureSpec(widthPx, View.MeasureSpec.EXACTLY),
        View.MeasureSpec.makeMeasureSpec(heightPx, View.MeasureSpec.EXACTLY)
      )
      view.layout(0, 0, widthPx, heightPx)
      view.requestLayout()
      requestLayout()

      Log.d(TAG, "Banner view added - pixels: ${widthPx}x${heightPx}px, view size: ${view.width}x${view.height}, childCount=$childCount")
    } ?: run {
      Log.w(TAG, "No banner view to show - adView is null. Try calling loadBanner first.")
      sendEvent("onAdFailed", "No banner loaded yet")
    }
  }

  fun hideBanner() {
    Log.d(TAG, "hideBanner called")
    adView?.let { view ->
      removeView(view)
      visibility = View.GONE
      Log.d(TAG, "Banner view removed and hidden")
    }
  }

  private fun createBannerLoader() {
    Log.d(TAG, "Creating banner loader - size: ${width}x${height}, configId: $configId, adUnitId: $adUnitId, refresh: $refreshInterval")

    try {
      bannerLoader = MultiBannerLoader(
        context = context,
        adSize = AdSize(width, height),
        configId = configId!!,
        gamAdUnitId = adUnitId!!,
        autoRefreshDelay = refreshInterval
      )

      Log.d(TAG, "MultiBannerLoader created successfully")

      bannerLoader?.setListener(object : MultiBannerViewListener {
        override fun onAdLoaded(view: View, sdk: SdkType) {
          Log.d(TAG, "Banner LOADED from ${sdk.name}")
          adView = view
          sendEvent("onAdLoaded", sdk)
        }

        override fun onAdFailed(bannerView: BannerView?, error: String?, sdk: SdkType?) {
          val errorMsg = error ?: "Unknown error"
          val sdkName = sdk?.name ?: "unknown"
          Log.e(TAG, "Banner FAILED: $errorMsg (SDK: $sdkName)")
          sendEvent("onAdFailed", errorMsg, sdk)
        }

        override fun onAdClicked(bannerView: BannerView?, sdk: SdkType) {
          Log.d(TAG, "Banner clicked from ${sdk.name}")
          sendEvent("onAdClicked", sdk)
        }

        override fun onAdClosed(bannerView: BannerView?, sdk: SdkType) {
          Log.d(TAG, "Banner closed from ${sdk.name}")
          sendEvent("onAdClosed", sdk)
        }

        override fun onAdDisplayed(bannerAdView: BannerView?, sdk: SdkType) {
          this@VeonPrebidReactNativeView.bannerView = bannerAdView
          Log.d(TAG, "Banner DISPLAYED from ${sdk.name}")
          sendEvent("onAdDisplayed", sdk)
        }

        override fun onImpression(sdk: SdkType) {
          Log.d(TAG, "Banner impression from ${sdk.name}")
        }

        override fun onAdOpened(sdk: SdkType) {
          Log.d(TAG, "Banner opened from ${sdk.name}")
        }
      })

      Log.d(TAG, "Banner listener set successfully")
    } catch (e: Exception) {
      Log.e(TAG, "Error creating banner loader", e)
      sendEvent("onAdFailed", "Error creating banner: ${e.message}")
    }
  }

  fun loadInterstitial() {
    Log.d(TAG, "loadInterstitial called")
    if (configId == null || adUnitId == null) {
      Log.e(TAG, "Cannot load interstitial: configId or adUnitId is null")
      sendEvent("onAdFailed", "Config ID or Ad Unit ID is null")
      return
    }

    if (interstitialLoader == null) {
      createInterstitialLoader()
    }

    Log.d(TAG, "Calling interstitialLoader.loadAd()")
    interstitialLoader?.loadAd()
  }

  fun showInterstitial() {
    Log.d(TAG, "showInterstitial called")
    interstitialLoader?.showAd() ?: run {
      Log.w(TAG, "No interstitial to show")
      sendEvent("onAdFailed", "No interstitial loaded yet")
    }
  }

  fun hideInterstitial() {
    Log.d(TAG, "hideInterstitial called")
    destroyInterstitialLoader()
  }

  private fun createInterstitialLoader() {
    Log.d(TAG, "Creating interstitial loader")

    try {
      interstitialLoader = MultiInterstitialAdLoader(
        context = reactContext.currentActivity ?: reactContext,
        configId = configId!!,
        gamAdUnitId = adUnitId!!
      )

      Log.d(TAG, "MultiInterstitialAdLoader created successfully")

      interstitialLoader?.setListener(object : MultiInterstitialAdListener {
        override fun onAdLoaded(sdk: SdkType) {
          Log.d(TAG, "Interstitial LOADED from ${sdk.name}")
          sendEvent("onAdLoaded", sdk)
        }

        override fun onAdDisplayed(sdk: SdkType) {
          Log.d(TAG, "Interstitial DISPLAYED from ${sdk.name}")
          sendEvent("onAdDisplayed", sdk)
        }

        override fun onAdFailed(error: String?, sdk: SdkType?) {
          val errorMsg = error ?: "Unknown error"
          val sdkName = sdk?.name ?: "unknown"
          Log.e(TAG, "Interstitial FAILED: $errorMsg (SDK: $sdkName)")
          sendEvent("onAdFailed", errorMsg, sdk)
        }

        override fun onAdFailedToShow(error: String?, sdk: SdkType?) {
          val errorMsg = error ?: "Unknown error"
          val sdkName = sdk?.name ?: "unknown"
          Log.e(TAG, "Interstitial FAILED TO SHOW: $errorMsg (SDK: $sdkName)")
          sendEvent("onAdFailed", errorMsg, sdk)
        }

        override fun onAdClicked(sdk: SdkType) {
          Log.d(TAG, "Interstitial clicked from ${sdk.name}")
          sendEvent("onAdClicked", sdk)
        }

        override fun onAdClosed(sdk: SdkType) {
          Log.d(TAG, "Interstitial closed from ${sdk.name}")
          sendEvent("onAdClosed", sdk)
        }
      })

      Log.d(TAG, "Interstitial listener set successfully")
    } catch (e: Exception) {
      Log.e(TAG, "Error creating interstitial loader", e)
      sendEvent("onAdFailed", "Error creating interstitial: ${e.message}")
    }
  }

  // Pause/Resume/Destroy methods for compatibility
  fun pauseAuction() {
    Log.d(TAG, "pauseAuction called")
    bannerView?.stopRefresh()
  }

  fun resumeAuction() {
    Log.d(TAG, "resumeAuction called")
    bannerView?.setAutoRefreshDelay(refreshInterval)
  }

  fun destroyAuction() {
    Log.d(TAG, "destroyAuction called")
    destroy()
  }

  private fun getSdkTypeName(sdk: SdkType?): String {
    return sdk?.name?.lowercase() ?: "unknown"
  }

  // Send event with SDK type (for successful events)
  private fun sendEvent(eventName: String, sdk: SdkType) {
    val event: WritableMap = Arguments.createMap()
    event.putString("configId", configId)
    event.putString("adUnitId", adUnitId)
    event.putString("sdkType", getSdkTypeName(sdk))

    try {
      reactContext
        .getJSModule(RCTEventEmitter::class.java)
        .receiveEvent(id, eventName, event)
      Log.d(TAG, "Event sent: $eventName - SDK: ${sdk.name}")
    } catch (e: Exception) {
      Log.e(TAG, "Error sending event: $eventName", e)
    }
  }

  // Send event with error message (for failed events)
  private fun sendEvent(eventName: String, error: String, sdk: SdkType? = null) {
    val event: WritableMap = Arguments.createMap()
    event.putString("configId", configId)
    event.putString("adUnitId", adUnitId)
    event.putString("error", error)
    if (sdk != null) {
      event.putString("sdkType", getSdkTypeName(sdk))
    }

    try {
      reactContext
        .getJSModule(RCTEventEmitter::class.java)
        .receiveEvent(id, eventName, event)
      Log.d(TAG, "Event sent: $eventName - Error: $error")
    } catch (e: Exception) {
      Log.e(TAG, "Error sending event: $eventName", e)
    }
  }

  private fun destroyBannerLoader() {
    try {
      removeAllViews()
      bannerView?.destroy()
      bannerLoader?.destroy()
      Log.d(TAG, "Banner loader destroyed")
    } catch (e: Exception) {
      Log.w(TAG, "Error destroying banner: $e")
    } finally {
      bannerView = null
      bannerLoader = null
      adView = null
    }
  }

  private fun destroyInterstitialLoader() {
    try {
      interstitialLoader?.destroy()
      Log.d(TAG, "Interstitial loader destroyed")
    } catch (e: Exception) {
      Log.w(TAG, "Error destroying interstitial: $e")
    } finally {
      interstitialLoader = null
    }
  }

  fun destroy() {
    Log.d(TAG, "Destroying view")
    destroyBannerLoader()
    destroyInterstitialLoader()
    paramsComplete = false
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    Log.d(TAG, "View detached from window")
    destroy()
  }
}
