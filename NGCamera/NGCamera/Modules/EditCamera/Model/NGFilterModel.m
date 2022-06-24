//
//  NGFilterModel.m
//  NGCamera
//
//  Created by caizhepeng on 2020/1/10.
//  Copyright © 2020 caizhepeng. All rights reserved.
//

#import "NGFilterModel.h"
#import "FWApplyFilter.h"

@implementation NGFilterModel

+ (NSArray<NGFilterModel *> *)buildFilterModels;
{
    NSArray *filterArray = [NSArray arrayWithObjects:@"LFGPUImageEmptyFilter", @"FWAmaroFilter", @"GPUImageSoftEleganceFilter", @"GPUImageMissEtikateFilter", @"FWNashvilleFilter", @"FWLordKelvinFilter", @"GPUImageAmatorkaFilter", @"FWRiseFilter", @"FWHudsonFilter", @"FWXproIIFilter", @"FW1977Filter", @"FWValenciaFilter", @"FWWaldenFilter", @"FWLomofiFilter", @"FWInkwellFilter", @"FWSierraFilter", @"FWEarlybirdFilter", @"FWSutroFilter", @"FWToasterFilter", @"FWBrannanFilter", @"FWHefeFilter", nil];
    NSArray *listArray = [NSArray arrayWithObjects:@"原图", @"经典LOMO", @"流年", @"HDR", @"碧波", @"上野", @"优格", @"彩虹瀑", @"云端", @"淡雅", @"粉红佳人", @"复古", @"候鸟", @"黑白", @"一九〇〇", @"古铜色", @"哥特风", @"移轴", @"TEST1", @"TEST2", @"TEST3", nil];
    NSMutableArray *filters = [NSMutableArray array];
    for (NSUInteger i = 0; i < listArray.count; i++) {
        UIImage *currentImage = [NGFilterModel selectedFilterAtIndex:i image:[UIImage imageNamed:@"icon_videoFilter"]];
        if (currentImage) {
            NGFilterModel *model = [[NGFilterModel alloc] init];
            model.listName = listArray[i];
            model.filterName = filterArray[i];
            model.filterImage = currentImage;
            [filters addObject:model];
        }
    }
    return filters;
}

+ (UIImage *)selectedFilterAtIndex:(NSInteger)index image:(UIImage *)image
{
    UIImage *currentImage = image;
    switch (index) {
        case 0:
            currentImage = image;
            break;
            
        case 1:
            currentImage = [FWApplyFilter applyAmaroFilter:image];
            break;
            
        case 2:
            currentImage = [FWApplyFilter applySoftEleganceFilter:image];
            break;
            
        case 3:
            currentImage = [FWApplyFilter applyMissetikateFilter:image];
            break;
            
        case 4:
            currentImage = [FWApplyFilter applyNashvilleFilter:image];
            break;
            
        case 5:
            currentImage = [FWApplyFilter applyLordKelvinFilter:image];
            break;
            
        case 6:
            currentImage = [FWApplyFilter applyAmatorkaFilter:image];
            break;
            
        case 7:
            currentImage = [FWApplyFilter applyRiseFilter:image];
            break;
            
        case 8:
            currentImage= [FWApplyFilter applyHudsonFilter:image];
            break;
            
        case 9:
            currentImage = [FWApplyFilter applyXproIIFilter:image];
            break;
            
        case 10:
            currentImage =[FWApplyFilter apply1977Filter:image];
            break;
            
        case 11:
            currentImage =[FWApplyFilter applyValenciaFilter:image];
            break;
            
        case 12:
            currentImage =[FWApplyFilter applyWaldenFilter:image];
            break;
            
        case 13:
            currentImage = [FWApplyFilter applyLomofiFilter:image];
            break;
            
        case 14:
            currentImage = [FWApplyFilter applyInkwellFilter:image];
            break;
            
        case 15:
            currentImage= [FWApplyFilter applySierraFilter:image];
            break;
            
        case 16:
            currentImage = [FWApplyFilter applyEarlybirdFilter:image];
            break;
            
        case 17:
            currentImage = [FWApplyFilter applySutroFilter:image];
            break;
            
        case 18:
            currentImage = [FWApplyFilter applyToasterFilter:image];
            break;
            
        case 19:
            currentImage = [FWApplyFilter applyBrannanFilter:image];
            break;
            
        case 20:
            currentImage = [FWApplyFilter applyHefeFilter:image];
            break;
    }
    return currentImage;
}

@end
