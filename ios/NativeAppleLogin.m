#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(NaitveAppleLogin, NSObject)

RCT_EXTERN_METHOD(login: (RCTPromiseResolveBlock) resolve rejecter: (RCTPromiseRejectBlock) reject)
RCT_EXTERN_METHOD(getCredentialState: (NSString) userId)

@end
