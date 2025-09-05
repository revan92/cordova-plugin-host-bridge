#import "CDVHostBridge.h"

@implementation CDVHostBridge

- (void)emitToReactNative:(CDVInvokedUrlCommand*)command {
  NSString *event = [command argumentAtIndex:0 withDefault:@""];
  NSDictionary *payload = [command argumentAtIndex:1 withDefault:@{}];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"HBNotifyEmitToRN"
                                                      object:nil
                                                    userInfo:@{@"event":event ?: @"", @"payload":payload ?: @{}}];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                              callbackId:command.callbackId];
}

- (void)openReactNativeShell:(CDVInvokedUrlCommand*)command {
  id route  = [command argumentAtIndex:0 withDefault:nil];
  id params = [command argumentAtIndex:1 withDefault:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"HBRequestOpenRNShell"
                                                      object:nil
                                                    userInfo:@{@"route":route ?: [NSNull null],
                                                               @"params":params ?: @{}}];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                              callbackId:command.callbackId];
}

- (void)openCordovaShell:(CDVInvokedUrlCommand*)command {
  id route  = [command argumentAtIndex:0 withDefault:nil];
  id params = [command argumentAtIndex:1 withDefault:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"HBRequestOpenCordovaShell"
                                                      object:nil
                                                    userInfo:@{@"route":route ?: [NSNull null],
                                                               @"params":params ?: @{}}];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                              callbackId:command.callbackId];
}
@end