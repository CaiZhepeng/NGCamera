//
//  FWCommonFilter.m
//  FWMeituApp
//
//  Created by ForrestWoo on 15-10-2.
//  Copyright (c) 2015年 ForrestWoo co,.ltd. All rights reserved.
//

#import "FWApplyFilter.h"
#import "FWNashvilleFilter.h"
#import "FWLordKelvinFilter.h"
#import "FWAmaroFilter.h"
#import "FWRiseFilter.h"
#import "FWHudsonFilter.h"
#import "FW1977Filter.h"
#import "FWValenciaFilter.h"
#import "FWXproIIFilter.h"
#import "FWWaldenFilter.h"
#import "FWLomofiFilter.h"
#import "FWInkwellFilter.h"
#import "FWSierraFilter.h"
#import "FWEarlybirdFilter.h"
#import "FWSutroFilter.h"
#import "FWToasterFilter.h"
#import "FWBrannanFilter.h"
#import "FWHefeFilter.h"


@implementation FWApplyFilter

#pragma mark - 编辑
+ (GPUImageBrightnessFilter *)changeValueForBrightnessFilte:(GPUImageBrightnessFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageBrightnessFilter alloc] init];
    }
    filter.brightness = value;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (GPUImageContrastFilter *)changeValueForContrastFilter:(GPUImageContrastFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageContrastFilter alloc] init];
    }
    filter.contrast = value;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (GPUImageHighlightShadowFilter *)changeValueForHighlightFilter:(GPUImageHighlightShadowFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageHighlightShadowFilter alloc] init];
    }
    filter.highlights = value;
    filter.shadows = 0.0;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (GPUImageHighlightShadowFilter *)changeValueForLowlightFilter:(GPUImageHighlightShadowFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageHighlightShadowFilter alloc] init];
    }
    filter.highlights = 1.0;
    filter.shadows = value;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (GPUImageSaturationFilter *)changeValueForSaturationFilter:(GPUImageSaturationFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageSaturationFilter alloc] init];
    }
    filter.saturation = value;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (GPUImageSharpenFilter *)changeValueForSharpenilter:(GPUImageSharpenFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageSharpenFilter alloc] init];
    }
    filter.sharpness = value;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (GPUImageExposureFilter *)changeValueForExposureFilter:(GPUImageExposureFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageExposureFilter alloc] init];
    }
    filter.exposure = value;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (GPUImageWhiteBalanceFilter *)changeValueForWhiteBalanceFilter:(GPUImageWhiteBalanceFilter *)filter value:(float)value image:(UIImage *)image
{
    if (filter == nil) {
        filter = [[GPUImageWhiteBalanceFilter alloc] init];
    }
    filter.temperature = value;
    filter.tint = 0.0;
    if (image) {
        [filter forceProcessingAtSize:image.size];
    }
    return filter;
}

