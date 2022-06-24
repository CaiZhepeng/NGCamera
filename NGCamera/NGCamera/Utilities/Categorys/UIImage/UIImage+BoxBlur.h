#import <UIKit/UIKit.h>

@interface UIImage (BoxBlur)

// blur = 0 ~ 1.0
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur;
@end
