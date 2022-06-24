//
//  NGSuspensionView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/9/11.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGSuspensionModel : NSObject<YYModel>

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,assign) CGFloat value;
+ (NSArray<NGSuspensionModel *> *)buildSuspensionModelsWithJson:(NSString *)jsonStr;
+ (NSArray<NGSuspensionModel *> *)buildSuspensionModelsWithConfig:(NSString *)path;

@end

#define kCameraRatioSuspensionViewMargin  1
#define kCameraRatioSuspensionViewHeight  80

@interface NGSuspensionView : UIView

@property (nonatomic, strong) NSArray<NGSuspensionModel *> *suspensionModels;
@property (nonatomic, copy) void (^suspensionModelClickBlock)(NGSuspensionModel *model);

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout;

- (void)toggleInView:(UIView *)view withBottom:(CGFloat)bottom;
- (void)showInView:(UIView *)view withBottom:(CGFloat)bottom;
- (BOOL)hide;

@end

NS_ASSUME_NONNULL_END