+ (UIImage *)changeValueForMissEtikateFilter:(float)value image:(UIImage *)image
{
    GPUImageMissEtikateFilter *filter = [[GPUImageMissEtikateFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)changeValueForSoftEleganceFilter:(float)value image:(UIImage *)image
{
    GPUImageSoftEleganceFilter *filter = [[GPUImageSoftEleganceFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

#pragma mark - 滤镜
+ (UIImage *)applyToLookupFilter:(UIImage *)image
{
    FWLordKelvinFilter *filter = [[FWLordKelvinFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyAmatorkaFilter:(UIImage *)image
{
    GPUImageAmatorkaFilter *filter = [[GPUImageAmatorkaFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyMissetikateFilter:(UIImage *)image
{
    GPUImageMissEtikateFilter *filter = [[GPUImageMissEtikateFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applySoftEleganceFilter:(UIImage *)image
{
    GPUImageSoftEleganceFilter *filter = [[GPUImageSoftEleganceFilter alloc] init];
    [filter forceProcessingAtSize:CGSizeMake(image.size.width / 2.0, image.size.height / 2.0)];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyNashvilleFilter:(UIImage *)image
{
    FWNashvilleFilter *filter = [[FWNashvilleFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyLordKelvinFilter:(UIImage *)image
{
    FWLordKelvinFilter *filter = [[FWLordKelvinFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyAmaroFilter:(UIImage *)image
{
    FWAmaroFilter *filter = [[FWAmaroFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyRiseFilter:(UIImage *)image
{
    FWRiseFilter *filter = [[FWRiseFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyHudsonFilter:(UIImage *)image
{
    FWHudsonFilter *filter = [[FWHudsonFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyXproIIFilter:(UIImage *)image
{
    FWXproIIFilter *filter = [[FWXproIIFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)apply1977Filter:(UIImage *)image
{
    FW1977Filter *filter = [[FW1977Filter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyValenciaFilter:(UIImage *)image
{
    FWValenciaFilter *filter = [[FWValenciaFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}
+ (UIImage *)applyWaldenFilter:(UIImage *)image
{
    FWWaldenFilter *filter = [[FWWaldenFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyLomofiFilter:(UIImage *)image
{
    FWLomofiFilter *filter = [[FWLomofiFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyInkwellFilter:(UIImage *)image
{
    FWInkwellFilter *filter = [[FWInkwellFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applySierraFilter:(UIImage *)image
{
    FWSierraFilter *filter = [[FWSierraFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyEarlybirdFilter:(UIImage *)image
{
    FWEarlybirdFilter *filter = [[FWEarlybirdFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applySutroFilter:(UIImage *)image
{
    FWSutroFilter *filter = [[FWSutroFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyToasterFilter:(UIImage *)image
{
    FWToasterFilter*filter = [[FWToasterFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyBrannanFilter:(UIImage *)image
{
    FWBrannanFilter *filter = [[FWBrannanFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyHefeFilter:(UIImage *)image
{
    FWHefeFilter *filter = [[FWHefeFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyGlassFilter:(UIImage *)image
{
    GPUImageGlassSphereFilter *filter = [[GPUImageGlassSphereFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyBoxBlur:(UIImage *)image
{
    GPUImageBoxBlurFilter *filter = [[GPUImageBoxBlurFilter alloc] init];
    
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyGaussianBlur:(UIImage *)image
{
    GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
    filter.blurRadiusInPixels = 5.0;
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyGaussianSelectiveBlur:(UIImage *)image
{
    GPUImageGaussianSelectiveBlurFilter *filter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
    filter.excludeCircleRadius = 50 / 320.0;
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyiOSBlur:(UIImage *)image
{
    GPUImageiOSBlurFilter *filter = [[GPUImageiOSBlurFilter alloc] init];
    filter.saturation = 0.8;
    
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyMotionBlur:(UIImage *)image
{
    GPUImageMotionBlurFilter *filter = [[GPUImageMotionBlurFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyZoomBlur:(UIImage *)image
{
    GPUImageZoomBlurFilter *filter = [[GPUImageZoomBlurFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}
+ (UIImage *)applyColorInvertFilter:(UIImage *)image
{
    GPUImageColorInvertFilter *filter = [[GPUImageColorInvertFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applySepiaFilter:(UIImage *)image
{
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyHistogramFilter:(UIImage *)image
{
    GPUImageHistogramGenerator *filter = [[GPUImageHistogramGenerator alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    
    return [filter imageFromCurrentFramebuffer];
}


+ (UIImage *)applyRGBFilter:(UIImage *)image
{
    GPUImageRGBFilter *filter = [[GPUImageRGBFilter alloc] init];
    filter.red = 0.3;
    filter.green = 0.3;
    filter.blue = 0.3;
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applyToneCurveFilter:(UIImage *)image
{
    GPUImageToneCurveFilter *filter = [[GPUImageToneCurveFilter alloc] init];

    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    
    return [filter imageFromCurrentFramebuffer];
}

+ (UIImage *)applySketchFilter:(UIImage *)image
{
    GPUImageSketchFilter *filter = [[GPUImageSketchFilter alloc] init];
    
    [filter forceProcessingAtSize:CGSizeMake(image.size.width / 3.0, image.size.height / 3.0)];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    
    return [filter imageFromCurrentFramebuffer];
}
@end
