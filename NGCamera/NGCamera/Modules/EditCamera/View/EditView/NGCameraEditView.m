//
//  NGCameraEditView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/15.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraEditView.h"
#import "NGCustomBar.h"
#import "NGCustomSlider.h"
#import "FWApplyFilter.h"

#define kBarHeight      55
#define kSliderHeight   30
#define kSliderWidth    300
#define kButtonWidth    45

@interface NGCameraEditView() <NGCustomBarDelegate>
@property (nonatomic,strong) NGCustomBar *customBar;
@property (nonatomic,strong) NGCustomSlider *slider;

@property (nonatomic,strong) NSMutableArray *filters;

@property (nonatomic,strong) GPUImagePicture *imagePicture;

@property (nonatomic,strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic,strong) GPUImageContrastFilter *contrastFilter;
@property (nonatomic,strong) GPUImageWhiteBalanceFilter *whiteBalanceFilter;
@property (nonatomic,strong) GPUImageSaturationFilter *saturationFilter;
@property (nonatomic,strong) GPUImageHighlightShadowFilter *highlightFilter;
@property (nonatomic,strong) GPUImageHighlightShadowFilter *lowlightFilter;
@property (nonatomic,strong) GPUImageExposureFilter *exposureFilter;
@property (nonatomic,strong) GPUImageSharpenFilter *sharpenFilter;
@end

@implementation NGCameraEditView
{
    UIImage *currentImage;
    NSInteger _selectedIndex;
}

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
    _selectedIndex = 0;
    self.editModels = [NGEditModel buildEditModels];
    self.filters = [NSMutableArray array];
    [self setUpFilters];
}

- (void)createView
{
    NGCustomSlider *slider = [[NGCustomSlider alloc] initWithFrame:CGRectMake((kMainScreenWidth - kSliderWidth)/2, self.height - kBarHeight - kSliderHeight - 13, kSliderWidth, kSliderHeight)];
    slider.maxTipValue = 100;
    slider.minTipValue = -100;
    slider.maximumTrackTintColor = [UIColor whiteColor];
    slider.minimumTrackTintColor = [UIColor colorWithRed:16/255.0 green:118/255.0 blue:241/255.0 alpha:1.0];
    [slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    self.slider = slider;
    
    NGCustomBar *customBar = [[NGCustomBar alloc] initWithFrame:CGRectMake(0, self.height - kBarHeight - 5, kMainScreenWidth, kBarHeight)];
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < self.editModels.count; i++)
    {
        NGEditModel *editModel = self.editModels[i];
        NGCustomButton *item = [[NGCustomButton alloc] initWithFrame:CGRectZero];
        item.title = editModel.name;
        item.normalImage = editModel.normalImage;
        item.selectedImage = editModel.selectedImage;
        [items addObject:item];
    }
    customBar.items = items;
    customBar.customBarDelegate = self;
    [customBar setSelectedButton:[customBar.items objectAtIndex:0]];
    [self customBar:customBar didSelectItemAtIndex:0];
    [self addSubview:customBar];
    self.customBar = customBar;
}

- (void)reloadData
{
    [self createData];
    [self.customBar setSelectedButton:[self.customBar.items objectAtIndex:0]];
    [self customBar:self.customBar didSelectItemAtIndex:0];
    [self.imagePicture removeAllTargets];
    [self.filterGroup removeAllTargets];
}

- (void)customBar:(NGCustomBar *)bar didSelectItemAtIndex:(NSInteger)index
{
    NGEditModel *editModel = self.editModels[index];
    self.slider.maximumValue = editModel.maximumValue;
    self.slider.minimumValue = editModel.minimumValue;
    self.slider.value = editModel.value;
    _selectedIndex = index;
}

#pragma mark - slider
- (void)sliderValueChange:(UISlider *)slider
{
}

- (void)sliderTouchEnd:(UISlider *)slider
{
    NGEditModel *editMdoel = self.editModels[_selectedIndex];
    editMdoel.value = slider.value;
    [self changeValueForFilter:_filters[_selectedIndex]
                         index:_selectedIndex
                         value:slider.value
                         image:self.image];
    
    if (_isVideo) {
        if (self.editVdeoClick) {
            NGEditFilterModel *model = [[NGEditFilterModel alloc] init];
            model.index = _selectedIndex;
            model.value = slider.value;
            self.editVdeoClick(model);
        }
    } else {
        [self.imagePicture processImage];
        [self.filterGroup useNextFrameForImageCapture];
        currentImage = [self.filterGroup imageFromCurrentFramebuffer];
        if (self.editClick) {
            self.editClick(currentImage);
        }
    }
}

