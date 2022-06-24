//
//  NGCameraFlashView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/12.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGSuspensionView.h"

NS_ASSUME_NONNULL_BEGIN

// 闪关灯类型
typedef enum {
    FlashTypeNone = 1,
    FlashTypeAuto,
    FlashTypeAlways,
    FlashTypeTorch
} FlashType;

@interface NGCameraFlashView : NGSuspensionView
@property (nonatomic, copy) void (^flashCallBack)(AVCaptureFlashMode flash, AVCaptureTorchMode torch, NSString *icon);
+ (instancetype)flashSuspensionView;

@end

NS_ASSUME_NONNULL_END
