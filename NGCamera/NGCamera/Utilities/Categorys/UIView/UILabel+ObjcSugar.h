//
//  UILabel+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ObjcSugar)

/// 实例化 UILabel
///
/// @param text text
///
/// @return UILabel 默认字体 17，默认颜色 [UIColor whiteColor]，默认对齐方式 center
+ (nonnull instancetype)ng_labelWithText:(nullable NSString *)text;

/// 实例化 UILabel
///
/// @param text     text
/// @param fontSize fontSize
///
/// @return UILabel 默认颜色 [UIColor whiteColor]，默认对齐方式 center
+ (nonnull instancetype)ng_labelWithText:(nullable NSString *)text fontSize:(CGFloat)fontSize;

/// 实例化 UILabel
///
/// @param text      text
/// @param fontSize  fontSize
/// @param textColor textColor
///
/// @return UILabel 默认对齐方式 center
+ (nonnull instancetype)ng_labelWithText:(nullable NSString *)text
                                fontSize:(CGFloat)fontSize
                               textColor:(nonnull UIColor *)textColor;

/// 实例化 UILabel
///
/// @param text          text
/// @param boldFontSize  boldFontSize
/// @param textColor     textColor
///
/// @return UILabel 默认对齐方式 center 粗体字
+ (nonnull instancetype)ng_labelWithText:(nullable NSString *)text
                             boldFontSize:(CGFloat)boldFontSize
                                textColor:(nonnull UIColor *)textColor;

/// 实例化 UILabel
///
/// @param text      text
/// @param fontSize  fontSize
/// @param textColor textColor
/// @param alignment alignment
///
/// @return UILabel 默认size自适应字体
+ (nonnull instancetype)ng_labelWithText:(nullable NSString *)text
                                fontSize:(CGFloat)fontSize
                               textColor:(nonnull UIColor *)textColor
                               alignment:(NSTextAlignment)alignment;

/// 实例化 UILabel
///
/// @param text          text
/// @param boldFontSize  boldFontSize
/// @param textColor     textColor
/// @param alignment     alignment
///
/// @return UILabel 默认字体自适应size 粗体字
+ (nonnull instancetype)ng_labelWithText:(nullable NSString *)text
                             boldFontSize:(CGFloat)boldFontSize
                                textColor:(nonnull UIColor *)textColor
                                alignment:(NSTextAlignment)alignment;


/// 实例化 UILabel
///
/// @param text      text
/// @param font      font
/// @param textColor textColor
/// @param alignment alignment
///
/// @return UILabel
+ (nonnull instancetype)ng_labelWithText:(nullable NSString *)text
                                     font:(nullable UIFont *)font
                                textColor:(nonnull UIColor *)textColor
                                alignment:(NSTextAlignment)alignment;

@end
