//
//  NGCameraTextView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/11/6.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGText.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorBoard : UIView
@property (nonatomic,strong) UIColor *selectedColor;
@property (nonatomic,copy) void (^changeColorBlock)(UIColor *color);
@end

@interface NGCameraTextView : UIView
@property (nonatomic,strong) NGText *text;
@property (nonatomic,strong) UIColor *currentColor;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,copy) void (^didFinishTextBlock)(NGCameraTextView *textView, NGText *text);
@property (nonatomic,copy) void (^didCancelBlock)(NGCameraTextView *textView);
@end

NS_ASSUME_NONNULL_END
