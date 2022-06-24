#import <UIKit/UIKit.h>

static CGContextRef CreateRGBABitmapContext (CGImageRef inImage);
static unsigned char *RequestImagePixelData(UIImage *inImage);

@interface UIImage (MaskShape)

+ (UIImage*)imageChangeBlackToTransparent:(UIImage*)inImage;
- (UIImage *)imageWithMaskImage:(UIImage *)maskImage;
- (UIImage *)imageWithMaskImage:(UIImage *)maskImage maskColor:(UIColor *)maskColor;//ios7以下
- (UIImage *)imageWithLayerMaskImage:(UIImage *)maskImage maskColor:(UIColor *)maskColor;//ios7

- (UIImage *)imageWithColor:(UIColor *)color;
@end
