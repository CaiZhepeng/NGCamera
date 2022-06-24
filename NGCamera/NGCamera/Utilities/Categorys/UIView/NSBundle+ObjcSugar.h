//
//  NSBundle+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (ObjcSugar)

/// 当前版本号字符串
+ (nullable NSString *)ng_currentVersion;

/// 与当前屏幕尺寸匹配的启动图像
+ (nullable UIImage *)ng_launchImage;

@end
