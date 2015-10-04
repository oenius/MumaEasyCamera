//
//  UIImage+MAExtra.m
//  Overseas
//
//  Created by YURI_JOU on 15-4-2.
//

#import "UIImage+MAExtra.h"

@implementation UIImage (MAExtra)

- (UIImage *)imageWithImage:(UIImage *)image resizeInSize:(CGSize)size{
  CGFloat scale = [[UIScreen mainScreen]scale];
  UIGraphicsBeginImageContextWithOptions(size, NO, scale);
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

- (UIImage *)imageWithImage:(UIImage *)image cropInRect:(CGRect)rect{
  CGImageRef cropedImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
  return [UIImage imageWithCGImage:cropedImageRef];
}

- (UIImage *)croppedImage:(CGRect)bounds {
  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  return croppedImage;
}

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
  BOOL drawTransposed;
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  if([[[UIDevice currentDevice]systemVersion]floatValue] >= 5.0) {
    drawTransposed = YES;
  }
  else {
    switch(self.imageOrientation) {
      case UIImageOrientationLeft:
      case UIImageOrientationLeftMirrored:
      case UIImageOrientationRight:
      case UIImageOrientationRightMirrored:
        drawTransposed = YES;
        break;
      default:
        drawTransposed = NO;
    }
    
    transform = [self transformForOrientation:newSize];
  }
  transform = [self transformForOrientation:newSize];
  return [self resizedImage:newSize transform:transform drawTransposed:drawTransposed interpolationQuality:quality];
}

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
  CGFloat horizontalRatio = bounds.width / self.size.width;
  CGFloat verticalRatio = bounds.height / self.size.height;
  CGFloat ratio;
  
  switch(contentMode) {
    case UIViewContentModeScaleAspectFill:
      ratio = MAX(horizontalRatio, verticalRatio);
      break;
      
    case UIViewContentModeScaleAspectFit:
      ratio = MIN(horizontalRatio, verticalRatio);
      break;
      
    default:
      [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %ld", contentMode];
  }
  
  CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
  
  return [self resizedImage:newSize interpolationQuality:quality];
}


#pragma mark - fix orientation
- (UIImage *)fixOrientation {
  
  if (self.imageOrientation == UIImageOrientationUp) return self;
  
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  switch (self.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, self.size.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
      break;
  }
  
  switch (self.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
      
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationDown:
    case UIImageOrientationLeft:
    case UIImageOrientationRight:
      break;
  }

  CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                           CGImageGetBitsPerComponent(self.CGImage), 0,
                                           CGImageGetColorSpace(self.CGImage),
                                           CGImageGetBitmapInfo(self.CGImage));
  CGContextConcatCTM(ctx, transform);
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      // Grr...
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
      break;
      
    default:
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
      break;
  }
  
  CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
  UIImage *img = [UIImage imageWithCGImage:cgimg];
  CGContextRelease(ctx);
  CGImageRelease(cgimg);
  return img;
}

static inline CGFloat DegreesToRadians(CGFloat degrees)
{
  return M_PI * (degrees / 180.0);
}

- (UIImage *)rotatedByDegrees:(CGFloat)degrees
{
  UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
  CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
  rotatedViewBox.transform = t;
  CGSize rotatedSize = rotatedViewBox.frame.size;
  
  UIGraphicsBeginImageContext(rotatedSize);
  CGContextRef bitmap = UIGraphicsGetCurrentContext();
  
  CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
  
  CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
  
  CGContextScaleCTM(bitmap, 1.0, -1.0);
  CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
  
  
}

#pragma mark -
#pragma mark Private helper methods

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
  CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
  CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
  CGImageRef imageRef = self.CGImage;
  
  CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                              newRect.size.width,
                                              newRect.size.height,
                                              8,
                                              0,
                                              CGImageGetColorSpace(imageRef),
                                              kCGImageAlphaNoneSkipLast);
  
  // Rotate and/or flip the image if required by its orientation
  CGContextConcatCTM(bitmap, transform);
  
  // Set the quality level to use when rescaling
  CGContextSetInterpolationQuality(bitmap, quality);
  
  // Draw into the context; this scales the image
  CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
  
  // Get the resized image from the context and a UIImage
  CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
  UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
  
  // Clean up
  CGContextRelease(bitmap);
  CGImageRelease(newImageRef);
  
  return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  switch(self.imageOrientation) {
    case UIImageOrientationDown:           // EXIF = 3
    case UIImageOrientationDownMirrored:   // EXIF = 4
      transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationLeft:           // EXIF = 6
    case UIImageOrientationLeftMirrored:   // EXIF = 5
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:          // EXIF = 8
    case UIImageOrientationRightMirrored:  // EXIF = 7
      transform = CGAffineTransformTranslate(transform, 0, newSize.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
    default:
      break;
  }
  
  switch(self.imageOrientation) {
    case UIImageOrientationUpMirrored:     // EXIF = 2
    case UIImageOrientationDownMirrored:   // EXIF = 4
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
      
    case UIImageOrientationLeftMirrored:   // EXIF = 5
    case UIImageOrientationRightMirrored:  // EXIF = 7
      transform = CGAffineTransformTranslate(transform, newSize.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    default:
      break;
  }
  
  return transform;
}

@end
