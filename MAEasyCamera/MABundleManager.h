//
//  MABundleManager.h
//  Overseas
//
//  Created by YURI_JOU on 15-4-2.
//

#import <Foundation/Foundation.h>

@interface MABundleManager : NSObject

+ (MABundleManager *)manager;

- (NSBundle *)defaultBundle;
- (NSBundle *)bundleWithName:(NSString *)bundleName;

@end
