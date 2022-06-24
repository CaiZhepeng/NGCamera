//
//  NGVideoCaptureView.h
//  NGCamera
//
//  Created by caizhepeng on 2020/3/17.
//  Copyright © 2020 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGVideoClipView : UIView

@property (nonatomic,assign) CGFloat currentTime;

@property (nonatomic,copy) void(^getVideoTimeRange)(CGFloat startTime, CGFloat endTime, CGFloat jumpTime);

@property (nonatomic,copy) void(^didDragEnd)(void);

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
