#import <UIKit/UIKit.h>

@interface UIImage (watermark)

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (UIImage *)watermarkImageWithShowImageViewFrame:(CGRect )frame sourceimage:(UIImage *)sourceImage watermarkImage:(UIImage *)watermarkImage time:(BOOL)showTime;

@end
