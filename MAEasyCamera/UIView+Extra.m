//
//  UIView+Extra.m
//  Overseas
//
//  Created by YURI_JOU on 15-3-6.
//

#import "UIView+Extra.h"

@interface UIView()<UIGestureRecognizerDelegate>

@end

@implementation UIView (Extra)

- (void) setCenterX:(CGFloat)centerX {
  CGPoint center = self.center;
  center.x = centerX;
  self.center = center;
}

- (void) setCenterY:(CGFloat)centerY {
  CGPoint center = self.center;
  center.y = centerY;
  self.center = center;
}

- (void) setFrameOriginX:(CGFloat)originX {
  CGRect originFrame = self.frame;
  originFrame.origin.x = originX;
  self.frame = originFrame;
}

- (void) setFrameOriginY:(CGFloat)originY {
  CGRect originFrame = self.frame;
  originFrame.origin.y = originY;
  self.frame = originFrame;
}

- (void) setFrameWidth:(CGFloat)width {
  CGRect originFrame = self.frame;
  originFrame.size.width = width;
  self.frame = originFrame;
}

- (void) setFrameHeight:(CGFloat)height {
  CGRect originFrame = self.frame;
  originFrame.size.height = height;
  self.frame = originFrame;
}

- (void) setFrameOriginPoint:(CGPoint)originPoint {
  CGRect originFrame = self.frame;
  originFrame.origin = originPoint;
  self.frame = originFrame;
}

- (void) setFrameSize:(CGSize)size {
  CGRect originFrame = self.frame;
  originFrame.size = size;
  self.frame = originFrame;
}

- (void) setBoundsOriginX:(CGFloat)originX {
  CGRect originFrame = self.bounds;
  originFrame.origin.x = originX;
  self.bounds = originFrame;
}

- (void) setBoundsOriginY:(CGFloat)originY {
  CGRect originFrame = self.bounds;
  originFrame.origin.y = originY;
  self.bounds = originFrame;
}

- (void) setBoundsWidth:(CGFloat)width {
  CGRect originFrame = self.bounds;
  originFrame.size.width = width;
  self.bounds = originFrame;
}

- (void) setBoundsHeight:(CGFloat)height {
  CGRect originFrame = self.bounds;
  originFrame.size.height = height;
  self.bounds = originFrame;
}

- (void) setBoundsOriginPoint:(CGPoint)originPoint {
  CGRect originFrame = self.bounds;
  originFrame.origin = originPoint;
  self.bounds = originFrame;
}

- (void) setBoundsSize:(CGSize)size {
  CGRect originFrame = self.bounds;
  originFrame.size = size;
  self.bounds = originFrame;
}

#pragma mark - subviews
- (void) removeAllSubViews {
  while ([self.subviews count] != 0) {
    UIView *subView = [self.subviews lastObject];
    [subView removeFromSuperview];
  }
}

- (NSArray *)subviewsForClassName:(Class)className {
  NSMutableArray *someSubviews = [NSMutableArray array];
  for(id subview in self.subviews) {
    if ([subview isKindOfClass:className]) {
      [someSubviews addObject:subview];
    }
  }
  return someSubviews;
}

- (NSArray *)subviewsForClassName:(Class)className tag:(NSInteger)tag {
  NSArray *subviews = [self subviewsForClassName:className];
  NSMutableArray *tagSubViews = [NSMutableArray array];
  for (UIView *subview in subviews) {
    if (subview.tag == tag) {
      [tagSubViews addObject:subview];
    }
  }
  return tagSubViews;
}

- (void) setNeedEndEditing{
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleEndEditing:)];
  [self addGestureRecognizer:tapGesture];
}
- (void)handleEndEditing:(UIGestureRecognizer *)gesture{
  [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

#pragma mark - debug
- (void)logViewHierarchy {
  [self _logViewHierarchyAtLevel:0];
}

- (void)_logViewHierarchyAtLevel:(int)level {
  for (int index = 0; index < level; ++index) {
    printf("  ");
  }
  printf("%s\n", [[self description] cStringUsingEncoding:NSUTF8StringEncoding]);
  for (UIView *subview in self.subviews) {
    [subview _logViewHierarchyAtLevel:(level + 1)];
  }
}

@end
