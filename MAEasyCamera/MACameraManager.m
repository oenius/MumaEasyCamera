//
//  MACaptureManager.m
//
//  Created by YURI_JOU on 15-4-1.
//

#import "MACameraManager.h"
#import "MACameraEncoder.h"
#import "NSObject+Extra.h"
#import "UIImage+MAExtra.h"

#import <AssetsLibrary/ALAssetsLibrary.h>

@interface MACameraManager()
<
AVCaptureVideoDataOutputSampleBufferDelegate
>

@property (nonatomic, assign) MACameraType cameraType;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

@property (nonatomic, strong) AVCaptureDevice *audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutPut;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutPut;
@property (nonatomic, strong) dispatch_queue_t videoQueue;

@property (nonatomic, strong) CALayer *cameraLayer;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CALayer *filterLayer;

@property (nonatomic, strong) MACameraEncoder *encoder;
@property (nonatomic, assign) CMTime lastTime;

@property (nonatomic, assign) BOOL shouldRecord;
@property (nonatomic, assign) BOOL hasPaused;

@end

@implementation MACameraManager
static MACameraManager *shareInstance;
static void *kCameraLayerContext = &kCameraLayerContext;

+ (instancetype)manager{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shareInstance = [[MACameraManager alloc]init];
  });
  return shareInstance;
}

- (instancetype)init{
  self = [super init];
  if (self) {
    [self ma_safeAddInput:self.videoInput];
    [self ma_safeAddInput:self.audioInput];
    
//    [self ma_safeAddOutput:self.imageOutPut];
    [self ma_safeAddOutput:self.videoDataOutPut];
    [self.session addOutput:self.imageOutPut];
//    [self ma_safeAddOutput:self.movieOutPut];
    self.cameraType = MACameraTypePhoto;
    
    [self.cameraLayer addSublayer:self.filterLayer];
    [self.cameraLayer addSublayer:self.previewLayer];
    [self yg_addObserver:self forKeyPath:@"cameraLayer.bounds" options:NSKeyValueObservingOptionNew context:kCameraLayerContext];
    [self.session startRunning];
  }
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
  if (context == kCameraLayerContext) {
    self.previewLayer.frame = self.cameraLayer.bounds;
    self.filterLayer.frame = self.cameraLayer.bounds;
  }
}

- (void)dealloc{
  [self yg_removeObserver:self forKeyPath:@"cameraLayer.bounds"];
}


#pragma mark - utils method
- (void)ma_safeAddInput:(AVCaptureInput *)input{
  if ([self.session canAddInput:input]) {
    [self.session addInput:input];
  }
}

- (void)ma_safeAddOutput:(AVCaptureOutput *)output{
  if ([self.session canAddOutput:output]) {
    [self.session addOutput:output];
  }
}

#pragma mark - accessor
- (AVCaptureSession *)session{
  if (!_session) {
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    session.sessionPreset = AVCaptureSessionPresetInputPriority;
    _session = session;
  }
  return _session;
}

- (AVCaptureDevice *)videoDevice{
  if (!_videoDevice) {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _videoDevice = videoDevice;
  }
  return _videoDevice;
}

- (AVCaptureDeviceInput *)videoInput{
  if (!_videoInput) {
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice
                                                                        error:&error];
    if (error) {
      _videoInput = nil;
    }else{
      _videoInput = input;
    }
  }
  return _videoInput;
}

- (AVCaptureDevice *)audioDevice{
  if (!_audioDevice) {
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    _audioDevice = audioDevice;
  }
  return _audioDevice;
}

- (AVCaptureDeviceInput *)audioInput{
  if (!_audioInput) {
    NSError *error;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice
                                                                             error:&error];
    if (error) {
      _audioInput = nil;
    }
    else{
      _audioInput = audioInput;
    }
  }
  return _audioInput;
}

- (AVCaptureStillImageOutput *)imageOutPut{
  if (!_imageOutPut) {
    AVCaptureStillImageOutput *imageOutPut = [[AVCaptureStillImageOutput alloc]init];
    _imageOutPut = imageOutPut;
  }
  return _imageOutPut;
}

- (AVCaptureMovieFileOutput *)movieOutPut{
  if (!_movieOutPut) {
    AVCaptureMovieFileOutput *moveOutPut = [[AVCaptureMovieFileOutput alloc]init];
    _movieOutPut = moveOutPut;
  }
  return _movieOutPut;
}

- (dispatch_queue_t)videoQueue{
  if (!_videoQueue) {
    dispatch_queue_t queue = dispatch_queue_create("ma_camera_video_queue", DISPATCH_QUEUE_SERIAL);
    _videoQueue = queue;
  }
  return _videoQueue;
}

- (AVCaptureVideoDataOutput *)videoDataOutPut{
  if(!_videoDataOutPut){
    AVCaptureVideoDataOutput *videoDataOutPut = [[AVCaptureVideoDataOutput alloc]init];
//    AVCaptureConnection *conn = [videoDataOutPut connectionWithMediaType:AVMediaTypeVideo];
    NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];
    videoDataOutPut.videoSettings = setcapSettings;
    [videoDataOutPut setSampleBufferDelegate:self queue:self.videoQueue];
    _videoDataOutPut = videoDataOutPut;
  }
  return _videoDataOutPut;
}

