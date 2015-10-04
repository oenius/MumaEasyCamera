//
//  MACameraManager+AuthorizationExtra.h
//
//  Created by YURI_JOU on 15-4-7.
//

#import "MACameraManager.h"

@interface MACameraManager (AuthorizationExtra)

- (void) authorizaCameraAuthorize:(void(^)(AVCaptureDevice*device))authorize completion:(void(^)(AVCaptureDevice*device))completion failure:(void(^)(AVCaptureDevice*device))failure;

@end
