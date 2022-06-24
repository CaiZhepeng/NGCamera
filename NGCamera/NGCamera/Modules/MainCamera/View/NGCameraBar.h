//
//  NGCameraBar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/12.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGCameraBar : UIView

@property (nonatomic,copy) void (^handleClickBlock)(NSInteger index);
- (instancetype)initWithFrame:(CGRect)frame withListArray:(NSArray <NSString *>*)listArray;
- (void)scrollAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
