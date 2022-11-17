#import <React/RCTBridge+Private.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTFabricSurface.h>
#import <React/RCTScheduler.h>
#import <React/RCTSurface.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTSurfacePresenterBridgeAdapter.h>
#import <React/RCTSurfaceView.h>
#endif

#import <RNReanimated/NativeProxy.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <RNReanimated/NewestShadowNodesRegistry.h>
#import <RNReanimated/REAInitializerRCTFabricSurface.h>
#import <RNReanimated/ReanimatedCommitHook.h>
#import <RNReanimated/ReanimatedUIManagerBinding.h>
#endif

#import <RNReanimated/REAModule.h>
#import <RNReanimated/REANodesManager.h>
#import <RNReanimated/REASnapshot.h>
#import <RNReanimated/SingleInstanceChecker.h>

// #include <algorithm>

using namespace facebook::react;
using namespace reanimated;

@interface RCTBridge (JSIRuntime)
- (void *)runtime;
@end

@interface RCTBridge (RCTTurboModule)
- (std::shared_ptr<facebook::react::CallInvoker>)jsCallInvoker;
- (void)_tryAndHandleError:(dispatch_block_t)block;
@end

#ifdef RCT_NEW_ARCH_ENABLED
static __strong REAInitializerRCTFabricSurface *reaSurface;
#else
typedef void (^AnimatedOperation)(REANodesManager *nodesManager);
#endif

@implementation REAModule {
#ifdef RCT_NEW_ARCH_ENABLED
  __weak RCTSurfacePresenter *_surfacePresenter;
  __weak RCTUIManager *_uiManager; // viewForReactTag
  std::shared_ptr<NewestShadowNodesRegistry> newestShadowNodesRegistry;
  std::weak_ptr<NativeReanimatedModule> reanimatedModule_;
  std::shared_ptr<EventListener> eventListener_;
  std::shared_ptr<ReanimatedCommitHook> commitHook_; // for observing shadow tree changes
#else
  NSMutableArray<AnimatedOperation> *_operations;
#endif
#ifdef DEBUG
  SingleInstanceChecker<REAModule> singleInstanceChecker_;
#endif
  bool hasListeners;
}

RCT_EXPORT_MODULE(ReanimatedModule);

#ifdef RCT_NEW_ARCH_ENABLED
+ (BOOL)requiresMainQueueSetup
{
  return YES;
}
#endif // RCT_NEW_ARCH_ENABLED

- (void)invalidate
{
#ifdef RCT_NEW_ARCH_ENABLED
  RCTScheduler *scheduler = [_surfacePresenter scheduler];
  [scheduler removeEventListener:eventListener_];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.bridge.surfacePresenter removeObserver:self];
#endif
  [_nodesManager invalidate];
  [super invalidate];
}

- (dispatch_queue_t)methodQueue
{
  // This module needs to be on the same queue as the UIManager to avoid
  // having to lock `_operations` and `_preOperations` since `uiManagerWillPerformMounting`
  // will be called from that queue.
  return RCTGetUIManagerQueue();
}

#ifdef RCT_NEW_ARCH_ENABLED

- (std::shared_ptr<UIManager>)getUIManager
{
  RCTScheduler *scheduler = [_surfacePresenter scheduler];
  return scheduler.uiManager;
}

- (void)injectReanimatedUIManagerBinding:(jsi::Runtime &)runtime uiManager:(std::shared_ptr<UIManager>)uiManager
{
  RuntimeExecutor syncRuntimeExecutor = [&](std::function<void(jsi::Runtime & runtime_)> &&callback) {
    callback(runtime);
  };
  ReanimatedUIManagerBinding::createAndInstallIfNeeded(
      runtime, syncRuntimeExecutor, uiManager, newestShadowNodesRegistry);
}

- (void)setUpNativeReanimatedModule:(std::shared_ptr<UIManager>)uiManager
{
  if (auto reanimatedModule = reanimatedModule_.lock()) {
    reanimatedModule->setUIManager(uiManager);
    reanimatedModule->setNewestShadowNodesRegistry(newestShadowNodesRegistry);
  }
}

