//
//  NGEditModel.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/15.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGEditModel.h"
#import <YYModel.h>

@implementation NGEditModel

+ (NSArray<NGEditModel *> *)buildEditModels
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"json"];
    NSData *jsonConfig = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonConfig options:NSJSONReadingMutableContainers error:nil];
    if (array) {
        NSMutableArray *editArrayM = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            NGEditModel *model = [NGEditModel yy_modelWithDictionary:dict];
            if (model) {
                [editArrayM addObject:model];
            }
        }
        return editArrayM;
    }
    return nil;
}

@end
