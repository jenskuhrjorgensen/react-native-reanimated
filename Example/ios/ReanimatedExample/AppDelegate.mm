#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <RNReanimated/WorkletRuntime.h>

@implementation AppDelegate

std::shared_ptr<reanimated::WorkletRuntime> workletRuntime;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"ReanimatedExample";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};
  
  jsi::Runtime& runtime = *(jsi::Runtime*)"@123";
  jsi::Value value = jsi::Value(42);
  auto rt = reanimated::extractWorkletRuntime(runtime, value);
  jsi::Runtime &rtt = rt->getJSIRuntime();
  auto worklet = reanimated::extractShareableOrThrow<reanimated::ShareableWorklet>(rtt, value);
  workletRuntime = reanimated::extractWorkletRuntime(runtime, value.asObject(runtime));
  std::weak_ptr<reanimated::WorkletRuntime> weakWorkletRuntime = workletRuntime;
  auto workletRuntime = weakWorkletRuntime.lock();
  workletRuntime->runGuarded(worklet);
  
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}



- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
