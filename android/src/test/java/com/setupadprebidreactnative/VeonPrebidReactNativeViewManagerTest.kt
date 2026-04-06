package com.setupadprebidreactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.viewmanagers.VeonPrebidReactNativeViewManagerDelegate
import org.junit.Assert.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.mockito.MockedStatic
import org.mockito.Mockito.*

/**
 * Tests that ViewManager correctly delegates commands and props to the View.
 * This verifies the JS → Native bridge: when React Native dispatches a command
 * or sets a prop, the ViewManager forwards it to VeonPrebidReactNativeView.
 */
class VeonPrebidReactNativeViewManagerTest {

    private lateinit var reactContext: ReactApplicationContext
    private lateinit var manager: VeonPrebidReactNativeViewManager
    private lateinit var view: VeonPrebidReactNativeView
    private lateinit var delegate: VeonPrebidReactNativeViewManagerDelegate<VeonPrebidReactNativeView, VeonPrebidReactNativeViewManager>
    private lateinit var uiThreadUtilMock: MockedStatic<UiThreadUtil>

    @Before
    fun setup() {
        // Mock UiThreadUtil.runOnUiThread to execute the Runnable immediately (no Android Looper in unit tests)
        uiThreadUtilMock = mockStatic(UiThreadUtil::class.java) { invocation ->
            val method = invocation.method
            if (method.name == "runOnUiThread" && invocation.arguments.isNotEmpty()) {
                (invocation.arguments[0] as Runnable).run()
            }
            null
        }

        reactContext = mock(ReactApplicationContext::class.java)
        manager = VeonPrebidReactNativeViewManager(reactContext)
        view = mock(VeonPrebidReactNativeView::class.java)
        delegate = VeonPrebidReactNativeViewManagerDelegate(manager)
    }

    @After
    fun teardown() {
        uiThreadUtilMock.close()
    }

    // region View Manager Configuration

    @Test
    fun `getName returns correct component name`() {
        assertEquals("VeonPrebidReactNativeView", manager.name)
    }

    @Test
    fun `getExportedCustomDirectEventTypeConstants exports all 5 events`() {
        val events = manager.exportedCustomDirectEventTypeConstants!!
        assertEquals(5, events.size)
        assertTrue(events.containsKey("onAdLoaded"))
        assertTrue(events.containsKey("onAdDisplayed"))
        assertTrue(events.containsKey("onAdFailed"))
        assertTrue(events.containsKey("onAdClicked"))
        assertTrue(events.containsKey("onAdClosed"))
    }

    @Test
    fun `event registrations use correct registrationName`() {
        val events = manager.exportedCustomDirectEventTypeConstants!!
        val eventNames = listOf("onAdLoaded", "onAdDisplayed", "onAdFailed", "onAdClicked", "onAdClosed")
        for (name in eventNames) {
            @Suppress("UNCHECKED_CAST")
            val entry = events[name] as Map<String, Any>
            assertEquals(name, entry["registrationName"])
        }
    }

    // endregion

    // region Prop Setters → View (called by @ReactProp for Paper)

    @Test
    fun `setAdType forwards to view`() {
        manager.setAdType(view, "banner")
        verify(view).setAdType("banner")
    }

    @Test
    fun `setAdType with null does not call view`() {
        manager.setAdType(view, null)
        verify(view, never()).setAdType(anyString())
    }

    @Test
    fun `setConfigId forwards to view`() {
        manager.setConfigId(view, "config-123")
        verify(view).setConfigId("config-123")
    }

    @Test
    fun `setConfigId with null does not call view`() {
        manager.setConfigId(view, null)
        verify(view, never()).setConfigId(anyString())
    }

    @Test
    fun `setAdUnitId forwards to view`() {
        manager.setAdUnitId(view, "/network/ad-unit")
        verify(view).setAdUnitId("/network/ad-unit")
    }

    @Test
    fun `setAdUnitId with null does not call view`() {
        manager.setAdUnitId(view, null)
        verify(view, never()).setAdUnitId(anyString())
    }

    @Test
    fun `setWidth forwards to view`() {
        manager.setWidth(view, 320)
        verify(view).setAdWidth(320)
    }

    @Test
    fun `setHeight forwards to view`() {
        manager.setHeight(view, 250)
        verify(view).setAdHeight(250)
    }

    @Test
    fun `setRefreshInterval forwards to view`() {
        manager.setRefreshInterval(view, 60)
        verify(view).setRefreshInterval(60)
    }

    // endregion

    // region Command Methods → View (interface methods, called by delegate for Fabric)

    @Test
    fun `loadBanner command forwards to view`() {
        manager.loadBanner(view)
        verify(view).loadBanner()
    }

    @Test
    fun `showBanner command forwards to view`() {
        manager.showBanner(view)
        verify(view).showBanner()
    }

    @Test
    fun `hideBanner command forwards to view`() {
        manager.hideBanner(view)
        verify(view).hideBanner()
    }

    @Test
    fun `loadInterstitial command forwards to view`() {
        manager.loadInterstitial(view)
        verify(view).loadInterstitial()
    }

    @Test
    fun `showInterstitial command forwards to view`() {
        manager.showInterstitial(view)
        verify(view).showInterstitial()
    }