- (void)changeValueForFilter:(GPUImageOutput<GPUImageInput> *)filter
                       index:(NSInteger)index
                       value:(CGFloat)value
                       image:(UIImage *)image
{
    switch (index) {
        case 0: {
            [FWApplyFilter changeValueForBrightnessFilte:(GPUImageBrightnessFilter *)filter
                                                            value:value
                                                            image:image];
            break;
        }
        case 1: {
            [FWApplyFilter changeValueForContrastFilter:(GPUImageContrastFilter *)filter
                                                           value:value
                                                           image:image];
            break;
        }
        case 2: {
            [FWApplyFilter changeValueForWhiteBalanceFilter:(GPUImageWhiteBalanceFilter *)filter
                                                               value:value
                                                               image:image];
            break;
        }
        case 3: {
            [FWApplyFilter changeValueForSaturationFilter:(GPUImageSaturationFilter *)filter
                                                             value:value
                                                             image:image];
            break;
        }
        case 4: {
            [FWApplyFilter changeValueForHighlightFilter:(GPUImageHighlightShadowFilter *)filter
                                                            value:value
                                                            image:image];
            break;
        }
        case 5: {
            [FWApplyFilter changeValueForLowlightFilter:(GPUImageHighlightShadowFilter *)filter
                                                           value:value
                                                           image:image];
            break;
        }
        case 6: {
            [FWApplyFilter changeValueForExposureFilter:(GPUImageExposureFilter *)filter
                                                           value:value
                                                           image:image];
            break;
        }
        case 7: {
            [FWApplyFilter changeValueForSharpenilter:(GPUImageSharpenFilter *)filter
                                                         value:value
                                                         image:image];
            break;
        }
        default:
            break;
    }
}

- (void)setUpFilters
{
    _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    _contrastFilter = [[GPUImageContrastFilter alloc] init];
    _whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    _saturationFilter = [[GPUImageSaturationFilter alloc] init];
    _highlightFilter = [[GPUImageHighlightShadowFilter alloc] init];
    _lowlightFilter = [[GPUImageHighlightShadowFilter alloc] init];
    _exposureFilter = [[GPUImageExposureFilter alloc] init];
    _sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    [_filters addObject:_brightnessFilter];
    [_filters addObject:_contrastFilter];
    [_filters addObject:_whiteBalanceFilter];
    [_filters addObject:_saturationFilter];
    [_filters addObject:_highlightFilter];
    [_filters addObject:_lowlightFilter];
    [_filters addObject:_exposureFilter];
    [_filters addObject:_sharpenFilter];
}

- (void)addFilters
{
    for (GPUImageOutput<GPUImageInput> *filter in _filters) {
        [self addFilter:filter];
    }
}

- (void)addFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [self addGPUImageFilter:filter filterGroup:_filterGroup];
}

// 将滤镜加在FilterGroup中并且设置初始滤镜和末尾滤镜
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter filterGroup:(GPUImageFilterGroup *)filterGroup
{
    [filterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = filterGroup.filterCount;
    
    if (count == 1)
    {
        //设置初始滤镜
        filterGroup.initialFilters = @[newTerminalFilter];
        //设置末尾滤镜
        filterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter = filterGroup.terminalFilter;
        NSArray *initialFilters                       = filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        //设置初始滤镜
        filterGroup.initialFilters = @[initialFilters[0]];
        //设置末尾滤镜
        filterGroup.terminalFilter = newTerminalFilter;
    }
}

#pragma mark - setter
- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imagePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    self.filterGroup = [[GPUImageFilterGroup alloc] init];
    [self.imagePicture addTarget:self.filterGroup];
}

- (void)setFilterGroup:(GPUImageFilterGroup *)filterGroup
{
    _filterGroup = filterGroup;
    [self addFilters];
}

@end

@implementation NGEditFilterModel

@end
