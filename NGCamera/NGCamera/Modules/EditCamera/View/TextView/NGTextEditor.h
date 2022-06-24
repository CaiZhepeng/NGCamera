//
//  NGTextEditor.h
//  NGCamera
//
//  Created by caizhepeng on 2019/11/6.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGText.h"

NS_ASSUME_NONNULL_BEGIN

@interface NGTextEditor : UIView

@property (nonatomic,assign) CGFloat minScale;
@property (nonatomic,assign) CGFloat maxScale;
@property (nonatomic,assign) CGFloat deactivatedDelay;

@property (nonatomic,readonly) BOOL isActive;
@property (nonatomic,readonly) CGFloat scale;
@property (nonatomic,readonly) CGFloat rotation;
@property (nonatomic,strong) NGText *text;
@property (nonatomic,copy) void(^tapTextBlock)(NGTextEditor *textEditor);
@property (nonatomic,copy) BOOL(^moveCenter)(CGRect rect);

+ (void)setActiveTextEditor:(NGTextEditor * __nullable)textEditor;
- (instancetype)initWithText:(NGText *)text;
- (instancetype)copyWithScaleFactor:(CGFloat)factor relativedView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
