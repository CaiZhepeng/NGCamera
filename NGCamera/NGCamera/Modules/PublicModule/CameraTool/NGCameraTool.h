//
//  NGCameraTool.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/4.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGCameraTool : NSObject

@property (nonatomic,copy) void(^ISOChangeBlock)(float ISO);
@property (nonatomic,copy) void(^ISOAdjustingBlock)(BOOL adjust);
@property (nonatomic,copy) void(^FocusAdjustingBlock)(BOOL adjust);
@property (nonatomic,strong) AVCaptureDevice *inputCamera;

+ (instancetype)shareCameraTool;

// Focus
- (BOOL)isFocusPointOfInterestSupported;
- (void)focusAtPoint:(CGPoint)point;
- (void)setFocusModel:(AVCaptureFocusMode)focusModel;

- (BOOL)isAutoFocusRangeRestrictionSupported;
- (void)setAutoFocusRangeRestrictionModel:(AVCaptureAutoFocusRangeRestriction)autoFocusModel;

- (BOOL)isSmoothAutoFocusSupported;
- (void)enableSmoothAutoFocus:(BOOL)enable;

// Exposure
- (BOOL)isExposurePointOfInterestSupported;
- (void)setExposeModel:(AVCaptureExposureMode)exposeModel;
- (void)exposeAtPoint:(CGPoint)point;
- (float)exposureTargetOffset;
- (CGFloat)currentISOPercentage;
- (void)setExposureModeCustomWithDuration:(CMTime)duration ISO:(float)ISO completionHandler:(void (^)(CMTime syncTime))handler;

// Flash
- (AVCaptureFlashMode)currentFlashModel;
- (void)setFlashModel:(AVCaptureFlashMode)flashModel;

// WhiteBalance
- (AVCaptureWhiteBalanceMode)currentWhiteBalanceMode;
- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode;

// Torch
- (AVCaptureTorchMode)currentTorchModel;
- (void)setTorchModel:(AVCaptureTorchMode)torchModel;
- (void)setTorchLevel:(float)torchLevel;

// Zoom
- (BOOL)videoCanZoom;
- (float)videoZoomFactor;
- (float)videoMaxZoomFactor;
- (void)setVideoZoomFactor:(float)factor;
- (void)rampZoomToFactor:(float)factor;

// 获取帧视频图片
+ (UIImage *)getScreenShotImageFromVideoPath:(AVURLAsset *)urlAsset
                               withStartTime:(CGFloat)startTime
                               withTimescale:(CGFloat)timescale
                                  isKeyImage:(BOOL)isKeyImage;

// degress
+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url;

//merge and export videos
+ (void)mergeFreeVideoFilePath:(NSArray<NSURL *> *)videoPathArray
                 mergeFilePath:(NSString*)str_merge_path
                 withCropRatio:(CGFloat)ratio
         withCompletionHandler:(void (^)(void))hanlder;

@end

NS_ASSUME_NONNULL_END
