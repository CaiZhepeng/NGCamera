//
//  NGCropModel.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/21.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCropModel.h"
#import <YYModel.h>

@implementation NGCropModel

+ (NSArray<NGCropModel *> *)buildCropModels
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"crop" ofType:@"json"];
    NSData *jsonConfig = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonConfig options:NSJSONReadingMutableContainers error:nil];
    if (array) {
        NSMutableArray *editArrayM = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            NGCropModel *model = [NGCropModel yy_modelWithDictionary:dict];
            if (model) {
                [editArrayM addObject:model];
            }
        }
        return editArrayM;
    }
    return nil;
}

@end
