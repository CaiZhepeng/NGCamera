//
//  NGMusicModel.h
//  NGCamera
//
//  Created by caizhepeng on 2020/4/29.
//  Copyright © 2020 caizhepeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGMusicModel : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *iconPath;
@property (nonatomic,copy) NSString *audioPath;

+ (NSArray<NGMusicModel *> *)buildMusicModels;

@end

NS_ASSUME_NONNULL_END