- (AVCaptureVideoPreviewLayer *)previewLayer{
  if (!_previewLayer) {
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    layer.contentsGravity = kCAGravityResizeAspectFill;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer = layer;
  }
  return _previewLayer;
}

- (CALayer *)filterLayer{
  if (!_filterLayer) {
    CALayer *layer = [AVPlayerLayer layer];
    layer.affineTransform = CGAffineTransformMakeRotation(M_PI/2);
    layer.contentsGravity = kCAGravityResizeAspectFill;
    AVPlayerLayer *av = (AVPlayerLayer *)layer;
    av.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.masksToBounds = YES;
    _filterLayer = layer;

  }
  return _filterLayer;
}

- (CALayer *)cameraLayer{
  if (!_cameraLayer) {
    CALayer *layer = [CALayer layer];
    layer.contentsGravity = kCAGravityResizeAspectFill;
    layer.masksToBounds = YES;
    _cameraLayer = layer;
  }
  return _cameraLayer;
}

- (MACameraEncoder *)encoder{
  if (!_encoder) {
    NSString *url = [NSTemporaryDirectory() stringByAppendingPathComponent:@"cap.mp4"];
    NSDictionary *settings = self.videoDataOutPut.videoSettings;
    MAVideoSize size = {[settings[@"Width"] intValue],[settings[@"Height"] intValue]};
    MACameraEncoder *encoder = [[MACameraEncoder alloc]initWithUrl:url videoSize:size rate:6000];
    _encoder = encoder;
  }
  return _encoder;
}

#pragma mark - snap

- (void)snap:(void (^)(UIImage *))completion{
  AVCaptureConnection *connection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
  [self.imageOutPut captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    if (error) {
      completion(nil);
      return;
    }
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
    
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                        bounds:self.filterLayer.bounds.size
                          interpolationQuality:kCGInterpolationHigh];
    image = [image croppedImage:CGRectMake(0, (image.size.height - self.filterLayer.frame.size.height) / 2, self.filterLayer.frame.size.width, self.filterLayer.frame.size.height)];
    if (completion) {
      completion(image);
    }
  }];
}

- (void)switchCamera:(void (^)(void))completion{

  AVCaptureDevicePosition position
  = self.videoDevice.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
  NSArray *devices = [AVCaptureDevice devices];
  for(AVCaptureDevice *device in devices){
    if (device.position == position) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.session stopRunning];
        [self.session removeInput:self.videoInput];
        self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        [self.session addInput:self.videoInput];
        self.videoDevice = device;
        [self.session startRunning];
        if (completion) {
          completion();
        }
      });
    }
  }
}

- (void)switchCameraToBack{
  if (self.videoDevice.position == AVCaptureDevicePositionBack) {
    return;
  }
  [self switchCamera:nil];
}

- (void)switchCameraToFront{
  if (self.videoDevice.position == AVCaptureDevicePositionFront) {
    return;
  }
  [self switchCamera:nil];
}

// video output data delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
  
  CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
  size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
  size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
  void *lumaBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
  CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
  CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace,kCGImageAlphaNone);
  CGImageRef dstImage = CGBitmapContextCreateImage(context);
  dispatch_sync(dispatch_get_main_queue(), ^{
    self.filterLayer.contents = (__bridge id)dstImage;
  });
  CGImageRelease(dstImage);
  CGContextRelease(context);
  CGColorSpaceRelease(grayColorSpace);
  
  if (![self.session isRunning]) return;
  
  if (!self.shouldRecord) {
    if (self.hasPaused) {
      self.lastTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
      self.hasPaused = NO;
    }
    return;
  }
  static CMTime offset;
  if (!self.hasPaused) {
    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMTime pOffset = CMTimeSubtract(pts, self.lastTime);
    if (offset.timescale == 0) {
      offset = CMTimeMake(0, pOffset.timescale);
    }
    offset = CMTimeAdd(offset, pOffset);
    self.hasPaused = YES;
  }
  
  CFRetain(sampleBuffer);
  if (offset.value != 0 ) {
      CFRelease(sampleBuffer);
      sampleBuffer = [MACameraEncoder forwardSampleBuffer:sampleBuffer offset:offset];
  }
  
  if (self.lastTime.value == 0) {
      self.lastTime = CMTimeMake(1, 1);
  }
  [self.encoder writeVideoSampleBuffer:sampleBuffer];
  CFRelease(sampleBuffer);

}
- (void)startRecord:(NSURL *)filePath{
  self.shouldRecord = YES;
}

- (void)pauseRecord{
  self.shouldRecord = NO;
}

- (void)resumeRecord{
  self.shouldRecord = YES;
}

- (void)stopRecord{
  self.shouldRecord = NO;
  [self.encoder finishWritingWithCompletionHandler:^{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSString *url = [NSTemporaryDirectory() stringByAppendingString:@"cap.mp4"];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:url] completionBlock:^(NSURL *assetURL, NSError *error){
      NSLog(@"save completed");
      [[NSFileManager defaultManager] removeItemAtPath:url error:nil];
    }];
  }];
}

- (void)cancelRecord{
  self.shouldRecord = NO;
  [self.encoder finishWritingWithCompletionHandler:^{
  }];
}

@end
