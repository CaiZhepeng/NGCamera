//
//  NSString+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Path)

/// 拼接了`文档目录`的全路径
@property (nullable, nonatomic, readonly) NSString *ng_documentDirectory;
/// 拼接了`缓存目录`的全路径
@property (nullable, nonatomic, readonly) NSString *ng_cacheDirecotry;
/// 拼接了临时目录的全路径
@property (nullable, nonatomic, readonly) NSString *ng_tmpDirectory;

@end

@interface NSString (Base64)

/// BASE 64 编码的字符串内容
@property(nullable, nonatomic, readonly) NSString *ng_base64encode;
/// BASE 64 解码的字符串内容
@property(nullable, nonatomic, readonly) NSString *ng_base64decode;

@end

@interface NSString (AdjustStringToFitLength)

/// 调整字符串
@property(nullable, nonatomic, readonly) NSString *ng_fitString;

@end

@interface NSString (Font)

/// 检测文字宽度  默认 font 高
- (CGFloat)ng_widthWithFont:(NSInteger)font height:(CGFloat)height;

/// 检测文字高度  默认 font 宽
- (CGFloat)ng_heightWithFont:(NSInteger)font width:(CGFloat)width;

/// 检测文字宽度 自定义 font
- (CGSize)ng_sizeWithFont:(nullable UIFont *)font height:(CGFloat)height;

/// 检测文字高度 自定义 font
- (CGSize)ng_sizeWithFont:(nullable UIFont *)font width:(CGFloat)width;

/// 检测文字高或宽度 自定义 attributes
- (CGSize)ng_sizeWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes maxSize:(CGSize)maxSize;

@end
