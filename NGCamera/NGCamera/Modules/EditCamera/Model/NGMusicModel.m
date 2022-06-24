//
//  NGMusicModel.m
//  NGCamera
//
//  Created by caizhepeng on 2020/4/29.
//  Copyright © 2020 caizhepeng. All rights reserved.
//

#import "NGMusicModel.h"
#import <YYModel.h>

@implementation NGMusicModel

+ (NSArray<NGMusicModel *> *)buildMusicModels
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"json"];
    NSData *jsonConfig = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonConfig options:NSJSONReadingAllowFragments error:nil];
    NSArray *items = dic[@"music"];
    if (items) {
        NSMutableArray *editArrayM = [NSMutableArray array];
        NGMusicModel *model = [[NGMusicModel alloc] init];
        model.name = @"原音";
        model.iconPath = [[NSBundle mainBundle] pathForResource:@"nilMusic" ofType:@"png"];
        [editArrayM addObject:model];
        
        for (NSDictionary *item in items) {
            NGMusicModel *model = [[NGMusicModel alloc] init];
            model.name = item[@"name"];
            model.audioPath = [[NSBundle mainBundle] pathForResource:item[@"audio"] ofType:@"mp3"];
            model.iconPath = [[NSBundle mainBundle] pathForResource:item[@"icon"] ofType:@"png"];
            if (model) {
                [editArrayM addObject:model];
            }
        }
        return editArrayM;
    }
    return nil;
}

@end
