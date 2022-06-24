//
//  NGCustomSlider.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/18.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGCustomSlider : UISlider

@property(nonatomic,strong) UILabel *sliderValueLabel;
@property (nonatomic,assign) NSInteger maxTipValue;
@property (nonatomic,assign) NSInteger minTipValue;
@end

NS_ASSUME_NONNULL_END