- (void)injectDependencies:(jsi::Runtime &)runtime
{
  auto uiManager = [self getUIManager];
  react_native_assert(uiManager.get() != nil);
  newestShadowNodesRegistry = std::make_shared<NewestShadowNodesRegistry>();
#ifdef RCT_NEW_ARCH_ENABLED
  std::shared_ptr<LayoutAnimationsProxy> layoutAnimationsProxy;
  if (auto reanimatedModule = reanimatedModule_.lock()) {
    layoutAnimationsProxy = reanimatedModule->layoutAnimationsProxy_;
  }
  assert(layoutAnimationsProxy != nullptr);
  commitHook_ = std::make_shared<ReanimatedCommitHook>(layoutAnimationsProxy);
  uiManager->registerCommitHook(*commitHook_);
#endif // RCT_NEW_ARCH_ENABLED
  [self injectReanimatedUIManagerBinding:runtime uiManager:uiManager];
  [self setUpNativeReanimatedModule:uiManager];
}

#pragma mark-- Initialize

- (void)installReanimatedUIManagerBindingAfterReload
{
  // called from REAInitializerRCTFabricSurface::start
  __weak __typeof__(self) weakSelf = self;
  _surfacePresenter = self.bridge.surfacePresenter;
  [_nodesManager setSurfacePresenter:_surfacePresenter];

  // to avoid deadlock we can't use Executor from React Native
  // but we can create own and use it because initialization is already synchronized
  react_native_assert(self.bridge != nil);
  RCTRuntimeExecutorFromBridge(self.bridge)(^(jsi::Runtime &runtime) {
    if (__typeof__(self) strongSelf = weakSelf) {
      [strongSelf injectDependencies:runtime];
    }
  });
}

- (void)handleJavaScriptDidLoadNotification:(NSNotification *)notification
{
  _surfacePresenter = self.bridge.surfacePresenter;
  RCTScheduler *scheduler = [_surfacePresenter scheduler];
  __weak __typeof__(self) weakSelf = self;
  _surfacePresenter.runtimeExecutor(^(jsi::Runtime &runtime) {
    __typeof__(self) strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    if (auto reanimatedModule = strongSelf->reanimatedModule_.lock()) {
      self->eventListener_ =
          std::make_shared<facebook::react::EventListener>([reanimatedModule](const RawEvent &rawEvent) {
            if (!RCTIsMainQueue()) {
              // event listener called on the JS thread, let's ignore this event
              // as we cannot safely access worklet runtime here
              // and also we don't care about topLayout events
              return false;
            }
            return reanimatedModule->handleRawEvent(rawEvent, CACurrentMediaTime() * 1000);
          });
      [scheduler addEventListener:self->eventListener_];
    }
  });
}

- (void)setBridge:(RCTBridge *)bridge
{
  [super setBridge:bridge];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleJavaScriptDidLoadNotification:)
                                               name:RCTJavaScriptDidLoadNotification
                                             object:nil];

  [[self.moduleRegistry moduleForName:"EventDispatcher"] addDispatchObserver:self];

#ifdef RCT_NEW_ARCH_ENABLED
  [bridge.surfacePresenter addObserver:self];
  _uiManager = bridge.uiManager;
#else
  [bridge.uiManager.observerCoordinator addObserver:self];
#endif

  // only within the first loading `self.bridge.surfacePresenter` exists
  // during the reload `self.bridge.surfacePresenter` is null
  _surfacePresenter = self.bridge.surfacePresenter;
#ifdef DEBUG
  if (reaSurface == nil) {
    // we need only one instance because SurfacePresenter is the same during the application lifetime
    reaSurface = [[REAInitializerRCTFabricSurface alloc] init];
    [_surfacePresenter registerSurface:reaSurface];
  }
  reaSurface.reaModule = self;
