#import "GPUImage.h"

@interface FSKGPUImageBeautyFilter : GPUImageFilter

/** 美颜程度 */
@property (nonatomic, assign) CGFloat beautyLevel;
/** 美白程度 */
@property (nonatomic, assign) CGFloat brightLevel;
/** 色调强度 */
@property (nonatomic, assign) CGFloat toneLevel;

@end
