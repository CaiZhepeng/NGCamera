#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CGAffineTransformFun : NSObject

+ (CGFloat)radianWithCGAffineTransform:(CGAffineTransform)t;

+ (CGFloat)scaleXWithCGAffineTransform:(CGAffineTransform)t;

+ (CGFloat)scaleYWithCGAffineTransform:(CGAffineTransform)t;

+ (void)translateWithCGAffineTranform:(CGAffineTransform)t tx:(CGFloat *)tx ty:(CGFloat *)ty;

+ (CGRect)CGRectForCenterWithAffineTransform:(CGAffineTransform)t CGRect:(CGRect)rect;

//+ (CGSize)CGSizeForInnerWithAffineTransform:(CGAffineTransform)t TransformCGRect:(CGRect)tRect;


@end