#endif

  if (_surfacePresenter == nil) {
    // _surfacePresenter will be set in installReanimatedUIManagerBindingAfterReload
    _nodesManager = [[REANodesManager alloc] initWithModule:self bridge:self.bridge surfacePresenter:nil];
    return;
  }

  _nodesManager = [[REANodesManager alloc] initWithModule:self bridge:self.bridge surfacePresenter:_surfacePresenter];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(installTurboModule)
{
  facebook::jsi::Runtime *jsiRuntime = [self.bridge respondsToSelector:@selector(runtime)]
      ? reinterpret_cast<facebook::jsi::Runtime *>(self.bridge.runtime)
      : nullptr;

  if (jsiRuntime) {
    // Reanimated
    jsi::Runtime &runtime = *jsiRuntime;

    auto reanimatedModule = reanimated::createReanimatedModule(self.bridge, self.bridge.jsCallInvoker);

    auto workletRuntimeValue = runtime.global()
                                   .getProperty(runtime, "ArrayBuffer")
                                   .asObject(runtime)
                                   .asFunction(runtime)
                                   .callAsConstructor(runtime, {static_cast<double>(sizeof(void *))});
    uintptr_t *workletRuntimeData =
        reinterpret_cast<uintptr_t *>(workletRuntimeValue.getObject(runtime).getArrayBuffer(runtime).data(runtime));
    workletRuntimeData[0] = reinterpret_cast<uintptr_t>(reanimatedModule->runtime.get());

    runtime.global().setProperty(runtime, "_WORKLET_RUNTIME", workletRuntimeValue);

    runtime.global().setProperty(runtime, "_IS_FABRIC", true);

    runtime.global().setProperty(
        runtime,
        jsi::PropNameID::forAscii(runtime, "__reanimatedModuleProxy"),
        jsi::Object::createFromHostObject(runtime, reanimatedModule));
    reanimatedModule_ = reanimatedModule;
    if (_surfacePresenter != nil) {
      // reload, uiManager is null right now, we need to wait for `installReanimatedUIManagerBindingAfterReload`
      [self injectDependencies:runtime];
    }
  }
  return nil;
}

#else

RCT_EXPORT_METHOD(installTurboModule)
{
  // TODO: Move initialization from UIResponder+Reanimated to here
}

- (void)setBridge:(RCTBridge *)bridge
{
  [super setBridge:bridge];

  _nodesManager = [[REANodesManager alloc] initWithModule:self uiManager:self.bridge.uiManager];
  _operations = [NSMutableArray new];

#ifdef RN_FABRIC_ENABLED
  [bridge.surfacePresenter addObserver:self];
#else
  [bridge.uiManager.observerCoordinator addObserver:self];
#endif // RN_FABRIC_ENABLED
}

#pragma mark-- Batch handling

