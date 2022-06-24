//
//  NGCameraEditView.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/15.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGEditModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NGEditFilterModel : NSObject

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) CGFloat value;

@end

@interface NGCameraEditView : UIView

@property (nonatomic,strong) NSArray<NGEditModel *> *editModels;
@property (nonatomic,strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) BOOL isVideo;
@property (nonatomic,copy) void(^editClick)(UIImage *image);
@property (nonatomic,copy) void(^editVdeoClick)(NGEditFilterModel *editFilterModel);

- (void)reloadData;
- (void)addFilter:(GPUImageOutput<GPUImageInput> *)filter;
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter filterGroup:(GPUImageFilterGroup *)filterGroup;
- (void)changeValueForFilter:(GPUImageOutput<GPUImageInput> *)filter
                       index:(NSInteger)index
                       value:(CGFloat)value
                       image:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
