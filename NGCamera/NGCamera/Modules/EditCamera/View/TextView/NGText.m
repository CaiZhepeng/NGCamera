//
//  NGText.m
//  NGCamera
//
//  Created by caizhepeng on 2019/11/26.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGText.h"
#import <CoreText/CoreText.h>

@implementation NGText

- (UIImage *)drawText
{
    UIEdgeInsets textInsets = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
    CGPoint point = CGPointMake(textInsets.left, textInsets.top);
    
    CGSize textSize = [self sizeWithConstrainedToSize:CGSizeMake(kMainScreenWidth - (textInsets.left+textInsets.right), CGFLOAT_MAX)];
    CGSize size = textSize;
    size.width += (textInsets.left + textInsets.right);
    size.height += (textInsets.top + textInsets.bottom);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawInContext:context
         attributedText:self.attributedText
           withPosition:point
              andHeight:textSize.height
               andWidth:textSize.width];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGSize)sizeWithConstrainedToSize:(CGSize)size
{
    if (self.attributedText.length == 0) return CGSizeZero;
    
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)self.attributedText;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self.attributedText length]), NULL, size, NULL);
    CFRelease(framesetter);
    return result;
}

- (void)drawInContext:(CGContextRef)context attributedText:(NSAttributedString *)attributedText withPosition:(CGPoint)p andHeight:(float)height andWidth:(float)width
{
    CGSize size = CGSizeMake(width, height);
    // 翻转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 创建绘制区域（路径）
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(p.x, -p.y, (size.width), (size.height)));
    
    // 创建CFAttributedStringRef
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedText;
    
    // 绘制frame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,0),path,NULL);
    CTFrameDraw(ctframe,context);
    CGPathRelease(path);
    CFRelease(framesetter);
    CFRelease(ctframe);
}

@end