- (void)addOperationBlock:(AnimatedOperation)operation
{
  [_operations addObject:operation];
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerWillPerformMounting:(RCTUIManager *)uiManager
{
  [_nodesManager maybeFlushUpdateBuffer];
  if (_operations.count == 0) {
    return;
  }

  NSArray<AnimatedOperation> *operations = _operations;
  _operations = [NSMutableArray new];

  REANodesManager *nodesManager = _nodesManager;

  [uiManager addUIBlock:^(__unused RCTUIManager *manager, __unused NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    for (AnimatedOperation operation in operations) {
      operation(nodesManager);
    }
    [nodesManager operationsBatchDidComplete];
  }];
}

#endif // RCT_NEW_ARCH_ENABLED

#pragma mark-- Events

- (NSArray<NSString *> *)supportedEvents
{
  return @[ @"onReanimatedCall", @"onReanimatedPropsChange" ];
}

- (void)eventDispatcherWillDispatchEvent:(id<RCTEvent>)event
{
  // Events can be dispatched from any queue
  [_nodesManager dispatchEvent:event];
}

- (void)startObserving
{
  hasListeners = YES;
}

- (void)stopObserving
{
  hasListeners = NO;
}

- (void)sendEventWithName:(NSString *)eventName body:(id)body
{
  if (hasListeners) {
    [super sendEventWithName:eventName body:body];
  }
}

#pragma mark - RCTSurfacePresenterObserver

#ifdef RCT_NEW_ARCH_ENABLED

// // TODO: generalize for more instances
// static REASnapshot *beforeSnapshot;
// static UIView *removedView;

- (void)willMountComponentsWithRootTag:(NSInteger)rootTag
{
  RCTAssertMainQueue();

  [CATransaction begin];
  // this transaction wraps transaction inside RCTPerformMountInstructions
  // because we don't want to splash view for a single frame before entering/layout animations starts

  // if (auto reanimatedModule = reanimatedModule_.lock()) {
  //   // layout animations
  //   {
  //     const auto &tags = reanimatedModule->layoutAnimationsProxy_->tagsOfUpdatedViews_;
  //     for (auto tag : tags) {
  //       UIView *view = [_uiManager viewForReactTag:@(tag)];
  //       REASnapshot *snapshot = [[REASnapshot alloc] init:view];
  //       beforeSnapshot = snapshot; // TODO: remove beforeSnapshot
  //     }
  //   }

  //   // exiting animations
  //   {
  //     const auto &tags = reanimatedModule->layoutAnimationsProxy_->tagsOfRemovedViews_;
  //     for (auto tag : tags) {
  //       UIView *view = [_uiManager viewForReactTag:@(tag)];
  //       view.reactTag = @(tag);
  //       REASnapshot *snapshot = [[REASnapshot alloc] init:view];
  //       beforeSnapshot = snapshot; // TODO: remove beforeSnapshot
  //       removedView = [view snapshotViewAfterScreenUpdates:NO];
  //       removedView.frame = view.frame;
  //     }
  //   }
  // }
}

- (void)didMountComponentsWithRootTag:(NSInteger)rootTag
{
  RCTAssertMainQueue();

  // if (auto reanimatedModule = reanimatedModule_.lock()) {
  //   // entering animations
  //   {
  //     const auto &tags = reanimatedModule->layoutAnimationsProxy_->tagsOfCreatedViews_;
  //     for (auto tag : tags) {
  //       UIView *view = [_uiManager viewForReactTag:@(tag)];
  //       view.reactTag = @(tag);
  //       REASnapshot *afterSnapshot = [[REASnapshot alloc] init:view];
  //       [self.nodesManager.animationsManager onViewCreate:view after:afterSnapshot];
  //     }
  //     reanimatedModule->layoutAnimationsProxy_->tagsOfCreatedViews_.clear();
  //   }

  //   // layout animations
  //   {
  //     const auto &tags = reanimatedModule->layoutAnimationsProxy_->tagsOfUpdatedViews_;
  //     for (auto tag : tags) {
  //       UIView *view = [_uiManager viewForReactTag:@(tag)];
  //       REASnapshot *afterSnapshot = [[REASnapshot alloc] init:view];
  //       [self.nodesManager.animationsManager onViewUpdate:view before:beforeSnapshot after:afterSnapshot];
  //     }
  //     reanimatedModule->layoutAnimationsProxy_->tagsOfUpdatedViews_.clear();
  //   }

  //   // exiting animations
  //   {
  //     const auto &tags = reanimatedModule->layoutAnimationsProxy_->tagsOfRemovedViews_;
  //     for (auto tag : tags) {
  //       UIView *windowView = UIApplication.sharedApplication.keyWindow;
  //       [windowView addSubview:removedView];
  //       removedView.reactTag = @(tag);
  //       // TODO: fix exiting animations
  //       // [self.nodesManager.animationsManager onViewRemoval:removedView before:beforeSnapshot];
  //     }
  //     reanimatedModule->layoutAnimationsProxy_->tagsOfRemovedViews_.clear();
  //   }
  // }

  [CATransaction commit];
}

#endif // RCT_NEW_ARCH_ENABLED

@end
