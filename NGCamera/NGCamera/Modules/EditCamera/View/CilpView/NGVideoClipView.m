//
//  NGVideoCaptureView.m
//  NGCamera
//
//  Created by caizhepeng on 2020/3/17.
//  Copyright © 2020 caizhepeng. All rights reserved.
//

#import "NGVideoClipView.h"
#import "NGCameraTool.h"
#import "UIImage+fill.h"

@interface NGImageScrollView : UIView

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) CGRect rect;

- (void)drawRect:(CGRect)rect image:(UIImage *)image;

@end

@implementation NGImageScrollView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self.image drawInRect:rect];
}

- (void)drawRect:(CGRect)rect image:(UIImage *)image
{
    self.image = image;
    self.rect = rect;
    [self setNeedsDisplayInRect:rect];
}

@end

#define kVideoMinTime   3
#define kVideoMaxTime   15
#define kImageCount     10
#define kClipViewHeight 50
#define kClipViewLeft   30
#define kClipViewWidth  (kMainScreenWidth - 2 * kClipViewLeft)
#define kLeftViewWidth  15

typedef NS_ENUM (NSInteger, DragType)
{
    DragTypeLeft,
    DragTypeRight,
};

@interface NGVideoClipView () <UIScrollViewDelegate>

@property (nonatomic,strong) UIView *clipView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *leftView;
@property (nonatomic,strong) UIImageView *rightView;
@property (nonatomic,strong) UIView *topLine;
@property (nonatomic,strong) UIView *bottomLine;
@property (nonatomic,strong) UIView *videoSlider;
@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,assign) CGFloat totalTime;
@property (nonatomic,assign) CGFloat pixelTime;

@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) AVURLAsset *urlAsset;
@end

@implementation NGVideoClipView

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL
{
    if (self = [super initWithFrame:frame]) {
        _videoURL = videoURL;
        [self setupData];
        [self setupUI];
        [self drawScrollImage];
    }
    return self;
}

- (void)setupData
{
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    self.urlAsset = [AVURLAsset URLAssetWithURL:self.videoURL options:options];
    self.totalTime = self.urlAsset.duration.value*1.0f / self.urlAsset.duration.timescale;
    self.pixelTime = kVideoMaxTime <= self.totalTime ? kVideoMaxTime*1.0/kClipViewWidth : self.totalTime/kClipViewWidth;
}

- (void)setupUI
{
    UIView *clipView = [[UIView alloc] initWithFrame:CGRectMake(kClipViewLeft, (self.height - kClipViewHeight)/2, kClipViewWidth, kClipViewHeight)];
    clipView.backgroundColor = [UIColor blackColor];
    [self addSubview:clipView];
    self.clipView = clipView;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:clipView.bounds];
    scrollView.clipsToBounds = YES;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = YES;
    [clipView addSubview:scrollView];
    self.scrollView = scrollView;

    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(kClipViewLeft - kLeftViewWidth, clipView.top, kLeftViewWidth, kClipViewHeight)];
    leftView.image = [UIImage imageNamed:@"icon_videoClip_window_pan_bar_left~iphone"];
    leftView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanGestureAction:)];
    leftPan.maximumNumberOfTouches = 1;
    leftPan.minimumNumberOfTouches = 1;
    [self addSubview:leftView];
    [leftView addGestureRecognizer:leftPan];
    self.leftView = leftView;
    
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(clipView.right, clipView.top, kLeftViewWidth, kClipViewHeight)];
    rightView.image = [UIImage imageNamed:@"icon_videoClip_window_pan_bar_right~iphone"];
    rightView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanGestureAction:)];
    [self addSubview:rightView];
    [rightView addGestureRecognizer:rightPan];
    self.rightView = rightView;
    
    UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, clipView.width, 3)];
    topLine.backgroundColor = [UIColor whiteColor];
    [clipView addSubview:topLine];
    self.topLine = topLine;

    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, clipView.height-3,clipView.width, 3)];
    bottomLine.backgroundColor = [UIColor whiteColor];
    [clipView addSubview:bottomLine];
    self.bottomLine = bottomLine;
    
    UIView *videoSlider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, kClipViewHeight)];
    videoSlider.backgroundColor = [UIColor colorWithRed:16/255.0 green:118/255.0 blue:241/255.0 alpha:1.0];
    [clipView addSubview:videoSlider];
    self.videoSlider = videoSlider;
    
    UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, clipView.top - 25, self.width, 20)];
    timeLable.backgroundColor = [UIColor blackColor];
    timeLable.textColor = [UIColor whiteColor];
    timeLable.textAlignment = NSTextAlignmentCenter;
    timeLable.text = [NSString stringWithFormat:@"%.1f",kVideoMaxTime <= self.totalTime ? kVideoMaxTime : self.totalTime];
    [self addSubview:timeLable];
    self.timeLabel = timeLable;
}

