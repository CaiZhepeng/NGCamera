//
//  NGCustomSlider.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/5.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGBrightnessSlider.h"

#define kCustomSliderWidth     2
#define kCustomSliderMargin     0.05f

@implementation NGBrightnessSlider
{
    UIView      *_leftLineView;
    UIView      *_rightLineView;
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _value = 0.0f;
        [self setBackgroundColor:[UIColor clearColor]];
        
        _leftLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftLineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_leftLineView];
        
        CGFloat imageViewSize = frame.size.width;
        _rightLineView = [[UIView alloc] initWithFrame:CGRectMake(imageViewSize/2-kCustomSliderWidth/2, imageViewSize+kCustomSliderMargin, kCustomSliderWidth, frame.size.height-imageViewSize)];
        _rightLineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_rightLineView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewSize, imageViewSize)];
        [self addSubview:_imageView];
        _imageView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        [_imageView addGestureRecognizer:panGesture];
    }
    
    return self;
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    CGFloat imageSize = self.bounds.size.width;
    CGFloat x = MAX(MIN([gesture locationInView:self].y, self.bounds.size.height-imageSize/2), imageSize/2);
    [self render:x completeCallback:_sliderValueChangeBlock];
}

- (void)render:(CGFloat)x completeCallback:(void(^)(CGFloat value))sliderValueChangeBlock
{
    CGFloat imageSize = self.bounds.size.width;
    CGFloat sliderAvailabelLength = self.bounds.size.height-imageSize;
    CGFloat value = (x-imageSize/2)/sliderAvailabelLength;
    
    _imageView.center = CGPointMake(imageSize/2, x);
    
    _leftLineView.frame = CGRectMake(imageSize/2-kCustomSliderWidth/2, 0, kCustomSliderWidth, _imageView.frame.origin.y-kCustomSliderMargin);
    
    _rightLineView.frame = CGRectMake(imageSize/2-kCustomSliderWidth/2, _imageView.frame.origin.y+imageSize+kCustomSliderMargin, kCustomSliderWidth, self.bounds.size.height-(_imageView.frame.origin.y+imageSize+kCustomSliderMargin));
    
    _value = value;
    if (sliderValueChangeBlock) {
        sliderValueChangeBlock(_value);
    }
}

#pragma mark - PublicMethod
- (void)setValue:(CGFloat)value
{
    _value = value;
    CGFloat imageSize = self.bounds.size.width;
    CGFloat sliderAvailabelLength = self.bounds.size.height-imageSize;
    CGFloat x = value*sliderAvailabelLength + imageSize/2;
    [self render:x completeCallback:_sliderValueChangeBlock];
}

- (void)setThumbImage:(UIImage *)image
{
    _imageView.image = image;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor
{
    _rightLineView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor
{
    _leftLineView.backgroundColor = minimumTrackTintColor;
}

- (void)setValue:(CGFloat)value wantCallBack:(BOOL)callback
{
    CGFloat imageSize = self.bounds.size.width;
    CGFloat sliderAvailabelLength = self.bounds.size.height-imageSize;
    CGFloat x = value*sliderAvailabelLength + imageSize/2;
    if (callback) {
        [self render:x completeCallback:_sliderValueChangeBlock];
    }else {
        [self render:x completeCallback:nil];
    }
}

@end
