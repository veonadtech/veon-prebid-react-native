package com.setupadprebidreactnative

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.VeonPrebidReactNativeViewManagerInterface
import com.facebook.react.viewmanagers.VeonPrebidReactNativeViewManagerDelegate

@ReactModule(name = VeonPrebidReactNativeViewManager.NAME)
class VeonPrebidReactNativeViewManager : SimpleViewManager<VeonPrebidReactNativeView>(),
  VeonPrebidReactNativeViewManagerInterface<VeonPrebidReactNativeView> {
  private val mDelegate: ViewManagerDelegate<VeonPrebidReactNativeView>

  init {
    mDelegate = VeonPrebidReactNativeViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<VeonPrebidReactNativeView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): VeonPrebidReactNativeView {
    return VeonPrebidReactNativeView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: VeonPrebidReactNativeView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "VeonPrebidReactNativeView"
  }
}
