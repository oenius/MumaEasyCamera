//
//  MACameraManager+FocusIntrestPointExtra.m
//
//  Created by YURI_JOU on 15-4-7.
//

#import "MACameraManager+FocusIntrestPointExtra.h"

@implementation MACameraManager (FocusIntrestPointExtra)

- (void)focusOnPoint:(CGPoint)point{
  CGPoint interestPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
  NSError *error;
  if([self.videoDevice lockForConfiguration:&error]){
    
    self.videoDevice.focusPointOfInterest = interestPoint;
    self.videoDevice.focusMode = AVCaptureFocusModeAutoFocus;
    [self.videoDevice unlockForConfiguration];
  }
}

@end
