//
//  UIControl+Extra.m
//  Overseas
//
//  Created by YURI_JOU on 15-3-13.
//

#import "UIControl+Extra.h"
#import <objc/runtime.h>

static const void *kEventDict = &kEventDict;
@implementation UIControl (Extra)

@dynamic eventDict;

+ (void)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel
{
  IMP originalIMP = class_getMethodImplementation([self class], origSel);
  IMP alterIMP = class_getMethodImplementation([self class], altSel);
  Method originalMethod = class_getInstanceMethod([self class],origSel);
  Method alterMethod = class_getInstanceMethod([self class], altSel);
  method_setImplementation(alterMethod, originalIMP);
  method_setImplementation(originalMethod, alterIMP);
}

#pragma mark - switch method
+ (void)load{
  [self.class swizzleMethod:@selector(sendAction:to:forEvent:)
                 withMethod:@selector(__sendAction:to:forEvent:)];
}



#pragma mark - accessor
- (void)setEventDict:(NSDictionary *)eventDict{
  objc_setAssociatedObject(self, kEventDict, eventDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSMutableDictionary *)eventDict{
  NSMutableDictionary *eventDict = objc_getAssociatedObject(self, kEventDict);
  if (!eventDict) {
    eventDict = [@{} mutableCopy];
    [self setEventDict:eventDict];
  }
  return eventDict;
}

#pragma mark - action block
- (void)addActionBlock:(void(^)(id sender)) block forControlEvents:(UIControlEvents)controlEvents{
  self.eventDict[@(controlEvents)] = block;
  SEL action = NSSelectorFromString([NSString stringWithFormat:@"%ld",controlEvents]);
  [self addTarget:self action:action forControlEvents:controlEvents];
}

- (void)removeActionBlockForControlEvents:(UIControlEvents)controlEvents{
  if ([[self.eventDict allKeys] containsObject:@(controlEvents)] ) {
    [self.eventDict removeObjectForKey:@(controlEvents)];
  }
  SEL action = NSSelectorFromString([NSString stringWithFormat:@"%ld",controlEvents]);
  [self removeTarget:self action:action forControlEvents:controlEvents];
}

- (void)__sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
  NSString *eventsDesc = NSStringFromSelector(action);
  UIControlEvents controlEvents = (UIControlEvents)([eventsDesc integerValue]);
  void(^block)(id sender)  = self.eventDict[@(controlEvents)];
  if (block) {
    block(self);
  }
  if ([target respondsToSelector:action]) {
    [self __sendAction:action to:target forEvent:event];
  }

}

- (void)setAlignmentToLeft{
  self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

- (void)setAlignmentToRight{
  self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)setAlignmentToTop{
  self.contentHorizontalAlignment = UIControlContentVerticalAlignmentTop;
}

- (void)setAlignmentToBottom{
  self.contentHorizontalAlignment = UIControlContentVerticalAlignmentBottom;
}

@end
