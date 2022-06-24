//
//  UIButton+ObjcSugar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import "UIButton+ObjcSugar.h"

@implementation UIButton (ObjcSugar)

+ (instancetype)ng_buttonWithTitle:(NSString *)title fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor {
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:title
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                                       NSForegroundColorAttributeName: textColor}];
    
    return [self ng_buttonWithAttributedText:attributedText];
}

+ (instancetype)ng_buttonWithAttributedText:(NSAttributedString *)attributedText {
    return [self ng_buttonWithAttributedText:attributedText imageName:nil backImageName:nil highlightedImageName:nil];
}

+ (instancetype)ng_buttonWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName {
    
    return [self ng_buttonWithAttributedText:nil imageName:imageName backImageName:nil highlightedImageName:highlightedImageName];
}

+ (nonnull instancetype)ng_buttonWithbackImageName:(nullable NSString *)backImageName highlightedImageName:(nullable NSString *)highlightedImageName
{
    return [self ng_buttonWithAttributedText:nil imageName:nil backImageName:backImageName highlightedImageName:highlightedImageName];
}

+ (instancetype)ng_buttonWithImageName:(NSString *)imageName backImageName:(NSString *)backImageName highlightedImageName:(NSString *)highlightedImageName {
    
    return [self ng_buttonWithAttributedText:nil imageName:imageName backImageName:backImageName highlightedImageName:highlightedImageName];
}

+ (instancetype)ng_buttonWithTitle:(NSString *)title fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor imageName:(NSString *)imageName backImageName:(NSString *)backImageName highlightedImageName:(NSString *)highlightedImageName {
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:title
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                                       NSForegroundColorAttributeName: textColor}];
    
    return [self ng_buttonWithAttributedText:attributedText imageName:imageName backImageName:backImageName highlightedImageName:highlightedImageName];
}

+ (void)extracted:(NSAttributedString * _Nullable)attributedText button:(UIButton *)button {
    [button setAttributedTitle:attributedText forState:UIControlStateNormal];
}

+ (instancetype)ng_buttonWithAttributedText:(NSAttributedString *)attributedText imageName:(NSString *)imageName backImageName:(NSString *)backImageName highlightedImageName:(NSString *)highlightedImageName {
    
    UIButton *button = [[self alloc] init];
    
    [self extracted:attributedText button:button];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    if (imageName != nil) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    }
    
    if (backImageName != nil) {
        [button setBackgroundImage:[UIImage imageNamed:backImageName] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    }
    
    [button sizeToFit];
    
    return button;
}

@end
