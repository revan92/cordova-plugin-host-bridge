package com.cordova.hostbridge;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;

public class HostBridge extends CordovaPlugin {

  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext cb) throws JSONException {
    // No-op stub so Android builds don’t break if plugin is present.
    if ("emitEventToReactNative".equals(action)
        || "startReceivingFromReactNative".equals(action)
        || "stopReceivingFromReactNative".equals(action)
        || "openReactNativeShell".equals(action)) {
      cb.success(); // implement later in your Android host
      return true;
    }
    return false;
  }
}