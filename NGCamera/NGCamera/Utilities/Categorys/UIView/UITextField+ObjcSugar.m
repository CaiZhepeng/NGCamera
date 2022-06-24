//
//  UITextField+ObjcSugar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import "UITextField+ObjcSugar.h"

@implementation UITextField (ObjcSugar)

+ (instancetype)ng_textFieldWithPlaceHolder:(NSString *)placeHolder {
    
    UITextField *textField = [[self alloc] init];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = placeHolder;
    
    return textField;
}

@end
