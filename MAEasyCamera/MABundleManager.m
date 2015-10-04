//
//  MABundleManager.m
//  Overseas
//
//  Created by YURI_JOU on 15-4-2.
//

#define DEFAULT_BUNDLE_NAME @"MumaDefault"
#import "MABundleManager.h"
@interface MABundleManager()

@property (nonatomic, strong)NSBundle *defaultBundle;

@end

static MABundleManager *shareInstance;

@implementation MABundleManager

+ (MABundleManager *)manager{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shareInstance = [[MABundleManager alloc]init];
  });
  return shareInstance;
}

- (NSBundle *)bundleWithName:(NSString *)bundleName{
  NSURL *bundlePath = [[NSBundle mainBundle]URLForResource:bundleName withExtension:@".bundle"];
  NSBundle *bundle = [NSBundle bundleWithURL:bundlePath];
  return bundle;
}

- (NSBundle *)defaultBundle{
  return [self bundleWithName:DEFAULT_BUNDLE_NAME];
}



@end
