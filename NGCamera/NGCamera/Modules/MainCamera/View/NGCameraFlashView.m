//
//  NGCameraFlashView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/12.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraFlashView.h"

@implementation NGCameraFlashView

+ (instancetype)flashSuspensionView
{
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"flash" ofType:@"json"];
    
    CGRect rect = CGRectMake(0, 0, kMainScreenWidth, kCameraRatioSuspensionViewHeight);
    NGCameraFlashView *view = [[NGCameraFlashView alloc] initWithFrame:rect];
    view.suspensionModels = [NGSuspensionModel buildSuspensionModelsWithConfig:configPath];
    view.hidden = YES;
    
    WeakSelf(view);
    view.suspensionModelClickBlock = ^(NGSuspensionModel * _Nonnull model) {
        StrongSelf(view);
        [view hide];
        if (view.flashCallBack) {
            AVCaptureFlashMode flash = AVCaptureFlashModeOff;
            AVCaptureTorchMode torch = AVCaptureTorchModeOff;
            switch (model.type) {
                case FlashTypeNone:
                    flash = AVCaptureFlashModeOff;
                    break;
                case FlashTypeAuto:
                    flash = AVCaptureFlashModeAuto;
                    break;
                case FlashTypeAlways:
                    flash = AVCaptureFlashModeOn;
                    break;
                case FlashTypeTorch:
                    torch = AVCaptureTorchModeOn;
                    break;
                default:
                    break;
            }
            view.flashCallBack(flash, torch, model.icon);
        }
    };
    return view;
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60,self.frame.size.height/2);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    return layout;
}

@end
