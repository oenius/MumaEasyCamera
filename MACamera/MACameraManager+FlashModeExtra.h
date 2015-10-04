//
//  MACameraManager+FlashModeExtra.h
//
//  Created by YURI_JOU on 15-4-7.
//

#import "MACameraManager.h"

@interface MACameraManager (FlashModeExtra)

- (void)switchFlashModeToOff;
- (void)switchFlashModeToOn;
- (void)switchFlashModeToAuto;
- (void)switchFlashMode:(void(^)(AVCaptureFlashMode flashMode))completion;

- (void)switchTorchModeToOn;
- (void)switchTorchModeToOff;
- (void)switchTorchModeToAtuto;
- (void)switchTorchMode:(void(^)(AVCaptureTorchMode torchMode))completion;

@end
