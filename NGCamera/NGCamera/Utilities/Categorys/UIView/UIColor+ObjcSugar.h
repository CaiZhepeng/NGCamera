//
//  UIColor+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ObjcSugar)

/// 使用十六进制数字生成颜色
///
/// @param hex 格式 0xFFEEDD
///
/// @return UIColor
+ (UIColor*)colorWithHex:(NSInteger)hex;

/// 使用十六进制数字生成颜色
///
/// @param hex    0xFFEEDD
/// @param alpha  透明度
///
/// @return UIColor
+ (UIColor*) colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

@end
