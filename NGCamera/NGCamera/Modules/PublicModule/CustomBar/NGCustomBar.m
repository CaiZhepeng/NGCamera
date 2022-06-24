//
//  NGCustomBar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/17.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCustomBar.h"

@implementation NGCustomBar

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.bounces = NO;
    self.margin = 10;
    self.itemWidth = 50;
    self.itemBeginX = 10;
}

- (void)layoutSubviews
{
    for (NSInteger i = 0; i < self.items.count; i++) {
        NGCustomButton *item = self.items[i];
        item.frame = CGRectMake(self.itemBeginX + i * (self.itemWidth + self.margin), 0, self.itemWidth, self.frame.size.height);
        [item setNeedsDisplay];
    }
    CGSize contentSize = CGSizeMake(self.itemBeginX + self.items.count * self.itemWidth + (self.items.count - 1) * _margin, self.frame.size.height);
    self.contentSize = contentSize;
}

- (void)setItems:(NSArray *)items
{
    _items = [items copy];
    for (NGCustomButton *item in _items) {
        [item addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:item];
    }
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame),
                            CGRectGetWidth(self.frame), height);
}

#pragma mark - Item selection
- (void)buttonClicked:(id)sender
{
    [self setSelectedButton:sender];
    if ([self.customBarDelegate respondsToSelector:@selector(customBar:didSelectItemAtIndex:)]) {
        NSInteger index = [self.items indexOfObject:self.selectedButton];
        [self.customBarDelegate customBar:self didSelectItemAtIndex:index];
    }
}

- (void)setSelectedButton:(NGCustomButton *)selectedButton
{
    if (selectedButton == _selectedButton) {
        return;
    }
    [_selectedButton setSelected:NO];
    _selectedButton = selectedButton;
    [_selectedButton setSelected:YES];
}

@end
