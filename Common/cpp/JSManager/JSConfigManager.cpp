#include "JSConfigManager.h"

namespace reanimated {

JSConfigManager::JSConfigManager(std::shared_ptr<JSRuntimeHelper> runtimeHelper)
  : runtimeHelper_(runtimeHelper) {}

void JSConfigManager::setConfigValue(const JSConfigType type, const jsi::Value &config) {
  auto &runtime = *runtimeHelper_->uiRuntime();
  if (type == JSConfigType::SHARED_TRANSITION_ANIMATION_TYPE) {
    setSharedTansitionConfig(runtime, config);
  }
}

jsi::Value JSConfigManager::getConfigValue(const JSConfigType type, const int key) {
  if (type == JSConfigType::SHARED_TRANSITION_ANIMATION_TYPE) {
    return jsi::Value(static_cast<int>(getSharedTansitionConfig(key)));
  }
  return jsi::Value::undefined();
}

void JSConfigManager::setSharedTansitionConfig(jsi::Runtime &rt, const jsi::Value &config) {
  jsi::Object configObject = config.asObject(rt);
  int key = configObject.getProperty(rt, "viewTag").asNumber();
  jsi::Value animationType = configObject.getProperty(rt, "animationType");
  if (animationType.isUndefined()) {
    sharedTransitionConfig_.erase(key);
    return;
  }
  sharedTransitionConfig_[key] = static_cast<SharedTransitionType>(animationType.asNumber());
}

SharedTransitionType JSConfigManager::getSharedTansitionConfig(const int key) {
  return sharedTransitionConfig_[key];
}

}
