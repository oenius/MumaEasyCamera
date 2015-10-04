//
//  MACameraView.m
//
//  Created by YURI_JOU on 15-4-2.
//

#import "MACameraView.h"

@implementation MACameraView

- (instancetype)initWithCameraLayer:(CALayer *)layer{
  self = [super initWithFrame:CGRectZero];
  if (self) {
    self.cameraLayer = layer;
    self.cameraLayer.masksToBounds = YES;
    self.clipsToBounds = YES;
  }
  return self;
}

- (void)setCameraLayer:(CALayer *)cameraLayer{
  [self.layer insertSublayer:cameraLayer atIndex:0];
  _cameraLayer = cameraLayer;
  [self setNeedsLayout];
}


- (void)layoutSubviews{
  [super layoutSubviews];
  self.cameraLayer.frame = self.layer.bounds;
}

@end
