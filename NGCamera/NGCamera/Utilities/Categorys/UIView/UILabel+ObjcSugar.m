//
//  UILabel+ObjcSugar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import "UILabel+ObjcSugar.h"

@implementation UILabel (ObjcSugar)

+ (instancetype)ng_labelWithText:(NSString *)text {
    return [self ng_labelWithText:text fontSize:17 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
}

+ (instancetype)ng_labelWithText:(NSString *)text fontSize:(CGFloat)fontSize {
    return [self ng_labelWithText:text fontSize:fontSize textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
}

+ (instancetype)ng_labelWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor {
    return [self ng_labelWithText:text fontSize:fontSize textColor:textColor alignment:NSTextAlignmentCenter];
}

+ (instancetype)ng_labelWithText:(NSString *)text boldFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor {
    return [self ng_labelWithText:text boldFontSize:fontSize textColor:textColor alignment:NSTextAlignmentCenter];
}

+ (instancetype)ng_labelWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment {
    return [self ng_labelWithText:text font:[UIFont systemFontOfSize:fontSize] textColor:textColor alignment:alignment];
}

+ (instancetype)ng_labelWithText:(NSString *)text boldFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment {
    return [self ng_labelWithText:text font:[UIFont boldSystemFontOfSize:fontSize] textColor:textColor alignment:alignment];
}

+ (instancetype)ng_labelWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment  {
    
    UILabel *label = [[self alloc] init];
    
    label.text = text;
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = alignment;
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

@end
