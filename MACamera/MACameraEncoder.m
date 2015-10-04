//
//  MACameraEncoder.m
//
//  Created by YURI_JOU on 15-4-5.
//

#import "MACameraEncoder.h"

@interface MACameraEncoder()

@property (nonatomic, strong)AVAssetWriter *assetWriter;
@property (nonatomic, strong)AVAssetWriterInput *assetInput;
@property (nonatomic, strong)NSURL *url;
@property (nonatomic, assign)MAVideoSize size;

@end

@implementation MACameraEncoder

- (instancetype)initWithUrl:(NSString *)url videoSize:(MAVideoSize)size rate:(Float64)rate{
  self = [super init];
  if (self) {
    [[NSFileManager defaultManager] removeItemAtPath:url error:nil];
    self.url = [NSURL fileURLWithPath:url];
    self.size = size;
    [self.assetWriter addInput:self.assetInput];
  }
  return self;
}

#pragma mark - accessor

- (AVAssetWriter *)assetWriter{
  if (!_assetWriter) {
    NSError *error;

    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:self.url fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if (error) {
      _assetWriter = nil;
    }else{
      _assetWriter = writer;
    }
  }
  return _assetWriter;
}

- (AVAssetWriterInput *)assetInput{
  if (!_assetInput) {
    NSDictionary *settings = @{
                               AVVideoCodecKey:AVVideoCodecH264,
                               AVVideoWidthKey:@(self.size.width),
                               AVVideoHeightKey:@(self.size.height),
                               };
    AVAssetWriterInput *input = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _assetInput = input;
  }
  return _assetInput;
}

#pragma public method
+ (CMSampleBufferRef)forwardSampleBuffer:(CMSampleBufferRef)sample offset:(CMTime)offset{
  CMItemCount count;
  CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
  CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
  CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
  for (CMItemCount i = 0; i < count; i++)
  {
    pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
    pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
  }
  CMSampleBufferRef sout;
  CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
  free(pInfo);
  return sout;
}


- (BOOL)writeVideoSampleBuffer:(CMSampleBufferRef) sampleBuffer{
  if (self.assetWriter.status == AVAssetWriterStatusUnknown) {
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
  }
  if (self.assetWriter.status == AVAssetWriterStatusFailed) {
    //TODO log error
    return NO;
  }
  if (self.assetInput.readyForMoreMediaData) {
    [self.assetInput appendSampleBuffer:sampleBuffer];
  }
  return YES;
}

- (void)finishWritingWithCompletionHandler:(void(^)(void)) completion{
  [self.assetWriter finishWritingWithCompletionHandler:completion];
}

@end
