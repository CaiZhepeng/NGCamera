//
//  NGCameraFilterView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/10.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGCameraFilterView : UIView

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,copy) void(^filterClick)(UIImage *image, NSString *filterName);

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
