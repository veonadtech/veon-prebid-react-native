#ifdef RCT_NEW_ARCH_ENABLED
#import "VeonPrebidReactNativeViewComponentView.h"

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/EventEmitters.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/Props.h>
#import <react/renderer/components/VeonPrebidReactNativeViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "VeonPrebidReactNative-Swift.h"

using namespace facebook::react;

@interface VeonPrebidReactNativeViewComponentView () <RCTVeonPrebidReactNativeViewViewProtocol>
@end

@implementation VeonPrebidReactNativeViewComponentView {
    VeonPrebidReactNativeView *_view;
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

        _view = [[VeonPrebidReactNativeView alloc] init];
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

    // Update adType
    if (oldViewProps.adType != newViewProps.adType) {
        _view.adTypeValue = [NSString stringWithUTF8String:newViewProps.adType.c_str()];
    }

    // Update configId
    if (oldViewProps.configId != newViewProps.configId) {
        _view.configIdValue = [NSString stringWithUTF8String:newViewProps.configId.c_str()];
    }

    // Update adUnitId
    if (oldViewProps.adUnitId != newViewProps.adUnitId) {
        _view.adUnitIdValue = [NSString stringWithUTF8String:newViewProps.adUnitId.c_str()];
    }

    // Update width
    if (oldViewProps.width != newViewProps.width) {
        _view.widthValue = @(newViewProps.width);
    }

    // Update height
    if (oldViewProps.height != newViewProps.height) {
        _view.heightValue = @(newViewProps.height);
    }

    // Update refreshInterval
    if (oldViewProps.refreshInterval != newViewProps.refreshInterval) {
        _view.refreshIntervalValue = @(newViewProps.refreshInterval);
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
    [super updateEventEmitter:eventEmitter];

    __weak __typeof(self) weakSelf = self;

    // Set up event handlers
    _view.onAdLoaded = ^(NSDictionary *event) {
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

    _view.onAdDisplayed = ^(NSDictionary *event) {
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

    _view.onAdFailed = ^(NSDictionary *event) {
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

    _view.onAdClicked = ^(NSDictionary *event) {
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

    _view.onAdClosed = ^(NSDictionary *event) {
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
}

Class<RCTComponentViewProtocol> VeonPrebidReactNativeViewCls(void)
{
    return VeonPrebidReactNativeViewComponentView.class;
}

@end
#endif
