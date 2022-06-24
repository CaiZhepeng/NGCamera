//
//  NGCustomSlider.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/5.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGBrightnessSlider : UIView

@property(nonatomic, strong) UIColor *minimumTrackTintColor;
@property(nonatomic, strong) UIColor *maximumTrackTintColor;
@property(nonatomic, copy) void (^sliderValueChangeBlock)(CGFloat value);
@property(nonatomic, assign) CGFloat value;

- (void)setThumbImage:(UIImage *)image;
- (void)setValue:(CGFloat)value wantCallBack:(BOOL)callback;

@end

NS_ASSUME_NONNULL_END
