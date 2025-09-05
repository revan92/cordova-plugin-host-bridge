// www/hostbridge.js
var exec = require('cordova/exec');

// Prefer the canonical service name "HostBridge"; keep a legacy fallback if needed.
var SERVICE = 'HostBridge';

function call(action, args, ok, err) {
  exec(ok || null, err || null, SERVICE, action, args || []);
}

// ===== Native calls (symmetric with RN) =====
exports.openCordovaShell = function(route, params, ok, err) {
  call('openCordovaShell', [route || null, params || null], ok, err);
};

exports.openReactNativeShell = function(route, params, ok, err) {
  call('openReactNativeShell', [route || null, params || null], ok, err);
};

exports.emitToReactNative = function(event, payload, ok, err) {
  call('emitToReactNative', [event || '', payload || {}], ok, err);
};

// ===== Single DOM event stream: HBEvent =====
// iOS injects: window.dispatchEvent(new CustomEvent('HBEvent', { detail: {...} }))
// Shapes you may receive in Cordova:
//  { type:'visibility', active:'cordova'|'rn' }
//  { type:'rn', event:string, payload?:object }
//  { type:'navigate', route?:string, params?:object }  // if host emits for Cordova too
var _handlers = new Set();

function _domListener(e) {
  var msg = (e && e.detail) || {};
  _handlers.forEach(function(h) {
    try { h(msg); } catch (err) { console.error('[HostBridge] handler error', err); }
  });
}

// Ensure single registration per page
if (!window.__hbDomWired) {
  window.addEventListener('HBEvent', _domListener);
  window.__hbDomWired = true;
}

// Subscribe / Unsubscribe
exports.onEvent = function(handler) {
  if (typeof handler === 'function') _handlers.add(handler);
  return function off() { _handlers.delete(handler); };
};
exports.offEvent = function(handler) { _handlers.delete(handler); };

// Optional convenience helpers
exports.onVisibility = function(handler) {
  return exports.onEvent(function(msg) {
    if (msg && msg.type === 'visibility') handler(msg.active);
  });
};
exports.onFromRN = function(handler) {
  return exports.onEvent(function(msg) {
    if (msg && msg.type === 'rn') handler(msg.event, msg.payload);
  });
};
exports.onNavigate = function(handler) {
  return exports.onEvent(function(msg) {
    if (msg && msg.type === 'navigate') handler(msg.route, msg.params);
  });
};