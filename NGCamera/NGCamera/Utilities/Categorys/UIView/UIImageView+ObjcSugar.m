//
//  UIImageView+ObjcSugar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+ObjcSugar.h"

@implementation UIImageView (ObjcSugar)

+ (nullable UIImageView *)ng_imageViewWithImageName:(nullable NSString *)imageName
{
    return [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
}

@end
