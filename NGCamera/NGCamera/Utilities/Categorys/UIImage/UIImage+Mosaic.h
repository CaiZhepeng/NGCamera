#import <UIKit/UIKit.h>

@interface UIImage (Mosaic)

//level:以多少像素为一个格子。
- (UIImage *)mosaicImageWithLevel:(int)level;

//level的默认值为8
- (UIImage *)mosaicDefaultImage;

@end
