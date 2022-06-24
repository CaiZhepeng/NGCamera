//
//  UITextField+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (ObjcSugar)

/// 实例化 UITextField
///
/// @param placeHolder     占位文本
///
/// @return UITextField
+ (nonnull instancetype)ng_textFieldWithPlaceHolder:(nonnull NSString *)placeHolder;

@end
