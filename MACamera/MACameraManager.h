//
//  MACaptureManager.h
//
//  Created by YURI_JOU on 15-4-1.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MACameraType) {
  MACameraTypeVideo       = -1,
  MACameraTypePhoto       = 1,
  MACameraTypeUnknown     = 2,
};

@interface MACameraManager : NSObject

@property (nonatomic, readonly) AVCaptureDevice *videoDevice;
@property (nonatomic, readonly) MACameraType cameraType;

@property (nonatomic, readonly) CALayer *cameraLayer;

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, readonly) CALayer *filterLayer;


+ (instancetype)manager;

- (void)switchCameraToBack;
- (void)switchCameraToFront;
- (void)switchCamera:(void (^)(void))completion;

- (void)snap:(void(^)(UIImage *image)) completion;

- (void)startRecord:(NSURL *)filePath;
- (void)pauseRecord;
- (void)resumeRecord;
- (void)stopRecord;
- (void)cancelRecord;

@end
