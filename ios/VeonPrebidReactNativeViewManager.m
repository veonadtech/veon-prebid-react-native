#import <React/RCTViewManager.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VeonPrebidReactNativeViewManager, RCTViewManager)

// Props - using UIView type
RCT_CUSTOM_VIEW_PROPERTY(adType, NSString, UIView) {
    [view setValue:[RCTConvert NSString:json] forKey:@"adTypeValue"];
}

RCT_CUSTOM_VIEW_PROPERTY(configId, NSString, UIView) {
    [view setValue:[RCTConvert NSString:json] forKey:@"configIdValue"];
}

RCT_CUSTOM_VIEW_PROPERTY(adUnitId, NSString, UIView) {
    [view setValue:[RCTConvert NSString:json] forKey:@"adUnitIdValue"];
}

RCT_CUSTOM_VIEW_PROPERTY(width, NSNumber, UIView) {
    [view setValue:[RCTConvert NSNumber:json] forKey:@"widthValue"];
}

RCT_CUSTOM_VIEW_PROPERTY(height, NSNumber, UIView) {
    [view setValue:[RCTConvert NSNumber:json] forKey:@"heightValue"];
}

RCT_CUSTOM_VIEW_PROPERTY(refreshInterval, NSNumber, UIView) {
    [view setValue:[RCTConvert NSNumber:json] forKey:@"refreshIntervalValue"];
}

// Events
RCT_EXPORT_VIEW_PROPERTY(onAdLoaded, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdDisplayed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdFailed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdClicked, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdClosed, RCTDirectEventBlock)

// Commands
RCT_EXTERN_METHOD(loadBanner:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(showBanner:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(hideBanner:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(loadInterstitial:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(showInterstitial:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(hideInterstitial:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(pauseAuction:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(resumeAuction:(nonnull NSNumber *)node)
RCT_EXTERN_METHOD(destroyAuction:(nonnull NSNumber *)node)

@end
