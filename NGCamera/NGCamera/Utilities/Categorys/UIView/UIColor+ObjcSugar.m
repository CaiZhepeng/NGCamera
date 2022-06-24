//
//  UIColor+ObjcSugar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import "UIColor+ObjcSugar.h"

@implementation UIColor (ObjcSugar)

+ (UIColor*)colorWithHex:(NSInteger)hex
{
    return [self colorWithHex:hex alpha:1];
}

+ (UIColor*)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:alpha];
}

@end
