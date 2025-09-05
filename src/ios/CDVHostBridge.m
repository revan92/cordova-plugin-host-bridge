#import "CDVHostBridge.h"
#import <Foundation/Foundation.h>

// HB notification names (unchanged)
static NSString * const HBNotifyEmitToRN      = @"HBNotifyEmitToRN";      // Cordova -> RN
static NSString * const HBNotifyEmitToCordova = @"HBNotifyEmitToCordova"; // RN -> Cordova
static NSString * const HBNotifyCordovaReady  = @"HBNotifyCordovaReady";  // Cordova stream ready
static NSString * const HBNotifyOpenRNShell   = @"HBNotifyOpenRNShell";   // Request to open RN

@interface CDVHostBridge ()
@property (nonatomic, copy) NSString *streamCallbackId;
@property (nonatomic, assign) BOOL isStreaming;
@property (nonatomic, strong) id emitObserver; // cleanup token
@end

@implementation CDVHostBridge

- (void)pluginInitialize {
  [super pluginInitialize];
  __weak typeof(self) weakSelf = self;
  self.emitObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:HBNotifyEmitToCordova
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
      if (!weakSelf || !weakSelf.isStreaming || !weakSelf.streamCallbackId) return;
      NSDictionary *payload = note.userInfo ?: @{};
      CDVPluginResult *res =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
      [res setKeepCallbackAsBool:YES];
      [weakSelf.commandDelegate sendPluginResult:res callbackId:weakSelf.streamCallbackId];
  }];
}

- (void)dealloc {
  if (self.emitObserver) {
    [[NSNotificationCenter defaultCenter] removeObserver:self.emitObserver];
  }
}

#pragma mark - Cordova -> RN

- (void)emitEventToReactNative:(CDVInvokedUrlCommand*)command {
  NSString *eventName   = (command.arguments.count > 0 && [command.arguments[0] isKindOfClass:NSString.class]) ? command.arguments[0] : @"";
  NSDictionary *payload = (command.arguments.count > 1 && [command.arguments[1] isKindOfClass:NSDictionary.class]) ? command.arguments[1] : @{};
  NSNumber *openIfNeeded= (command.arguments.count > 2 && [command.arguments[2] isKindOfClass:NSNumber.class])   ? command.arguments[2] : @(YES);
  NSString *route       = (command.arguments.count > 3 && [command.arguments[3] isKindOfClass:NSString.class])   ? command.arguments[3] : nil;
  NSDictionary *params  = (command.arguments.count > 4 && [command.arguments[4] isKindOfClass:NSDictionary.class]) ? command.arguments[4] : nil;

  if (eventName.length == 0) {
    CDVPluginResult *bad = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing event name"];
    [self.commandDelegate sendPluginResult:bad callbackId:command.callbackId];
    return;
  }

  NSMutableDictionary *info = [@{ @"event":eventName, @"payload":payload, @"openIfNeeded":openIfNeeded } mutableCopy];
  if (route)  info[@"route"] = route;
  if (params) info[@"routeParams"] = params;

  [[NSNotificationCenter defaultCenter] postNotificationName:HBNotifyEmitToRN object:nil userInfo:info];

  CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
}

#pragma mark - RN -> Cordova stream

- (void)startReceivingFromReactNative:(CDVInvokedUrlCommand*)command {
  self.streamCallbackId = command.callbackId;
  self.isStreaming = YES;

  // Tell host we’re ready (host may flush a queued backlog)
  [[NSNotificationCenter defaultCenter] postNotificationName:HBNotifyCordovaReady object:nil];

  CDVPluginResult *res =
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"type":@"subscribed"}];
  [res setKeepCallbackAsBool:YES];
  [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)stopReceivingFromReactNative:(CDVInvokedUrlCommand*)command {
  self.isStreaming = NO;
  self.streamCallbackId = nil;
  CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
}

#pragma mark - Show RN UI

- (void)openReactNativeShell:(CDVInvokedUrlCommand*)command {
  NSString *route      = (command.arguments.count > 0 && [command.arguments[0] isKindOfClass:NSString.class]) ? command.arguments[0] : nil;
  NSDictionary *params = (command.arguments.count > 1 && [command.arguments[1] isKindOfClass:NSDictionary.class]) ? command.arguments[1] : nil;

  NSMutableDictionary *info = [NSMutableDictionary dictionary];
  if (route)  info[@"route"] = route;
  if (params) info[@"routeParams"] = params;

  [[NSNotificationCenter defaultCenter] postNotificationName:HBNotifyOpenRNShell
                                                      object:nil
                                                    userInfo:info];

  CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
}

@end