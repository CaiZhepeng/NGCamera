#import "UIImage+Blur.h"

@implementation UIImage (Blur)

- (UIImage *)blurryImageWithLevel:(CGFloat)blur
{
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, inputImage, @"inputRadius", @(blur), nil];
    
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef outImage = [[CIContext contextWithOptions:nil] createCGImage:outputImage
                                             fromRect:[outputImage extent]];
    UIImage *image = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return image;
}


@end