- (void)drawScrollImage
{
    CGFloat imageWith = kClipViewWidth / kImageCount;
    CGFloat timeUnit = kVideoMaxTime*1.0 / kImageCount;
    NSInteger count = self.totalTime / timeUnit;
    if (count <= kImageCount) {
        count = kImageCount;
        timeUnit = self.totalTime / kImageCount;
    } else {
        CGFloat beyondWidth = count * imageWith - kClipViewWidth;
        self.scrollView.contentSize = CGSizeMake(count * imageWith + beyondWidth, kClipViewHeight);
        self.scrollView.frame = CGRectMake(0, 0, count * imageWith, kClipViewHeight);
    }
    
    NGImageScrollView *imageScrollView = [[NGImageScrollView alloc]initWithFrame:CGRectMake(0, 0, count * imageWith, kClipViewHeight)];
    [self.scrollView addSubview:imageScrollView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSInteger i = 0; i < count; i++) {
            UIImage *image = [NGCameraTool getScreenShotImageFromVideoPath:self.urlAsset
                                                             withStartTime:i * timeUnit
                                                             withTimescale:10
                                                                isKeyImage:NO];
//            image = [UIImage fillSize:image viewsize:CGSizeMake(imageWith, kClipViewHeight)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageScrollView drawRect:CGRectMake(i*imageWith, 0, imageWith, kClipViewHeight) image:image];
            });
        }
    });
}

- (void)reloadData
{
    self.leftView.left = kClipViewLeft - kLeftViewWidth;
    self.rightView.left = self.clipView.right;
    self.topLine.left = self.bottomLine.left = 0;
    self.topLine.width = self.bottomLine.width = self.clipView.width;
    self.timeLabel.text = [NSString stringWithFormat:@"%.1f",kVideoMaxTime <= self.totalTime ? kVideoMaxTime : self.totalTime];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark - Action
- (void)leftPanGestureAction:(UIPanGestureRecognizer *)pan
{
    CGPoint stopLocation = [pan locationInView:self.clipView];
    CGFloat x = stopLocation.x;

    if (x < 0) {
        x = 0;
    }
    CGFloat distance = self.rightView.left - kClipViewLeft - kVideoMinTime*1.0/self.pixelTime;
    if (x > distance) {
        x = distance;
    }
    
    CGFloat lineWidth = self.rightView.left - kClipViewLeft - x;
    self.leftView.right = kClipViewLeft + x;
    self.topLine.left = self.bottomLine.left = x;
    self.topLine.width = self.bottomLine.width = lineWidth;
    self.timeLabel.text = [NSString stringWithFormat:@"%.1f", lineWidth * self.pixelTime];
    
    [self calculateForTimeNodes:DragTypeLeft];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self dragEnd];
    }
}

- (void)rightPanGestureAction:(UIPanGestureRecognizer *)pan
{
    CGPoint stopLocation = [pan locationInView:self.clipView];
    CGFloat x = stopLocation.x;
 
    if (x > kClipViewWidth) {
        x = kClipViewWidth;
    }
    CGFloat distance = self.leftView.right + kVideoMinTime*1.0/self.pixelTime - kClipViewLeft;
    if (x < distance) {
        x = distance;
    }
    
    CGFloat lineWidth = kClipViewLeft - self.leftView.right + x;
    self.rightView.left = kClipViewLeft + x;
    self.topLine.width = self.bottomLine.width = lineWidth;
    self.timeLabel.text = [NSString stringWithFormat:@"%.1f", lineWidth * self.pixelTime];

    [self calculateForTimeNodes:DragTypeRight];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self dragEnd];
    }
}

- (void)calculateForTimeNodes:(DragType)type
{
    CGPoint offset = self.scrollView.contentOffset;
    
    CGFloat startTime = (offset.x + self.leftView.right - kClipViewLeft) * self.pixelTime;
    CGFloat endTime = (offset.x + self.rightView.left - kClipViewLeft) * self.pixelTime;
    
    CGFloat jumpTime = 0;
    
    switch (type) {
        case DragTypeLeft:
            jumpTime = startTime;
            break;
        case DragTypeRight:
            jumpTime = endTime;
        default:
            break;
    }
    if (self.getVideoTimeRange) {
        self.getVideoTimeRange(startTime, endTime, jumpTime);
    }
    self.videoSlider.hidden = YES;
}

- (void)dragEnd
{
    if (self.didDragEnd) {
        self.didDragEnd();
    }
    self.videoSlider.hidden = NO;
}

- (void)setCurrentTime:(CGFloat)currentTime
{
    _currentTime = currentTime;
    self.videoSlider.left = currentTime/self.pixelTime - self.scrollView.contentOffset.x;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self calculateForTimeNodes:DragTypeLeft];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self dragEnd];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self dragEnd];
}

@end
