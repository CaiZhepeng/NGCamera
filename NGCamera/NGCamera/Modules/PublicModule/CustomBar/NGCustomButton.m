//
//  NGCustomButton.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/17.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCustomButton.h"

#define kButtonImageRatio 0.6

@implementation NGCustomButton

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:16/255.0 green:118/255.0 blue:241/255.0 alpha:1.0] forState:UIControlStateSelected];
    }
    return  self;
}

- (void)setHighlighted:(BOOL)highlighted{
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * kButtonImageRatio;
    return CGRectMake(0, 0, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    CGFloat  titleY = contentRect.size.height * kButtonImageRatio;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY ;
    return  CGRectMake(0, titleY, titleW, titleH);
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setNormalImage:(NSString *)normalImage
{
    _normalImage = normalImage;
    [self setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
}

- (void)setSelectedImage:(NSString *)selectedImage
{
    _selectedImage = selectedImage;
    [self setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
}

@end
