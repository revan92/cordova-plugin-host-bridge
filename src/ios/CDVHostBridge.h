#import <Cordova/CDV.h>

@interface CDVHostBridge : CDVPlugin
- (void)emitEventToReactNative:(CDVInvokedUrlCommand*)command;
- (void)startReceivingFromReactNative:(CDVInvokedUrlCommand*)command;
- (void)stopReceivingFromReactNative:(CDVInvokedUrlCommand*)command;
- (void)openReactNativeShell:(CDVInvokedUrlCommand*)command;
@end