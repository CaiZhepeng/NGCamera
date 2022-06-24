//
//  NGFilterViewCell.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/10.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGFilterViewCell.h"

@implementation NGFilterViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
    self.imageView.layer.cornerRadius = 4;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.imageView.layer.borderColor = [UIColor yellowColor].CGColor;
        self.imageView.layer.borderWidth = 2.0f;
        self.label.textColor = [UIColor yellowColor];
    } else {
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageView.layer.borderWidth = 0.0f;
        self.label.textColor = [UIColor whiteColor];
    }
}

@end
