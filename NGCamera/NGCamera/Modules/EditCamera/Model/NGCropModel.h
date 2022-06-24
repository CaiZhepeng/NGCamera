//
//  NGCropModel.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/21.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGCropModel : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *normalImage;
@property (nonatomic,copy) NSString *selectedImage;
@property (nonatomic,assign) NSInteger type;

+ (NSArray<NGCropModel *> *)buildCropModels;

@end

NS_ASSUME_NONNULL_END
