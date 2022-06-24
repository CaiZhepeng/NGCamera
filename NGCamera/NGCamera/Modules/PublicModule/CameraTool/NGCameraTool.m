//
//  NGCameraTool.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/4.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraTool.h"


static void* ISOContext;
static void* ISOAdjustingContext;
static void* FocusAdjustingContext;
static void* ExposureTargetOffsetContext;

@implementation NGCameraTool

+ (instancetype)shareCameraTool
{
    static NGCameraTool *sManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sManager = [[self alloc] init];
    });
    return sManager;
}

- (void)registerObserver
{
    [self.inputCamera addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:&ISOContext];
    [self.inputCamera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:&FocusAdjustingContext];
    [self.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&ISOAdjustingContext];
    [self.inputCamera addObserver:self forKeyPath:@"exposureTargetOffset" options:NSKeyValueObservingOptionNew context:&ExposureTargetOffsetContext];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    NSLog(@"key = %@", keyPath);
    
    if (&ISOContext == context) {
        if (_ISOChangeBlock) {
            _ISOChangeBlock([change[NSKeyValueChangeNewKey] floatValue]);
        }
    }else if (&ISOAdjustingContext == context) {
        if (_ISOAdjustingBlock) {
            _ISOAdjustingBlock([change[NSKeyValueChangeNewKey] boolValue]);
        }
    }else if (&FocusAdjustingContext == context) {
        if (_FocusAdjustingBlock) {
            _FocusAdjustingBlock([change[NSKeyValueChangeNewKey] boolValue]);
        }
    }else if (&ExposureTargetOffsetContext == context) {

    }
}

- (void)setInputCamera:(AVCaptureDevice *)inputCamera
{
    _inputCamera = inputCamera;
    [self registerObserver];
}

