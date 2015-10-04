//
//  NSObject+Extra.h
//  Overseas
//
//  Created by YURI_JOU on 15-3-14.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extra)

@property (nonatomic, strong) NSMutableDictionary *observerTargetMappings;

+ (void)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel;

- (void)yg_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context;

- (void)yg_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath;

@end
