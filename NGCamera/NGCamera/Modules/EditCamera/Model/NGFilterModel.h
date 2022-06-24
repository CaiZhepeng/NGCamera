//
//  NGFilterModel.h
//  NGCamera
//
//  Created by caizhepeng on 2020/1/10.
//  Copyright © 2020 caizhepeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGFilterModel : NSObject

@property (nonatomic,copy) NSString *listName;
@property (nonatomic,copy) NSString *filterName;
@property (nonatomic,strong) UIImage *filterImage;

+ (NSArray<NGFilterModel *> *)buildFilterModels;
+ (UIImage *)selectedFilterAtIndex:(NSInteger)index image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
