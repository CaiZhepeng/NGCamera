//
//  NGCustomSlider.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/18.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCustomSlider.h"

#define kPopUpLabelSize 25

@implementation NGCustomSlider

- (void)adjustPopLabelFrame
{
    CGRect thumbRect = [self thumbRect];
    CGFloat thumbW = thumbRect.size.width;
    CGFloat thumbH = thumbRect.size.height;
    
    CGRect popUpRect = CGRectInset(thumbRect, (thumbW - kPopUpLabelSize)/2, (thumbH - kPopUpLabelSize)/2);
    popUpRect.origin.y = thumbRect.origin.y - kPopUpLabelSize;

    CGFloat minOffsetX = CGRectGetMinX(popUpRect);
    CGFloat maxOffsetX = CGRectGetMaxX(popUpRect) - self.bounds.size.width;
    
    CGFloat offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0);
    popUpRect.origin.x -= offset;
    self.sliderValueLabel.frame = popUpRect;
    self.sliderValueLabel.text = [NSString stringWithFormat:@"%ld",(long)[self updateSliderValue]];
}

- (NSInteger)updateSliderValue
{
    CGFloat minimum = self.minimumValue;
    CGFloat maximum = self.maximumValue;
    CGFloat value = self.value;

    CGFloat x = ((value - minimum) / (maximum - minimum)) * self.frame.size.width;
    CGFloat maxMin = (maximum + minimum) / 2.0;

    if (value > maxMin) {
        value = (value - maxMin) / (maximum - maxMin);
        x = value * self.maxTipValue;
    } else {
        value = (maxMin - value) / (maxMin - minimum);
        x = value * self.minTipValue;
    }
    return (int)x;
}

- (CGRect)thumbRect
{
    return [self thumbRectForBounds:self.bounds
                          trackRect:[self trackRectForBounds:self.bounds]
                              value:self.value];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self adjustPopLabelFrame];
    [self showPopoverAnimated:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidePopoverAnimated:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidePopoverAnimated:YES];
    [super touchesCancelled:touches withEvent:event];
}

- (void)showPopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.sliderValueLabel.alpha = 1.0;
        }];
    } else {
        self.sliderValueLabel.alpha = 1.0;
    }
}

- (void)hidePopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.sliderValueLabel.alpha = 0;
        }];
    } else {
        self.sliderValueLabel.alpha = 0;
    }
}

- (UILabel *)sliderValueLabel
{
    if (!_sliderValueLabel) {
        [self addTarget:self action:@selector(adjustPopLabelFrame) forControlEvents:UIControlEventValueChanged];
        self.continuous = YES;
        _sliderValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kPopUpLabelSize, kPopUpLabelSize)];
        _sliderValueLabel.textColor = [UIColor whiteColor];
        _sliderValueLabel.textAlignment = NSTextAlignmentCenter;
        _sliderValueLabel.font = [UIFont systemFontOfSize:12];
        _sliderValueLabel.adjustsFontSizeToFitWidth = YES;
        _sliderValueLabel.alpha = 0;
        [self addSubview:_sliderValueLabel];
    }
    return _sliderValueLabel;
}

@end
