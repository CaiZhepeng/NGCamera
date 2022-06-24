#import "UIImage+Rotate.h"

//由角度转换弧度
#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
//由弧度转换角度
#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)

@implementation UIImage (Rotate)

/** 纠正图片的方向 */
- (UIImage *)fixOrientation
{
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

/** 按给定的方向旋转图片 */
- (UIImage*)rotate:(UIImageOrientation)orient
{
    CGRect bnds = CGRectZero;
    UIImage* copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = self.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            return self;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            return self;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}

/** 垂直翻转 */
- (UIImage *)flipVertical
{
    return [self rotate:UIImageOrientationDownMirrored];
}

/** 水平翻转 */
- (UIImage *)flipHorizontal
{
    return [self rotate:UIImageOrientationUpMirrored];
}

/** 将图片旋转弧度radians */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width * self.scale, self.size.height * self.scale)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    NSLog(@"rotatedSize: %f %f",rotatedSize.width, rotatedSize.height);
    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, self.scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/** 将图片旋转角度degrees */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    return [self imageRotatedByRadians:kDegreesToRadian(degrees)];
}

/** *保持图片纵横比缩放，最短边缩放后必须匹配targetSize的大小,长边截取 */
- (UIImage *)imageByScalingAspectToMinSize:(CGSize)targetSize {
    
    //获取源图片的宽和高
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    //获取图片缩放目标大小的宽和高
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    //定义图片缩放后的宽度
    CGFloat scaledWidth = targetWidth;
    //定义图片缩放后的高度
    CGFloat scaledHeight = targetHeight;
    CGPoint anchorPoint = CGPointZero;
    //如果源图片的大小于缩放的目标大小不相等
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        
        //计算水平方向上的缩放因子
        CGFloat xFactor = targetHeight/width;
        //计算垂直方向上的缩放因子
        CGFloat yFactor = targetHeight/height;
        //定义缩放因子scaleFactor为两个缩放因子中较大的一个
        CGFloat scaleFactor = xFactor>yFactor?xFactor:yFactor;
        //根据缩放因子计算图片缩放后的高度和宽度
        scaledWidth = width* scaleFactor;
        scaledHeight = height *scaleFactor;
        //如果横向上的缩放因子大于纵向上的缩放因子，那么图片在纵向上需要裁剪
        if (xFactor>yFactor) {
            anchorPoint.y = (targetHeight - scaledHeight)/2.0;
        }else if (xFactor < yFactor) {
            anchorPoint.x = (targetWidth - scaledWidth)/2.0;
            
        }
    }
    //开始绘图
    UIGraphicsBeginImageContext(targetSize);
    //定义图片缩放后的区域
    CGRect anchorRect = CGRectZero;
    anchorRect.origin = anchorPoint;
    anchorRect.size.width = scaledWidth;
    anchorRect.size.height = scaledHeight;
    //将图片本身绘制到anchorRect区域中
    [self drawInRect:anchorRect];
    
    //获取绘制后生成的新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/** *保持图片纵横比缩放，最短长边缩放后必须匹配targetSize的大小,短边留白 */
- (UIImage *)imageByScalingAspectToMaxSize:(CGSize)targetSize {
    
    //获取源图片的宽和高
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    //获取图片缩放目标大小的宽和高
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    //定义图片缩放后的宽度
    CGFloat scaledWidth = targetWidth;
    //定义图片缩放后的高度
    CGFloat scaledHeight = targetHeight;
    CGPoint anchorPoint = CGPointZero;
    //如果源图片的大小于缩放的目标大小不相等
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        
        //计算水平方向上的缩放因子
        CGFloat xFactor = targetHeight/width;
        //计算垂直方向上的缩放因子
        CGFloat yFactor = targetHeight/height;
        //定义缩放因子scaleFactor为两个缩放因子中较小的一个
        CGFloat scaleFactor = xFactor<yFactor?xFactor:yFactor;
        //根据缩放因子计算图片缩放后的高度和宽度
        scaledWidth = width* scaleFactor;
        scaledHeight = height *scaleFactor;
        //如果横向上的缩放因子小于纵向上的缩放因子，那么图片上下留空白
        if (xFactor<yFactor) {
            anchorPoint.y = (targetHeight - scaledHeight)/2.0;
        }else if (xFactor > yFactor) {
            anchorPoint.x = (targetWidth - scaledWidth)/2.0;
        }
        
    }
    //开始绘图
    UIGraphicsBeginImageContext(targetSize);
    //定义图片缩放后的区域
    CGRect anchorRect = CGRectZero;
    anchorRect.origin = anchorPoint;
    anchorRect.size.width = scaledWidth;
    anchorRect.size.height = scaledHeight;
    //将图片本身绘制到anchorRect区域中
    [self drawInRect:anchorRect];
    
    //获取绘制后生成的新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

/** 交换宽和高 */
static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat swap = rect.size.width;
    
    rect.size.width = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

- (CGImageRef)newScaledImage:(CGImageRef)source
             withOrientation:(UIImageOrientation)orientation
                      toSize:(CGSize)size
                 withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 rgbColorSpace,//CGImageGetColorSpace(source),
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big//(CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)angle
                          cropSize:(CGSize)cropSize
{
    CGImageRef source = [self newScaledImage:self.CGImage
                             withOrientation:self.imageOrientation
                                      toSize:self.size
                                 withQuality:kCGInterpolationNone];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(self.size.width, self.size.width*aspect);
    
    CGFloat width = fabs(cos(angle)) * cropSize.width + fabs(sin(angle)) * cropSize.height;
    CGFloat height = fabs(sin(angle)) * cropSize.width + fabs(cos(angle)) * cropSize.height;
    CGFloat max = MAX(width/cropSize.width, height/cropSize.height);
    height *= max;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // rotate
    transform = CGAffineTransformRotate(transform, angle);
    
    // scale
    CGAffineTransform t = CGAffineTransformMakeScale(max, max);
    CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    transform = CGAffineTransformScale(transform, xScale, yScale);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-cropSize.width/2.0,
                                           -cropSize.height/2.0,
                                           cropSize.width,
                                           cropSize.height), source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return [UIImage imageWithCGImage:resultRef];
}

@end
