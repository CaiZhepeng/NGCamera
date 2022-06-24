//
//  UIImageView+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ObjcSugar)

/// 实例化 UIImageView
///
/// @param imageName  图片名字
///
/// @return UIImageView
+ (nullable UIImageView *)ng_imageViewWithImageName:(nullable NSString *)imageName;

@end
