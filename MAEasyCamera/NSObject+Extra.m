//
//  NSObject+Extra.m
//  Overseas
//
//  Created by YURI_JOU on 15-3-14.
//

#import "NSObject+Extra.h"
#import <objc/runtime.h>

static const void *kObserverTargetMappings = &kObserverTargetMappings;

@implementation NSObject (Extra)
@dynamic observerTargetMappings;

- (NSMutableDictionary *)observerTargetMappings
{
  NSMutableDictionary *dict = objc_getAssociatedObject(self, kObserverTargetMappings);
  if (!dict) {
    dict = [NSMutableDictionary dictionary];
    [self setObserverTargetMappings:dict];
  }
  return dict;
}

- (void)setObserverTargetMappings:(NSMutableDictionary *)observerTargetMappings
{
  objc_setAssociatedObject(self, kObserverTargetMappings, observerTargetMappings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


+ (void)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel
{
  IMP originalIMP = class_getMethodImplementation([self class], origSel);
  IMP alterIMP = class_getMethodImplementation([self class], altSel);
  Method originalMethod = class_getInstanceMethod([self class],origSel);
  Method alterMethod = class_getInstanceMethod([self class], altSel);
  method_setImplementation(alterMethod, originalIMP);
  method_setImplementation(originalMethod, alterIMP);
}

+ (void)load
{
  [self swizzleMethod:@selector(yg_observeValueForKeyPath:ofObject:change:context:)
           withMethod:@selector(observeValueForKeyPath:ofObject:change:context:)];
}

- (void)yg_addObserver:(NSObject *)observer
           forKeyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
              context:(void *)context
{
  
  if (self.observerTargetMappings[keyPath] == observer) return;

  [self addObserver:observer forKeyPath:keyPath options:options context:context];
  self.observerTargetMappings[keyPath] = observer;
}

- (void)yg_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
{
  if (![self.observerTargetMappings.allKeys containsObject:keyPath]) return;
  
  [self.observerTargetMappings removeObjectForKey:keyPath];
  [self removeObserver:observer forKeyPath:keyPath];
}

- (void) yg_observeValueForKeyPath:(NSString *)keyPath
                          ofObject:(id)object
                            change:(NSDictionary *)change
                           context:(void *)context
{
  if (!self) return;
  
  if (!self.observerTargetMappings[keyPath])
  {
    [self yg_removeObserver:self.observerTargetMappings[keyPath] forKeyPath:keyPath];
    return;
  }
  [self yg_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
