//
//  NGEditModel.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/15.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGEditModel : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *normalImage;
@property (nonatomic,copy) NSString *selectedImage;
@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign) CGFloat minimumValue;
@property (nonatomic,assign) CGFloat maximumValue;
@property (nonatomic,assign) NSInteger type;

+ (NSArray<NGEditModel *> *)buildEditModels;

@end

NS_ASSUME_NONNULL_END
