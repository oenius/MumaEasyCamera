//
//  UIControl+Extra.h
//  Overseas
//
//  Created by YURI_JOU on 15-3-13.
//

#import <UIKit/UIKit.h>

@interface UIControl (Extra)

@property (nonatomic, strong) NSMutableDictionary *eventDict;

- (void)setAlignmentToLeft;

- (void)setAlignmentToRight;

- (void)setAlignmentToTop;

- (void)setAlignmentToBottom;

- (void)addActionBlock:(void(^)(id sender)) block forControlEvents:(UIControlEvents)controlEvents;

- (void)removeActionBlockForControlEvents:(UIControlEvents)controlEvents;


@end