#pragma mark - 调整焦距
- (BOOL)isFocusPointOfInterestSupported
{
    return [self.inputCamera isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point
{
    if (![self.inputCamera isFocusPointOfInterestSupported]) {
        return;
    }
    
    // 一定要先设置位置，再设置对焦模式。
    if ([self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([_inputCamera lockForConfiguration:&error]) {
            _inputCamera.focusPointOfInterest = point;
            _inputCamera.focusMode = AVCaptureFocusModeAutoFocus;
            [_inputCamera unlockForConfiguration];
        }
    }
}

- (void)setFocusModel:(AVCaptureFocusMode)focusModel
{
    if (![self.inputCamera isFocusPointOfInterestSupported]) {
        return;
    }
    
    if ([self.inputCamera isFocusModeSupported:focusModel]) {
        NSError *error;
        if ([_inputCamera lockForConfiguration:&error]) {
            _inputCamera.focusMode = focusModel;
            [_inputCamera unlockForConfiguration];
        }
    }
}

- (BOOL)isAutoFocusRangeRestrictionSupported
{
    return [self.inputCamera isAutoFocusRangeRestrictionSupported];
}

-  (void)setAutoFocusRangeRestrictionModel:(AVCaptureAutoFocusRangeRestriction)autoFocusModel
{
    if (![self.inputCamera isAutoFocusRangeRestrictionSupported]) {
        return;
    }
    
    if ([self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            self.inputCamera.autoFocusRangeRestriction = autoFocusModel;
            [self.inputCamera unlockForConfiguration];
        }
    }
}

- (BOOL)isSmoothAutoFocusSupported
{
    return [self.inputCamera isSmoothAutoFocusSupported];
}

- (void)enableSmoothAutoFocus:(BOOL)enable
{
    if (![self.inputCamera isSmoothAutoFocusSupported]) {
        return;
    }
    
    if ([self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([_inputCamera lockForConfiguration:&error]) {
            _inputCamera.smoothAutoFocusEnabled = enable;
        }
    }
}

#pragma mark - 曝光
- (BOOL)isExposurePointOfInterestSupported
{
    return [self.inputCamera isExposurePointOfInterestSupported];
}

- (void)setExposeModel:(AVCaptureExposureMode)exposeModel
{
    if ([self.inputCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            self.inputCamera.exposureMode = AVCaptureExposureModeAutoExpose;
            [self.inputCamera unlockForConfiguration];
        }
    }
}

- (void)exposeAtPoint:(CGPoint)point
{
    if (![self.inputCamera isExposurePointOfInterestSupported]) {
        return;
    }
    
    if ([self.inputCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            self.inputCamera.exposurePointOfInterest = point;
            self.inputCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [self.inputCamera unlockForConfiguration];
        }
    }
}

- (float)exposureTargetOffset
{
    return [self.inputCamera exposureTargetOffset];
}

- (void)setExposureModeCustomWithDuration:(CMTime)duration ISO:(float)ISO completionHandler:(void (^)(CMTime))handler
{
    CGFloat minISO = self.inputCamera.activeFormat.minISO;
    CGFloat maxISO = self.inputCamera.activeFormat.maxISO;
    
    ISO = ISO * (maxISO - minISO) + minISO;
    ISO = MAX(MIN(ISO, maxISO), minISO);
    
    NSError *error;
    if ([self.inputCamera lockForConfiguration:&error]) {
        [self.inputCamera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:ISO completionHandler:^(CMTime syncTime) {
            if (handler) {
                handler(syncTime);
            }
        }];
        [self.inputCamera unlockForConfiguration];
    }else {
        if (handler) {
            handler(kCMTimeInvalid);
        }
    }
}

- (CGFloat)currentISOPercentage
{
    CGFloat minISO = self.inputCamera.activeFormat.minISO;
    CGFloat maxISO = self.inputCamera.activeFormat.maxISO;
    CGFloat current = self.inputCamera.ISO;
    NSLog(@"current %f minISO %f maxISO %f", current, minISO, maxISO);
    return (current - minISO)/(maxISO - minISO);
}

#pragma mark - 闪光灯
- (AVCaptureFlashMode)currentFlashModel
{
    return self.inputCamera.flashMode;
}

- (void)setFlashModel:(AVCaptureFlashMode)flashModel
{
    if (self.inputCamera.flashMode == flashModel) {
        return;
    }
    
    if ([self.inputCamera isFlashModeSupported:flashModel]) {
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            self.inputCamera.flashMode = flashModel;
            [self.inputCamera unlockForConfiguration];
        }
    }
}

#pragma mark - 白平衡
- (AVCaptureWhiteBalanceMode)currentWhiteBalanceMode
{
    return self.inputCamera.whiteBalanceMode;
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    if (self.inputCamera.whiteBalanceMode == whiteBalanceMode) {
        return;
    }
    
    if ([self.inputCamera isWhiteBalanceModeSupported:whiteBalanceMode]) {
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            [self.inputCamera setWhiteBalanceMode:whiteBalanceMode];
            [self.inputCamera unlockForConfiguration];
        }
    }
}

#pragma mark - 手电筒
- (AVCaptureTorchMode)currentTorchModel
{
    return self.inputCamera.torchMode;
}

- (void)setTorchModel:(AVCaptureTorchMode)torchModel
{
    if (self.inputCamera.torchMode == torchModel) {
        return;
    }
    
    if ([self.inputCamera isTorchModeSupported:torchModel]) {
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            self.inputCamera.torchMode = torchModel;
            [self.inputCamera unlockForConfiguration];
        }
    }
}

- (void)setTorchLevel:(float)torchLevel
{
    if ([self.inputCamera isTorchActive]) {
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            [self.inputCamera setTorchModeOnWithLevel:torchLevel error:&error];
            [self.inputCamera unlockForConfiguration];
        }
    }
}

#pragma mark - 视频缩放
- (BOOL)videoCanZoom
{
    return self.inputCamera.activeFormat.videoMaxZoomFactor > 1.0f;
}

- (float)videoMaxZoomFactor
{
    return MIN(self.inputCamera.activeFormat.videoMaxZoomFactor, 4.0f);
}

- (float)videoZoomFactor
{
    return self.inputCamera.videoZoomFactor;
}

- (void)setVideoZoomFactor:(float)factor
{
    if (self.inputCamera.isRampingVideoZoom) {
        return;
    }
    
    NSError *error;
    if ([self.inputCamera lockForConfiguration:&error]) {
        factor = MAX(MIN(factor, [self videoMaxZoomFactor]), 1.0f);
        self.inputCamera.videoZoomFactor = factor;
        [self.inputCamera unlockForConfiguration];
    }
}

