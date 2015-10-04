//
//  UIColor+HexExtra.h
//  Overseas
//
//  Created by YURI_JOU on 15-3-5.
//

#import <UIKit/UIKit.h>

#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(c)                         [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

@interface UIColor (HexExtra)

+ (UIColor *)colorWithHex:(NSInteger)rgb;
+ (UIColor *)colorWithHexString:(NSString *)rgb;


@end
