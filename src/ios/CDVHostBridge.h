#import <Cordova/CDVPlugin.h>

@interface CDVHostBridge : CDVPlugin
- (void)emitToReactNative:(CDVInvokedUrlCommand*)command;     // Cordova -> RN payload
- (void)openReactNativeShell:(CDVInvokedUrlCommand*)command;  // ask host to show RN
- (void)openCordovaShell:(CDVInvokedUrlCommand*)command;      // ask host to show Cordova
@end