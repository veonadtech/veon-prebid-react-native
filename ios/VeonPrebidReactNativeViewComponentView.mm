#ifdef RCT_NEW_ARCH_ENABLED
#import "VeonPrebidReactNativeViewComponentView.h"

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/EventEmitters.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/Props.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface VeonPrebidReactNativeViewComponentView () <RCTVeonPrebidReactNativeViewViewProtocol>
@end

@implementation VeonPrebidReactNativeViewComponentView {
    UIView *_view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<VeonPrebidReactNativeViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const VeonPrebidReactNativeViewProps>();
        _props = defaultProps;

        Class viewClass = NSClassFromString(@"VeonPrebidReactNativeView");
        if (viewClass) {
            _view = [[viewClass alloc] init];
        } else {
            _view = [[UIView alloc] init];
        }
        _view.frame = self.bounds;
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.contentView = _view;
    }

    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<const VeonPrebidReactNativeViewProps>(_props);
    const auto &newViewProps = *std::static_pointer_cast<const VeonPrebidReactNativeViewProps>(props);

    if (oldViewProps.adType != newViewProps.adType) {
        [_view setValue:[NSString stringWithUTF8String:newViewProps.adType.c_str()] forKey:@"adTypeValue"];
    }

    if (oldViewProps.configId != newViewProps.configId) {
        [_view setValue:[NSString stringWithUTF8String:newViewProps.configId.c_str()] forKey:@"configIdValue"];
    }

    if (oldViewProps.adUnitId != newViewProps.adUnitId) {
        [_view setValue:[NSString stringWithUTF8String:newViewProps.adUnitId.c_str()] forKey:@"adUnitIdValue"];
    }

    if (oldViewProps.width != newViewProps.width) {
        [_view setValue:@(newViewProps.width) forKey:@"widthValue"];
    }

    if (oldViewProps.height != newViewProps.height) {
        [_view setValue:@(newViewProps.height) forKey:@"heightValue"];
    }

    if (oldViewProps.refreshInterval != newViewProps.refreshInterval) {
        [_view setValue:@(newViewProps.refreshInterval) forKey:@"refreshIntervalValue"];
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
    NSLog(@"VeonPrebid iOS: handleCommand: %@", commandName);

    if ([commandName isEqualToString:@"loadBanner"]) {
        [_view performSelector:@selector(loadBanner)];
    } else if ([commandName isEqualToString:@"showBanner"]) {
        [_view performSelector:@selector(showBanner)];
    } else if ([commandName isEqualToString:@"hideBanner"]) {
        [_view performSelector:@selector(hideBanner)];
    } else if ([commandName isEqualToString:@"loadInterstitial"]) {
        [_view performSelector:@selector(loadInterstitial)];
    } else if ([commandName isEqualToString:@"showInterstitial"]) {
        [_view performSelector:@selector(showInterstitial)];
    } else if ([commandName isEqualToString:@"hideInterstitial"]) {
        [_view performSelector:@selector(hideInterstitial)];
    } else if ([commandName isEqualToString:@"pauseAuction"]) {
        [_view performSelector:@selector(pauseAuction)];
    } else if ([commandName isEqualToString:@"resumeAuction"]) {
        [_view performSelector:@selector(resumeAuction)];
    } else if ([commandName isEqualToString:@"destroyAuction"]) {
        [_view performSelector:@selector(destroyAuction)];
    } else {
        [super handleCommand:commandName args:args];
    }
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
    [super updateEventEmitter:eventEmitter];

    __weak __typeof(self) weakSelf = self;

    void (^onAdLoaded)(NSDictionary *) = ^(NSDictionary *event) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf && strongSelf->_eventEmitter) {
            auto emitter = std::static_pointer_cast<const VeonPrebidReactNativeViewEventEmitter>(strongSelf->_eventEmitter);
            VeonPrebidReactNativeViewEventEmitter::OnAdLoaded data;
            if (event[@"adId"]) data.adId = std::string([event[@"adId"] UTF8String]);
            if (event[@"sdk"]) data.sdk = std::string([event[@"sdk"] UTF8String]);
            if (event[@"message"]) data.message = std::string([event[@"message"] UTF8String]);
            emitter->onAdLoaded(data);
        }
    };
    [_view setValue:[onAdLoaded copy] forKey:@"onAdLoaded"];

    void (^onAdDisplayed)(NSDictionary *) = ^(NSDictionary *event) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf && strongSelf->_eventEmitter) {
            auto emitter = std::static_pointer_cast<const VeonPrebidReactNativeViewEventEmitter>(strongSelf->_eventEmitter);
            VeonPrebidReactNativeViewEventEmitter::OnAdDisplayed data;
            if (event[@"adId"]) data.adId = std::string([event[@"adId"] UTF8String]);
            if (event[@"sdk"]) data.sdk = std::string([event[@"sdk"] UTF8String]);
            if (event[@"message"]) data.message = std::string([event[@"message"] UTF8String]);
            emitter->onAdDisplayed(data);
        }
    };
    [_view setValue:[onAdDisplayed copy] forKey:@"onAdDisplayed"];

    void (^onAdFailed)(NSDictionary *) = ^(NSDictionary *event) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf && strongSelf->_eventEmitter) {
            auto emitter = std::static_pointer_cast<const VeonPrebidReactNativeViewEventEmitter>(strongSelf->_eventEmitter);
            VeonPrebidReactNativeViewEventEmitter::OnAdFailed data;
            if (event[@"adId"]) data.adId = std::string([event[@"adId"] UTF8String]);
            if (event[@"sdk"]) data.sdk = std::string([event[@"sdk"] UTF8String]);
            if (event[@"message"]) data.message = std::string([event[@"message"] UTF8String]);
            emitter->onAdFailed(data);
        }
    };
    [_view setValue:[onAdFailed copy] forKey:@"onAdFailed"];

    void (^onAdClicked)(NSDictionary *) = ^(NSDictionary *event) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf && strongSelf->_eventEmitter) {
            auto emitter = std::static_pointer_cast<const VeonPrebidReactNativeViewEventEmitter>(strongSelf->_eventEmitter);
            VeonPrebidReactNativeViewEventEmitter::OnAdClicked data;
            if (event[@"adId"]) data.adId = std::string([event[@"adId"] UTF8String]);
            if (event[@"sdk"]) data.sdk = std::string([event[@"sdk"] UTF8String]);
            if (event[@"message"]) data.message = std::string([event[@"message"] UTF8String]);
            emitter->onAdClicked(data);
        }
    };
    [_view setValue:[onAdClicked copy] forKey:@"onAdClicked"];

    void (^onAdClosed)(NSDictionary *) = ^(NSDictionary *event) {
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf && strongSelf->_eventEmitter) {
            auto emitter = std::static_pointer_cast<const VeonPrebidReactNativeViewEventEmitter>(strongSelf->_eventEmitter);
            VeonPrebidReactNativeViewEventEmitter::OnAdClosed data;
            if (event[@"adId"]) data.adId = std::string([event[@"adId"] UTF8String]);
            if (event[@"sdk"]) data.sdk = std::string([event[@"sdk"] UTF8String]);
            if (event[@"message"]) data.message = std::string([event[@"message"] UTF8String]);
            emitter->onAdClosed(data);
        }
    };
    [_view setValue:[onAdClosed copy] forKey:@"onAdClosed"];
}

Class<RCTComponentViewProtocol> VeonPrebidReactNativeViewCls(void)
{
    return VeonPrebidReactNativeViewComponentView.class;
}

@end
#endif
