
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@interface RCT_EXTERN_MODULE(RNColorThief, NSObject)

RCT_EXTERN_METHOD(getColor: (NSString*)source quality: (int)quality ignoreWhite: (BOOL)ignoreWhite width: (int)width height: (int)height resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getPalette: (NSString*)source colorCount: (int)colorCount quality: (int)quality ignoreWhite:  width: (int)width height: (int)height  (BOOL)ignoreWhite resolve: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