    @Test
    fun `hideInterstitial command forwards to view`() {
        manager.hideInterstitial(view)
        verify(view).hideInterstitial()
    }

    @Test
    fun `pauseAuction command forwards to view`() {
        manager.pauseAuction(view)
        verify(view).pauseAuction()
    }

    @Test
    fun `resumeAuction command forwards to view`() {
        manager.resumeAuction(view)
        verify(view).resumeAuction()
    }

    @Test
    fun `destroyAuction command forwards to view`() {
        manager.destroyAuction(view)
        verify(view).destroyAuction()
    }

    // endregion

    // region Paper Int-based Command Dispatch

    @Test
    fun `receiveCommand int 0 calls loadBanner`() {
        manager.receiveCommand(view, 0, null)
        verify(view).loadBanner()
    }

    @Test
    fun `receiveCommand int 1 calls showBanner`() {
        manager.receiveCommand(view, 1, null)
        verify(view).showBanner()
    }

    @Test
    fun `receiveCommand int 2 calls hideBanner`() {
        manager.receiveCommand(view, 2, null)
        verify(view).hideBanner()
    }

    @Test
    fun `receiveCommand int 3 calls loadInterstitial`() {
        manager.receiveCommand(view, 3, null)
        verify(view).loadInterstitial()
    }

    @Test
    fun `receiveCommand int 4 calls showInterstitial`() {
        manager.receiveCommand(view, 4, null)
        verify(view).showInterstitial()
    }

    @Test
    fun `receiveCommand int 5 calls hideInterstitial`() {
        manager.receiveCommand(view, 5, null)
        verify(view).hideInterstitial()
    }

    @Test
    fun `receiveCommand int 6 calls pauseAuction`() {
        manager.receiveCommand(view, 6, null)
        verify(view).pauseAuction()
    }

    @Test
    fun `receiveCommand int 7 calls resumeAuction`() {
        manager.receiveCommand(view, 7, null)
        verify(view).resumeAuction()
    }

    @Test
    fun `receiveCommand int 8 calls destroyAuction`() {
        manager.receiveCommand(view, 8, null)
        verify(view).destroyAuction()
    }

    // endregion

    // region Codegen Delegate — Command Dispatch (Fabric path via string)

    @Test
    fun `delegate dispatches loadBanner by string`() {
        delegate.receiveCommand(view, "loadBanner", null)
        verify(view).loadBanner()
    }

    @Test
    fun `delegate dispatches showBanner by string`() {
        delegate.receiveCommand(view, "showBanner", null)
        verify(view).showBanner()
    }

    @Test
    fun `delegate dispatches hideBanner by string`() {
        delegate.receiveCommand(view, "hideBanner", null)
        verify(view).hideBanner()
    }

    @Test
    fun `delegate dispatches loadInterstitial by string`() {
        delegate.receiveCommand(view, "loadInterstitial", null)
        verify(view).loadInterstitial()
    }

    @Test
    fun `delegate dispatches showInterstitial by string`() {
        delegate.receiveCommand(view, "showInterstitial", null)
        verify(view).showInterstitial()
    }

    @Test
    fun `delegate dispatches hideInterstitial by string`() {
        delegate.receiveCommand(view, "hideInterstitial", null)
        verify(view).hideInterstitial()
    }

    @Test
    fun `delegate dispatches pauseAuction by string`() {
        delegate.receiveCommand(view, "pauseAuction", null)
        verify(view).pauseAuction()
    }

    @Test
    fun `delegate dispatches resumeAuction by string`() {
        delegate.receiveCommand(view, "resumeAuction", null)
        verify(view).resumeAuction()
    }

    @Test
    fun `delegate dispatches destroyAuction by string`() {
        delegate.receiveCommand(view, "destroyAuction", null)
        verify(view).destroyAuction()
    }

    // endregion

    // region Codegen Delegate — Prop Setting (Fabric path)

    @Test
    fun `delegate sets adType prop`() {
        delegate.setProperty(view, "adType", "interstitial")
        verify(view).setAdType("interstitial")
    }

    @Test
    fun `delegate sets configId prop`() {
        delegate.setProperty(view, "configId", "my-config-id")
        verify(view).setConfigId("my-config-id")
    }

    @Test
    fun `delegate sets adUnitId prop`() {
        delegate.setProperty(view, "adUnitId", "/123/ad-unit")
        verify(view).setAdUnitId("/123/ad-unit")
    }

    @Test
    fun `delegate sets width prop`() {
        delegate.setProperty(view, "width", 300.0)
        verify(view).setAdWidth(300)
    }

    @Test
    fun `delegate sets height prop`() {
        delegate.setProperty(view, "height", 250.0)
        verify(view).setAdHeight(250)
    }

    @Test
    fun `delegate sets refreshInterval prop`() {
        delegate.setProperty(view, "refreshInterval", 45.0)
        verify(view).setRefreshInterval(45)
    }

    // endregion

    // region onDropViewInstance

    @Test
    fun `onDropViewInstance calls destroyAuction on view`() {
        manager.onDropViewInstance(view)
        verify(view).destroyAuction()
    }

    // endregion
}
