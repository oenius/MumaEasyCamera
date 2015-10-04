//
//  UIImage+MAExtra.h
//  Overseas
//
//  Created by YURI_JOU on 15-4-2.
//

#import <UIKit/UIKit.h>

@interface UIImage (MAExtra)

- (UIImage *)imageWithImage:(UIImage *)image resizeInSize:(CGSize)size;
- (UIImage *)imageWithImage:(UIImage *)image cropInRect:(CGRect)rect;

- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

- (UIImage *)fixOrientation;

- (UIImage *)rotatedByDegrees:(CGFloat)degrees;

@end
