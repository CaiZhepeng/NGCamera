//
//  NGCameraBar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/12.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraBar.h"

#define kCameraBarTag      1000
#define kCameraBarItemSize 50

@interface NGCameraBar()
@property (nonatomic, strong) UIView *dragView;
@end

@implementation NGCameraBar
{
    NSArray *_listArr;
    NSInteger _arrayCount;
    NSInteger _midleValue;
}

- (instancetype)initWithFrame:(CGRect)frame withListArray:(NSArray <NSString *>*)listArray;
{
    if (self = [super initWithFrame:frame]) {
        _listArr = listArray;
        _arrayCount = _listArr.count;
        _midleValue = _listArr.count/2;
        [self setupView];
        [self addGesture];
    }
    return self;
}

- (void)setupView
{
    UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake(kMainScreenWidth/2-kCameraBarItemSize/2 * _arrayCount , 0, kCameraBarItemSize * _arrayCount, self.height)];
    [self addSubview:dragView];
    self.dragView = dragView;
    
    for (int i = 0; i < _arrayCount; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i * kCameraBarItemSize, 0, kCameraBarItemSize, kCameraBarItemSize)];
        [btn setTitle:_listArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn addTarget:self action:@selector(clickedBarButton:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = kCameraBarTag + i;
        [dragView addSubview:btn];
    }
}

- (void)addGesture
{
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];

    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGesture];
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            [self directionOfMovement:NO];
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            [self directionOfMovement:YES];
            break;
        default:
            break;
    }
}

- (void)clickedBarButton:(UIButton *)btn
{
    NSInteger btnIndex = btn.tag - kCameraBarTag;
    [self scrollAtIndex:btnIndex];
    if (self.handleClickBlock) {
        self.handleClickBlock(btnIndex);
    }
}

- (void)directionOfMovement:(BOOL)isLeft
{
    CGFloat add = kCameraBarItemSize;
    if (isLeft) add = -add;
    CGFloat newCenterX = self.dragView.center.x + add;
    
    BOOL isLeftRestrictedArea = newCenterX >= kMainScreenWidth/2 - kCameraBarItemSize * _midleValue;
    BOOL isRightRestrictedArea = newCenterX <= kMainScreenWidth/2 + kCameraBarItemSize * _midleValue;
    
    if (isLeftRestrictedArea && isRightRestrictedArea)
    {
        self.dragView.center = CGPointMake(newCenterX, self.dragView.center.y);
        NSInteger index = [self caculate:newCenterX];
        if (self.handleClickBlock) {
            self.handleClickBlock(index);
        }
    }
}

- (NSInteger)caculate:(CGFloat)x
{
    NSInteger index = ((x - kMainScreenWidth/2) / kCameraBarItemSize) + 1;
    if (index > _midleValue) {
        index = _arrayCount - 1 - index;
    }
    else if (index < _midleValue) {
        index = _arrayCount - 1  + index;
    }
    return index;
}

- (void)scrollAtIndex:(NSInteger)index
{
    CGFloat newCenterX = self.dragView.center.x;
    NSInteger lastIndex = [self caculate:newCenterX];
    self.dragView.center = CGPointMake(newCenterX + (lastIndex - index) * kCameraBarItemSize, self.dragView.center.y);
}

@end
