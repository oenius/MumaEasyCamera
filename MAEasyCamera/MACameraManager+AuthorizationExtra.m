//
//  MACameraManager+AuthorizationExtra.m
//
//  Created by YURI_JOU on 15-4-7.
//

#import "MACameraManager+AuthorizationExtra.h"

@implementation MACameraManager (AuthorizationExtra)

- (void) authorizaCameraAuthorize:(void(^)(AVCaptureDevice*device))authorize
                       completion:(void(^)(AVCaptureDevice*device))completion
                          failure:(void(^)(AVCaptureDevice*device))failure{
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  switch (status) {
    case AVAuthorizationStatusNotDetermined:
      if (authorize) {
        authorize(self.videoDevice);
      }
      break;
    case AVAuthorizationStatusAuthorized:
      if (completion) {
        completion(self.videoDevice);
      }
    case AVAuthorizationStatusRestricted|AVAuthorizationStatusRestricted:
      if (failure) {
        failure(self.videoDevice);
      }
    default:
      
      break;
  }
}

@end
