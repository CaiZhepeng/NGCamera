//
//  NGCropView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/21.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraCropView.h"
#import "NGCustomBar.h"
#import "NGCustomSlider.h"

#define kBarHeight      50
#define kSliderHeight   30
#define kSliderWidth    270
#define kButtonWidth    45

@interface NGCameraCropView() <NGCustomBarDelegate>
@property (nonatomic,strong) NGCustomBar *customBar;
@property (nonatomic,strong) NGCustomSlider *slider;
@end

@implementation NGCameraCropView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createData];
        [self createView];
    }
    return self;
}

- (void)createData
{
    self.cropModels = [NGCropModel buildCropModels];
}

- (void)createView
{
    //slider
    NGCustomSlider *slider = [[NGCustomSlider alloc] initWithFrame:CGRectMake(15, self.height - kBarHeight - kSliderHeight - 18, kSliderWidth, kSliderHeight)];
    slider.maximumValue = M_PI_4/2;
    slider.minimumValue = -M_PI_4/2;
    slider.maxTipValue = 100;
    slider.minTipValue = -100;
    slider.value = 0;
    slider.maximumTrackTintColor = [UIColor whiteColor];
    slider.minimumTrackTintColor = [UIColor colorWithRed:16/255.0 green:118/255.0 blue:241/255.0 alpha:1.0];
    [slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    self.slider = slider;
    
    // doneBtn
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(slider.right + (kMainScreenWidth - kButtonWidth - slider.right)/2, slider.top, kButtonWidth, kSliderHeight)];
    [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor colorWithRed:16/255.0 green:118/255.0 blue:241/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [doneBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneBtn];
    
    // customBar
    NGCustomBar *customBar = [[NGCustomBar alloc] initWithFrame:CGRectMake(0, self.height - kBarHeight - 5, kMainScreenWidth, kBarHeight)];
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < self.cropModels.count; i++)
    {
        NGCropModel *cropModel = self.cropModels[i];
        NGCustomButton *item = [[NGCustomButton alloc] initWithFrame:CGRectZero];
        item.title = cropModel.name;
        item.normalImage = cropModel.normalImage;
        item.selectedImage = cropModel.selectedImage;
        [items addObject:item];
    }
    customBar.itemWidth = 42;
    customBar.items = items;
    customBar.customBarDelegate = self;
    [customBar setSelectedButton:[customBar.items objectAtIndex:0]];
    [self addSubview:customBar];
    self.customBar = customBar;
}

- (void)reloadData
{
    [self createData];
    [self.customBar setSelectedButton:[self.customBar.items objectAtIndex:0]];
    self.slider.value = 0;
}

- (void)customBar:(nonnull NGCustomBar *)bar didSelectItemAtIndex:(NSInteger)index {
    if (self.clickBlock) {
        CGSize size = CGSizeZero;
        CGFloat rotate = 0;
        UIImageOrientation imageOrientation = UIImageOrientationUp;
        switch (index) {
            case 0:
                size = CGSizeMake(0.0f, 1.0f);
                break;
            case 1:
                size = CGSizeMake(1.0f, 1.0f);
                break;
            case 2:
                size = CGSizeMake(2.0f, 3.0f);
                break;
            case 3:
                size = CGSizeMake(3.0f, 2.0f);
                break;
            case 4:
                size = CGSizeMake(3.0f, 4.0f);
                break;
            case 5:
                size = CGSizeMake(4.0f, 3.0f);
                break;
            case 6:
                size = CGSizeMake(16.0f, 9.0f);
                break;
            case 7: {
                if (imageOrientation == UIImageOrientationUpMirrored) {
                    imageOrientation = UIImageOrientationDownMirrored;
                } else {
                    imageOrientation = UIImageOrientationUpMirrored;
                }
                break;
            }
            case 8: {
                if (imageOrientation == UIImageOrientationUp) {
                    imageOrientation = UIImageOrientationDown;
                } else {
                    imageOrientation = UIImageOrientationUp;
                }
                break;
            }
            case 9:
                rotate = M_PI_2;
                break;
            case 10:
                rotate = -M_PI_2;
                break;

            default:
                break;
        }
        self.clickBlock(size, rotate, imageOrientation);
    }
}

#pragma mark - slider
- (void)sliderValueChange:(UISlider *)slider
{
    
}

- (void)sliderTouchEnd:(UISlider *)slider
{
    if (self.sliderBlock) {
        self.sliderBlock(slider.value);
    }
}

- (void)buttonClicked:(UIButton *)btn
{
    if (self.didFinishBlock) {
        self.didFinishBlock();
    }
}

@end
