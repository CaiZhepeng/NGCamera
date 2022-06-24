#import "UIImage+ImageWithCorner.h"

@implementation UIImage (ImageWithCorner)

-(UIImage *)imageWithConrnerWithRadius:(CGFloat)radius sizeToFit:(CGSize)size{
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [UIScreen mainScreen].scale);
    
    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)].CGPath);
    
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [self drawInRect:rect];
    
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return output;
    
}

@end