- (void)rampZoomToFactor:(float)factor
{
    if (self.inputCamera.isRampingVideoZoom) {
        return;
    }
    
    NSError *error;
    if ([self.inputCamera lockForConfiguration:&error]) {
        [self.inputCamera rampToVideoZoomFactor:pow([self videoMaxZoomFactor], factor) withRate:50.0f];
        [self.inputCamera unlockForConfiguration];
    }
}

+ (UIImage *)getScreenShotImageFromVideoPath:(AVURLAsset *)urlAsset
                               withStartTime:(CGFloat)startTime
                               withTimescale:(CGFloat)timescale
                                  isKeyImage:(BOOL)isKeyImage {
    if (timescale == 0) {
        timescale = [urlAsset duration].timescale;
    }
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    UIImage *shotImage;
    NSError *error = nil;
    
    CMTime time = CMTimeMake(startTime, 1);
    if (!isKeyImage) {
        assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        time = CMTimeMake(startTime * timescale, timescale);
    }

    CGImageRef image = [assetImageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}


+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url {
    NSUInteger degress = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

+ (void)mergeFreeVideoFilePath:(NSArray<NSURL *> *)videoPathArray
                 mergeFilePath:(NSString*)str_merge_path
                 withCropRatio:(CGFloat)ratio
         withCompletionHandler:(void (^)(void))hanlder
{
    if (videoPathArray.count == 0 || str_merge_path.length == 0) {
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:str_merge_path]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:str_merge_path] error:nil];
    }
    
    NSError *error = nil;
    CGSize renderSize = CGSizeMake(0, 0);
    CMTime totalDuration = kCMTimeZero;
    NSMutableArray *layerInstructionArray = [NSMutableArray array];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //先去assetTrack 也为了取renderSize
    NSMutableArray *videoTrackArrayM = [NSMutableArray array];
    NSMutableArray *audioTrackArrayM = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    for (NSURL *url in videoPathArray) {
        AVAsset *asset = [AVAsset assetWithURL:url];
        if (!asset) {
            continue;
        }
        [assetArray addObject:asset];
        
        NSArray *videoTrackArray = [asset tracksWithMediaType:AVMediaTypeVideo];
        NSArray *audioTrackArray = [asset tracksWithMediaType:AVMediaTypeAudio];
        if (videoTrackArray.count == 0 || audioTrackArray.count == 0) {
            NSLog(@"asset里没有视频或音频");
            return;
        }
        
        AVAssetTrack *assetVideoTrack = [videoTrackArray objectAtIndex:0];
        AVAssetTrack *assetAudioTrack = [audioTrackArray objectAtIndex:0];
        [videoTrackArrayM addObject:assetVideoTrack];
        [audioTrackArrayM addObject:assetAudioTrack];
        
        renderSize.width = MAX(renderSize.width, assetVideoTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetVideoTrack.naturalSize.width);
        NSLog(@"%f %f", assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    CGFloat renderH = renderW * ratio;
    CGFloat rate = renderW / MIN(renderSize.width, renderSize.height);
    NSLog(@"renderW: %f renderH: %f rate: %f", renderW, renderH, rate);
    for (int i = 0; i < [assetArray count] && i < [videoTrackArrayM count]; i++) {
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetVideoTrack = [videoTrackArrayM objectAtIndex:i];
        AVAssetTrack *assetAudioTrack = [audioTrackArrayM objectAtIndex:i];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        BOOL isSuccess = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                             ofTrack:assetVideoTrack
                                              atTime:totalDuration
                                               error:&error];
        NSLog(@"加入视频 errorVideo:%@ %d",error, isSuccess);
        NSError *errorAudio = nil;
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

        isSuccess = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                             ofTrack:assetAudioTrack
                                              atTime:totalDuration
                                               error:&errorAudio];
        NSLog(@"加入音频 errorVideo:%@ %d",errorAudio, isSuccess);
        //fix orientation issue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        // rotate and position video since it may have been cropped to screen ratio
        CGAffineTransform layerTransform = CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx * rate, assetVideoTrack.preferredTransform.ty * rate);
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, (renderH - assetVideoTrack.naturalSize.height) / 2.0));//向上移动取中部影响
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称

        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    //get save path
    NSURL *mergeFileURL = [NSURL fileURLWithPath:str_merge_path];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderH);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:hanlder];
}

@end
