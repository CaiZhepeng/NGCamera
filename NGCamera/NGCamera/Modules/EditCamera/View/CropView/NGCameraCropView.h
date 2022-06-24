//
//  NGCropView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/21.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGCropModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NGCameraCropView : UIView

@property (nonatomic,strong) NSArray<NGCropModel *> *cropModels;
@property (nonatomic,copy) void(^clickBlock)(CGSize aspect, CGFloat rotation, UIImageOrientation imageOrientation);
@property (nonatomic,copy) void(^sliderBlock)(CGFloat rotation);
@property (nonatomic,copy) void(^didFinishBlock)(void);

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
