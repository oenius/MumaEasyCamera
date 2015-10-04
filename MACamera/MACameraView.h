//
//  MACameraView.h
//
//  Created by YURI_JOU on 15-4-2.
//

#import <UIKit/UIKit.h>

@interface MACameraView : UIView

@property (nonatomic, strong)CALayer *cameraLayer;

- (instancetype)initWithCameraLayer:(CALayer *)layer;

@end
