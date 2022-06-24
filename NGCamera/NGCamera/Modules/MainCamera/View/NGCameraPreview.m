//
//  NGCameraPreview.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/5.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraPreview.h"

@implementation NGCameraPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self setupGesture];
    }
    return self;
}

- (void)setupGesture
{
    // 捏合
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
    
    // 轻敲
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)pinGesture
{
    if (self.handlePinchGestureBlock) {
        self.handlePinchGestureBlock(pinGesture);
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (self.handleTapGestureBlock) {
        self.handleTapGestureBlock(tapGesture);
    }
}

@end
