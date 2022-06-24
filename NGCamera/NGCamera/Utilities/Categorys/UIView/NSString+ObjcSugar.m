//
//  NSString+ObjcSugar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import "NSString+ObjcSugar.h"

@implementation NSString (Path)

- (NSString *)ng_documentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self];
}

- (NSString *)ng_cacheDirecotry {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self];
}

- (NSString *)ng_tmpDirectory {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:self];
}

@end

@implementation NSString (Base64)

- (NSString *)ng_base64encode {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)ng_base64decode {
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (AdjustStringToFitLength)

- (NSString *)ng_fitString
{
    NSArray *array = [self componentsSeparatedByString:@"."];
    NSString *integerStr = array[0];
    NSString *decimalStr = array[1];
    
    if ( self.length > 6 ) {
        
        NSUInteger length = integerStr.length;
        
        if ( length < 5 ) {
            
            NSInteger decimal = decimalStr.intValue / pow(10, length - 2);
            return [NSString stringWithFormat:@"%@.%zi",integerStr,decimal];
        }
        else {
            return integerStr;
        }
    }
    return self;
}

@end

@implementation NSString (Font)

- (CGFloat)ng_widthWithFont:(NSInteger)font height:(CGFloat)height {
    return [self ng_sizeWithFont:[UIFont systemFontOfSize:font] height:height].width;
}

- (CGFloat)ng_heightWithFont:(NSInteger)font width:(CGFloat)width {
    return [self ng_sizeWithFont:[UIFont systemFontOfSize:font] width:width].height;
}

- (CGSize)ng_sizeWithFont:(UIFont *)font height:(CGFloat)height {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(MAXFLOAT, height);
    return [self ng_sizeWithAttributes:attrs maxSize:maxSize];
}

- (CGSize)ng_sizeWithFont:(UIFont *)font width:(CGFloat)width {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    return [self ng_sizeWithAttributes:attrs maxSize:maxSize];
}

- (CGSize)ng_sizeWithAttributes:(NSDictionary<NSString *, id> *)attributes maxSize:(CGSize)maxSize {
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}

@end
