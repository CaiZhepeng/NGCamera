//
//  NGCustomButton.h
//  NGCamera
//
//  Created by caizhepeng on 2019/10/17.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGCustomButton : UIButton

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *normalImage;

@property (nonatomic,copy) NSString *selectedImage;

@end

NS_ASSUME_NONNULL_END
