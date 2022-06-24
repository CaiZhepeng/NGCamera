//
//  NGCameraFocusView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/5.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraFocusView.h"
#import "NGBrightnessSlider.h"

#define kFocusViewMaxSize   120
#define kFocusViewMinSize   80
#define kLuminanceViewHeght 250

@implementation NGCameraFocusView
{
    NGBrightnessSlider *_luminanceView;
}

+ (instancetype)focusView
{
    NGCameraFocusView *focusView = [[NGCameraFocusView alloc] initWithFrame:CGRectMake(0, 0, kFocusViewMaxSize, kFocusViewMaxSize)];
    focusView.hidden = YES;
    return focusView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self render];
    }
    return self;
}

- (void)render
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 圆
    CGFloat lineWidth = 2.5;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(lineWidth, lineWidth, kFocusViewMaxSize-2*lineWidth, kFocusViewMaxSize-2*lineWidth));
    
    CGFloat lineLength = 10.0;
    CGPathMoveToPoint(path, NULL, lineWidth, kFocusViewMaxSize/2);
    CGPathAddLineToPoint(path, NULL, lineLength, kFocusViewMaxSize/2);
    
    // 四条线段
    CGPathMoveToPoint(path, NULL, kFocusViewMaxSize - lineLength, kFocusViewMaxSize/2);
    CGPathAddLineToPoint(path, NULL, kFocusViewMaxSize - lineWidth, kFocusViewMaxSize/2);
    
    CGPathMoveToPoint(path, NULL, kFocusViewMaxSize/2, lineWidth);
    CGPathAddLineToPoint(path, NULL, kFocusViewMaxSize/2, lineLength);
    
    CGPathMoveToPoint(path, NULL, kFocusViewMaxSize/2, kFocusViewMaxSize - lineLength);
    CGPathAddLineToPoint(path, NULL, kFocusViewMaxSize/2, kFocusViewMaxSize - lineWidth);
    
    // 十字线段
    CGFloat lineCrossLength = 30.0;
    CGPathMoveToPoint(path, NULL, self.center.x - lineCrossLength/2, self.center.y);
    CGPathAddLineToPoint(path, NULL, self.center.x + lineCrossLength/2, self.center.y);
    
    CGPathMoveToPoint(path, NULL, self.center.x, self.center.y - lineCrossLength/2);
    CGPathAddLineToPoint(path, NULL, self.center.x, self.center.y + lineCrossLength/2);
    
    // 绘制
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGPathRelease(path);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.layer.contents = (__bridge id _Nullable)(image.CGImage);
}

#pragma mark - Public
- (void)foucusAtPoint:(CGPoint)center withPreViewFrame:(CGRect)frame
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.luminanceView.hidden = NO;
    self.luminanceView.alpha = 1.0f;
    self.hidden = NO;
    self.alpha = 1.0f;
    self.frame = CGRectMake(0, 0, kFocusViewMaxSize, kFocusViewMaxSize);
    self.center = center;
    
    if (frame.size.height >= kLuminanceViewHeght) {
        self.luminanceView.top = (frame.size.height - kLuminanceViewHeght)/2 + frame.origin.y;
        self.luminanceView.height = kLuminanceViewHeght;
    } else {
        self.luminanceView.top = 0;
        self.luminanceView.height = frame.size.height;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectMake(0, 0, kFocusViewMinSize, kFocusViewMinSize);
        self.center = center;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideFoucusView) withObject:nil afterDelay:0.9f];
    }];
}

#pragma mark - Private
- (void)hideFoucusView
{
    [UIView animateWithDuration:0.1f animations:^{
        self.luminanceView.alpha = 0.1f;
        self.alpha = 0.1f;
    } completion:^(BOOL finished) {
        self.luminanceView.hidden = YES;
        self.hidden = YES;
    }];
}

- (UIView *)luminanceView
{
    if (!_luminanceView) {
        WeakSelf(self);
        _luminanceView = [[NGBrightnessSlider alloc] initWithFrame:CGRectMake(kMainScreenWidth - 60, 0, 30, kLuminanceViewHeght)];
        _luminanceView.hidden = YES;
        _luminanceView.value = 0.5;
        [_luminanceView setThumbImage:[UIImage imageNamed:@"icon_brightness_a"]];
        [self.superview addSubview:_luminanceView];
        [_luminanceView setSliderValueChangeBlock:^(CGFloat value) {
            StrongSelf(self);
            self.alpha = 0.8f;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(hideFoucusView) withObject:nil afterDelay:0.9f];
            if (self.luminanceChangeBlock) {
                self.luminanceChangeBlock(value);
            }
        }];
    }
    
    return _luminanceView;
}

@end
