//
//  NGText.h
//  NGCamera
//
//  Created by caizhepeng on 2019/11/26.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGText : NSObject

@property (nonatomic,strong) NSAttributedString *attributedText;

- (UIImage *)drawText;

@end

NS_ASSUME_NONNULL_END
