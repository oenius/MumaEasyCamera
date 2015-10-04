//
//  MACameraController.h
//
//  Created by YURI_JOU on 15-4-2.
//
#import <UIKit/UIKit.h>

@interface MACameraController : UIViewController

@property (nonatomic, copy) void(^cancelBlock)(UIViewController *controller);

@end
