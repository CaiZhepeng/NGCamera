//
//  NGCustomBar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/17.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGCustomButton.h"

NS_ASSUME_NONNULL_BEGIN

@class NGCustomBar;
@protocol NGCustomBarDelegate <NSObject>

- (void)customBar:(NGCustomBar *)bar didSelectItemAtIndex:(NSInteger)index;

@end

@interface NGCustomBar : UIScrollView

@property (nonatomic,assign) id<NGCustomBarDelegate> customBarDelegate;
@property (nonatomic,copy) NSArray *items;
@property (nonatomic,weak) NGCustomButton *selectedButton;
@property (nonatomic,assign) CGFloat margin;
@property (nonatomic,assign) CGFloat itemWidth;
@property (nonatomic,assign) CGFloat itemBeginX;

- (void)setHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
