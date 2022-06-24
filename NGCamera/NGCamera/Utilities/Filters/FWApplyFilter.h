//
//  FWCommonFilter.h
//  FWMeituApp
//
//  Created by ForrestWoo on 15-10-2.
//  Copyright (c) 2015年 ForrestWoo co,.ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWApplyFilter : NSObject

//亮度
+ (GPUImageBrightnessFilter *)changeValueForBrightnessFilte:(GPUImageBrightnessFilter *)filter
                                                      value:(float)value
                                                      image:(UIImage *)image;

//对比度
+ (GPUImageContrastFilter *)changeValueForContrastFilter:(GPUImageContrastFilter *)filter
                                                   value:(float)value
                                                   image:(UIImage *)image;

//色温
+ (GPUImageWhiteBalanceFilter *)changeValueForWhiteBalanceFilter:(GPUImageWhiteBalanceFilter *)filter
                                                           value:(float)value
                                                           image:(UIImage *)image;

//饱和度
+ (GPUImageSaturationFilter *)changeValueForSaturationFilter:(GPUImageSaturationFilter *)filter
                                                       value:(float)value
                                                       image:(UIImage *)image;

//高光
+ (GPUImageHighlightShadowFilter *)changeValueForHighlightFilter:(GPUImageHighlightShadowFilter *)filter
                                                           value:(float)value
                                                           image:(UIImage *)image;

//暗部
+ (GPUImageHighlightShadowFilter *)changeValueForLowlightFilter:(GPUImageHighlightShadowFilter *)filter
                                                          value:(float)value
                                                          image:(UIImage *)image;

//智能补光
+ (GPUImageExposureFilter *)changeValueForExposureFilter:(GPUImageExposureFilter *)filter
                                                   value:(float)value
                                                   image:(UIImage *)image;

//锐化
+ (GPUImageSharpenFilter *)changeValueForSharpenilter:(GPUImageSharpenFilter *)filter
                                                value:(float)value
                                                image:(UIImage *)image;

//复杂滤镜
+ (UIImage *)applyAmatorkaFilter:(UIImage *)image;

+ (UIImage *)applyMissetikateFilter:(UIImage *)image;

+ (UIImage *)applySoftEleganceFilter:(UIImage *)image;

+ (UIImage *)applyNashvilleFilter:(UIImage *)image;

+ (UIImage *)applyLordKelvinFilter:(UIImage *)image;

+ (UIImage *)applyAmaroFilter:(UIImage *)image;

+ (UIImage *)applyRiseFilter:(UIImage *)image;

+ (UIImage *)applyHudsonFilter:(UIImage *)image;

+ (UIImage *)applyXproIIFilter:(UIImage *)image;

+ (UIImage *)apply1977Filter:(UIImage *)image;

+ (UIImage *)applyValenciaFilter:(UIImage *)image;

+ (UIImage *)applyWaldenFilter:(UIImage *)image;

+ (UIImage *)applyLomofiFilter:(UIImage *)image;

+ (UIImage *)applyInkwellFilter:(UIImage *)image;

+ (UIImage *)applySierraFilter:(UIImage *)image;

+ (UIImage *)applyEarlybirdFilter:(UIImage *)image;

+ (UIImage *)applySutroFilter:(UIImage *)image;

+ (UIImage *)applyToasterFilter:(UIImage *)image;

+ (UIImage *)applyBrannanFilter:(UIImage *)image;

+ (UIImage *)applyHefeFilter:(UIImage *)image;

+ (UIImage *)applyGlassFilter:(UIImage *)image;

//盒状模糊
+ (UIImage *)applyBoxBlur:(UIImage *)image;

// 高斯模糊
+ (UIImage *)applyGaussianBlur:(UIImage *)image;

// 保证圆形区域内清晰的高斯模糊
+ (UIImage *)applyGaussianSelectiveBlur:(UIImage *)image;

// 毛玻璃效果
+ (UIImage *)applyiOSBlur:(UIImage *)image;

// 定向运动模糊
+ (UIImage *)applyMotionBlur:(UIImage *)image;

// 定向运动模糊
+ (UIImage *)applyZoomBlur:(UIImage *)image;

// 反色
+ (UIImage *)applyColorInvertFilter:(UIImage *)image;

// 褐色（怀旧）
+ (UIImage *)applySepiaFilter:(UIImage *)image;

// 色彩直方图，显示在图片上
+ (UIImage *)applyHistogramFilter:(UIImage *)image;

// RGB
+ (UIImage *)applyRGBFilter:(UIImage *)image;

// 色调曲线
+ (UIImage *)applyToneCurveFilter:(UIImage *)image;

// 素描
+ (UIImage *)applySketchFilter:(UIImage *)image;


@end
