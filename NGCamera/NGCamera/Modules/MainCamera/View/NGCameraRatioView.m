//
//  NGCameraRatioView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/12.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraRatioView.h"

@implementation NGCameraRatioView

+ (instancetype)ratioSuspensionView;
{
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"homecrop" ofType:@"json"];
    
    CGRect rect = CGRectMake(kCameraRatioSuspensionViewMargin, 0, kMainScreenWidth - 2*kCameraRatioSuspensionViewMargin, kCameraRatioSuspensionViewHeight);
    NGCameraRatioView *view = [[NGCameraRatioView alloc] initWithFrame:rect];
    view.suspensionModels = [NGSuspensionModel buildSuspensionModelsWithConfig:configPath];
    view.hidden = YES;
    
    WeakSelf(view);
    view.suspensionModelClickBlock = ^(NGSuspensionModel * _Nonnull model) {
        StrongSelf(view);
        [view hide];
        if (view.ratioCallBack) {
            view.ratioCallBack(model);
        }
    };
    return view;
}

@end
