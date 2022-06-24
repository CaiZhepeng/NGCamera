//
//  NGCameraRatioView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/12.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGSuspensionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NGCameraRatioView : NGSuspensionView
@property (nonatomic, copy) void (^ratioCallBack)(NGSuspensionModel *model);
+ (instancetype)ratioSuspensionView;
@end

NS_ASSUME_NONNULL_END
