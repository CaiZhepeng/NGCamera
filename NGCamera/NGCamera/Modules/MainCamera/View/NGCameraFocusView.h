//
//  NGCameraFocusView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/5.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGCameraFocusView : UIView

@property(nonatomic,copy) void (^luminanceChangeBlock)(CGFloat value);

+ (instancetype)focusView;
- (void)foucusAtPoint:(CGPoint)center withPreViewFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
