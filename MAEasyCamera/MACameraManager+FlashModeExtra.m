//
//  MACameraManager+FlashModeExtra.m
//
//  Created by YURI_JOU on 15-4-7.
//

#import "MACameraManager+FlashModeExtra.h"

@implementation MACameraManager (FlashModeExtra)

- (void)switchFlashModeToOff{
  if (self.videoDevice.flashAvailable) {
    self.videoDevice.flashMode = AVCaptureFlashModeOff;
  }
}

- (void)switchFlashModeToOn{
  if (self.videoDevice.flashAvailable) {
    self.videoDevice.flashMode = AVCaptureFlashModeOn;
  }
}

- (void)switchFlashModeToAuto{
  if (self.videoDevice.flashAvailable) {
    self.videoDevice.flashMode = AVCaptureFlashModeAuto;
  }
}

- (void)switchFlashMode:(void(^)(AVCaptureFlashMode captureMode))completion{
  if (!self.videoDevice.flashAvailable) {
    return;
  }
  NSError *error;
  if ([self.videoDevice lockForConfiguration:&error]) {
    switch (self.videoDevice.flashMode) {
      case AVCaptureFlashModeAuto:
        self.videoDevice.flashMode = AVCaptureFlashModeOff;
        break;
      case AVCaptureFlashModeOff:
        self.videoDevice.flashMode = AVCaptureFlashModeOn;
        break;
      case AVCaptureFlashModeOn:
        self.videoDevice.flashMode = AVCaptureFlashModeAuto;
        break;
      default:
        break;
    }
    if (completion) {
      completion(self.videoDevice.flashMode);
    }

    [self.videoDevice unlockForConfiguration];
  }
}

- (void)switchTorchModeToOn{
  if (self.videoDevice.torchAvailable) {
    self.videoDevice.torchMode = AVCaptureTorchModeOn;
  }
}

- (void)switchTorchModeToOff{
  if (self.videoDevice.torchAvailable) {
    self.videoDevice.torchMode = AVCaptureTorchModeOff;
  }
}

- (void)switchTorchModeToAtuto{
  if (self.videoDevice.torchAvailable) {
    self.videoDevice.torchMode = AVCaptureTorchModeAuto;
  }
}

- (void)switchTorchMode:(void(^)(AVCaptureTorchMode torchMode))completion{
  if (!self.videoDevice.torchAvailable) {
    return;
  }
  switch (self.videoDevice.flashMode) {
    case AVCaptureTorchModeAuto:
      self.videoDevice.torchMode = AVCaptureFlashModeOff;
      break;
    case AVCaptureTorchModeOff:
      self.videoDevice.torchMode = AVCaptureTorchModeOn;
      break;
    case AVCaptureTorchModeOn:
      self.videoDevice.torchMode = AVCaptureTorchModeAuto;
      break;
    default:
      break;
  }
  if (completion) {
    completion(self.videoDevice.torchMode);
  }
}

@end
