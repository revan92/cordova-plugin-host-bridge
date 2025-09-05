var exec = require('cordova/exec');

var HostBridge = {
  emitEventToReactNative: function (event, payload, openIfNeeded, route, routeParams, ok, err) {
    exec(ok, err, "CDVHostBridge", "emitEventToReactNative",
         [event, payload || {}, !!openIfNeeded, route, routeParams]);
  },

  startReceivingFromReactNative: function (onEvent, onError) {
    exec(function (data) { onEvent && onEvent(data); },
         onError, "CDVHostBridge", "startReceivingFromReactNative", []);
  },

  stopReceivingFromReactNative: function (ok, err) {
    exec(ok, err, "CDVHostBridge", "stopReceivingFromReactNative", []);
  },

  openReactNativeShell: function (route, params, ok, err) {
    exec(ok, err, "CDVHostBridge", "openReactNativeShell", [route, params]);
  }
};

module.exports = HostBridge;