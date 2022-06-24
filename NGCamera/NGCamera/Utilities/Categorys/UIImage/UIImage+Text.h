#import <UIKit/UIKit.h>

@interface UIImage (Text)

//+ (UIImage *)drawText:(NSString *)text inImage:(UIImage *)image atPoint:(CGPoint)point;
+ (UIImage *)drawTextWithStroke:(NSString *)string color:(UIColor *)color;
+ (UIImage *)drawDate:(NSString *)text InImage:(UIImage *)image font:(UIFont *)font point:(CGPoint)point;

@end
