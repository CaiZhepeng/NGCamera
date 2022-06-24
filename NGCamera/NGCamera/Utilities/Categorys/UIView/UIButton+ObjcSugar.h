//
//  UIButton+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ObjcSugar)

/**
 实例化 UIButton

 @param title      title
 @param fontSize   fontSize
 @param textColor  textColor
 @return UIButton
 */
+ (nonnull instancetype)ng_buttonWithTitle:(nullable NSString *)title
                                  fontSize:(CGFloat)fontSize
                                 textColor:(nonnull UIColor *)textColor;

/**
 实例化 UIButton

 @param attributedText attributedText
 @return UIButton
 */
+ (nonnull instancetype)ng_buttonWithAttributedText:(nullable NSAttributedString *)attributedText;

/**
 实例化 UIButton

 @param imageName              imageName
 @param highlightedImageName   highlightedImageName
 @return UIButton
 */
+ (nonnull instancetype)ng_buttonWithImageName:(nullable NSString *)imageName
                           highlightedImageName:(nullable NSString *)highlightedImageName;

/**
 实例化 UIButton

 @param backImageName          backImageName
 @param highlightedImageName   highlightedImageName
 @return UIButton
 */
+ (nonnull instancetype)ng_buttonWithbackImageName:(nullable NSString *)backImageName
                               highlightedImageName:(nullable NSString *)highlightedImageName;

/**
 实例化 UIButton

 @param imageName              imageName
 @param backImageName          backImageName
 @param highlightedImageName   highlightedImageName
 @return UIButton
 */
+ (nonnull instancetype)ng_buttonWithImageName:(nullable NSString *)imageName
                                  backImageName:(nullable NSString *)backImageName
                           highlightedImageName:(nullable NSString *)highlightedImageName;

/**
 实例化 UIButton

 @param title                  title
 @param fontSize               fontSize
 @param textColor              textColor
 @param imageName              imageName
 @param backImageName          backImageName
 @param highlightedImageName   highlightedImageName
 @return UIButton
 */
+ (nonnull instancetype)ng_buttonWithTitle:(nullable NSString *)title
                                   fontSize:(CGFloat)fontSize
                                  textColor:(nonnull UIColor *)textColor
                                  imageName:(nullable NSString *)imageName
                              backImageName:(nullable NSString *)backImageName
                       highlightedImageName:(nullable NSString *)highlightedImageName;

/**
 实例化 UIButton

 @param attributedText         attributedText
 @param imageName              imageName
 @param backImageName          backImageName
 @param highlightedImageName   highlightedImageName
 @return UIButton
 */
+ (nonnull instancetype)ng_buttonWithAttributedText:(nullable NSAttributedString *)attributedText
                                           imageName:(nullable NSString *)imageName
                                       backImageName:(nullable NSString *)backImageName
                                highlightedImageName:(nullable NSString *)highlightedImageName;

@end
