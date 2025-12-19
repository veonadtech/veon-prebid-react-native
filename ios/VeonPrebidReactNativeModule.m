#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(VeonPrebidReactNativeModule, RCTEventEmitter)

RCT_EXTERN_METHOD(initializeSDK:(NSString *)prebidHost
                  configHost:(NSString *)configHost
                  accountId:(NSString *)accountId
                  timeoutMillis:(nonnull NSNumber *)timeoutMillis
                  pbsDebug:(BOOL)pbsDebug
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getSDKVersion:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

@end
