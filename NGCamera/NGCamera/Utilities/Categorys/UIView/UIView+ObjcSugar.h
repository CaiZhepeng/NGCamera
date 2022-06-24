//
//  UIView+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapGestureActionBlock)(UITapGestureRecognizer *tap);

@interface UIView (ObjcSugar)

@property (nonatomic) CGFloat left;        ///f rame.origin.x.
@property (nonatomic) CGFloat top;         /// frame.origin.y

@property (nonatomic) CGFloat right;       /// frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      /// frame.origin.y + frame.size.height

@property (nonatomic) CGFloat width;       /// frame.size.width.
@property (nonatomic) CGFloat height;      /// frame.size.height.

@property (nonatomic) CGFloat centerX;     /// center.x
@property (nonatomic) CGFloat centerY;     /// center.y

@property (nonatomic) CGPoint origin;      /// frame.origin.
@property (nonatomic) CGSize  size;        /// frame.size.

- (UIViewController *)viewController;
- (UINavigationController *)navigationController;

/// 四边变圆
- (void)borderRoundCornerRadius:(CGFloat)radius;

/// 四边变圆 默认4
- (void)borderRound;

/// 单点击手势
- (void)handleTapGesture:(TapGestureActionBlock)block;

@end
