//
//  UIView+Extra.h
//  Overseas
//
//  Created by YURI_JOU on 15-3-6.
//

#import <UIKit/UIKit.h>

@interface UIView (Extra)

- (void)setCenterX:(CGFloat)centerX;
- (void)setCenterY:(CGFloat)centerY;

- (void)setFrameOriginX:(CGFloat)originX;
- (void)setFrameOriginY:(CGFloat)originY;

- (void)setFrameWidth:(CGFloat)width;
- (void)setFrameHeight:(CGFloat)height;

- (void)setFrameOriginPoint:(CGPoint)originPoint;
- (void)setFrameSize:(CGSize)size;

- (void)setBoundsOriginX:(CGFloat)originX;
- (void)setBoundsOriginY:(CGFloat)originY;

- (void)setBoundsWidth:(CGFloat)width;
- (void)setBoundsHeight:(CGFloat)height;

- (void)setBoundsOriginPoint:(CGPoint)originPoint;
- (void)setBoundsSize:(CGSize)size;

- (void)removeAllSubViews;
- (void)setNeedEndEditing;

- (NSArray *)subviewsForClassName:(Class)className;

- (NSArray *)subviewsForClassName:(Class)className tag:(NSInteger)tag;

- (void)logViewHierarchy;

+ (void)setAnimationPosition:(CGPoint)p ; 

@end
