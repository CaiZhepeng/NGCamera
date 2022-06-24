//
//  NGCameraPreview.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/5.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "GPUImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NGCameraPreview : GPUImageView

@property (nonatomic,copy) void(^handlePinchGestureBlock)(UIPinchGestureRecognizer *pinchGesture);
@property (nonatomic,copy) void(^handleTapGestureBlock)(UITapGestureRecognizer *tapGesture);

@end

NS_ASSUME_NONNULL_END
