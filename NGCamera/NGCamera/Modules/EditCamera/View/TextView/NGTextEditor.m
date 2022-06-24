//
//  NGTextEditor.m
//  NGCamera
//
//  Created by caizhepeng on 2019/11/6.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGTextEditor.h"

#define TextEditor_margin 22

@interface NGTextEditor ()

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIImageView *textImageView;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIButton *rotationBtn;

@end

@implementation NGTextEditor
{
    UIImage *_textImage;
    CGSize _imageSize;
    CGPoint _initialPoint;
    
    CGFloat _arg;
    CGFloat _initialArg;
    CGFloat _scale;
    CGFloat _initialScale;
}

static NGTextEditor *activeView = nil;
+ (void)setActiveTextEditor:(NGTextEditor *)textEditor
{
    [activeView cancelDeactivated];
    if (textEditor != activeView){
        [activeView setAvtive:NO];
        activeView = textEditor;
        [activeView setAvtive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
    }
    [activeView autoDeactivated];
}

- (void)dealloc
{
    [self cancelDeactivated];
}

#pragma mark - 自动取消激活
- (void)cancelDeactivated
{
    [NGTextEditor cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoDeactivated
{
    [self performSelector:@selector(setActiveTextEditor:) withObject:nil afterDelay:self.deactivatedDelay];
}

- (void)setActiveTextEditor:(NGTextEditor *)textEditor
{
    [NGTextEditor setActiveTextEditor:textEditor];
}

#pragma mark - init
- (instancetype)initWithText:(NGText *)text
{
    if (text == nil) {
        return nil;
    }
    UIImage *textImage = [text drawText];
    CGRect frame = CGRectMake(0, 0, textImage.size.width + TextEditor_margin, textImage.size.height + TextEditor_margin);
    if (self = [super initWithFrame:frame]) {
        _textImage = textImage;
        _imageSize = textImage.size;
        _text = text;
        [self createData];
        [self createView];
        [self setAvtive:NO];
    }
    return self;
}

- (void)createData
{
    self.minScale = 0.5;
    self.maxScale = 2.0;
    self.deactivatedDelay = 4.0;
    
    _arg = 0;
    _scale = 1.0;
}

- (void)createView
{
    // contentView
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _imageSize.width, _imageSize.height)];
    contentView.center = self.center;
    contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    contentView.layer.borderWidth = 1.0f;
    contentView.layer.cornerRadius = 4.0f;
    contentView.userInteractionEnabled = YES;
    [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [contentView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    // imageView
    UIImageView *textImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    textImageView.image = _textImage;
    textImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:textImageView];
    self.textImageView = textImageView;
    
    // deleteBtn
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TextEditor_margin, TextEditor_margin)];
    deleteBtn.center = contentView.origin;
    [deleteBtn setImage:[UIImage imageNamed:@"btn_text_delete"] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"btn_text_delete"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(buttonDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    
    // rorationBtn
    UIButton *rotationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TextEditor_margin, TextEditor_margin)];
    rotationBtn.center = CGPointMake(contentView.right, contentView.bottom);
    [rotationBtn setImage:[UIImage imageNamed:@"btn_text_roration"] forState:UIControlStateNormal];
    [rotationBtn setImage:[UIImage imageNamed:@"btn_text_roration"] forState:UIControlStateHighlighted];
    [rotationBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(buttonRotate:)]];
    [self addSubview:rotationBtn];
    self.rotationBtn = rotationBtn;
}

#pragma mark - Touch Event
- (void)buttonDelete:(UIButton *)btn
{
    [self cancelDeactivated];
    [self removeFromSuperview];
}

- (void)buttonRotate:(UIPanGestureRecognizer *)pan
{
    CGPoint p = [pan translationInView:self.superview];
    
    static CGFloat tempR = 1.0;
    static CGFloat tempArg = 0;
    
    if (pan.state == UIGestureRecognizerStateBegan){
        [self cancelDeactivated];
        
        _initialPoint = [self.superview convertPoint:self.rotationBtn.center fromView:self.rotationBtn.superview];
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        
        tempR = sqrt(p.x*p.x + p.y*p.y);
        tempArg = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg = _initialArg + arg - tempArg;
    [self setScale:(_initialScale * R/tempR)];
}

- (void)viewDidTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        if (self.tapTextBlock) {
            self.tapTextBlock(self);
        }
        [[self class] setActiveTextEditor:self];
    }
}

- (void)viewDidPan:(UIPanGestureRecognizer *)pan
{
    [[self class] setActiveTextEditor:self];
    
    CGPoint p = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + p.x, self.center.y + p.y);
    [pan setTranslation:CGPointZero inView:self.superview];
    
    if (pan.state == UIGestureRecognizerStateBegan){
        [self cancelDeactivated];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGRect rect = [self convertRect:self.contentView.frame toView:self.superview];
        BOOL isMoveCenter = NO;
        if (self.moveCenter) {
            isMoveCenter = self.moveCenter(rect);
        } else {
            isMoveCenter = !CGRectIntersectsRect(CGRectInset(self.superview.frame, 30, 30), rect);
        }
        if (isMoveCenter) {
            [UIView animateWithDuration:0.25f animations:^{
                self.center = self.superview.center;
            }];
        }
        [self autoDeactivated];
    }
}

#pragma mark - Override
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if(view == self){
        view = nil;
    }
    if (view == nil) {
        [NGTextEditor setActiveTextEditor:nil];
    }
    return view;
}

#pragma mark - 更新坐标
- (void)updateFrameWithSize:(CGSize)size
{
    CGPoint center = self.center;
    self.size = CGSizeMake(size.width + TextEditor_margin, size.height + TextEditor_margin);
    self.center = center;
    
    self.contentView.transform = CGAffineTransformIdentity;
    
    self.contentView.size = size;
    self.contentView.center = center;
    self.textImageView.frame = self.contentView.bounds;
    self.deleteBtn.center = self.contentView.origin;
    self.rotationBtn.center = CGPointMake(CGRectGetMaxX(self.contentView.frame), CGRectGetMaxY(self.contentView.frame));
    [self setScale:_scale rotation:_arg];
}

- (instancetype)copyWithScaleFactor:(CGFloat)factor relativedView:(UIView *)view
{
    NGTextEditor *textEditor = [[[self class] alloc] initWithText:self.text];
    textEditor.transform = self.transform;
    textEditor.contentView.transform = CGAffineTransformScale(self.contentView.transform, 1.0f/factor, 1.0f/factor);
    
    CGFloat centerX = self.center.x - view.frame.origin.x;
    CGFloat centerY = self.center.y - view.frame.origin.y;
    NSLog(@"relativedView %@ %@",NSStringFromCGRect(view.frame), NSStringFromCGRect(self.frame));
    textEditor.center = CGPointMake(centerX/factor, centerY/factor);
    
    return textEditor;
}

#pragma mark - setter
- (void)setText:(NGText *)text
{
    _text = text;
    if (text) {
        UIImage *textImage = [text drawText];
        self.textImageView.image = textImage;
        self.textImageView.userInteractionEnabled = self.isActive;
        [self updateFrameWithSize:textImage.size];
    } else {
        [self removeFromSuperview];
    }
}

- (void)setScale:(CGFloat)scale
{
    [self setScale:scale rotation:MAXFLOAT];
}

- (void)setScale:(CGFloat)scale rotation:(CGFloat)rotation
{
    if (rotation != MAXFLOAT) {
        _arg = rotation;
    }
    _scale = MIN(MAX(scale, _minScale), _maxScale);
    
    self.transform = CGAffineTransformIdentity;
    self.contentView.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rect = self.frame;
    rect.origin.x += (rect.size.width - (self.contentView.frame.size.width + TextEditor_margin)) / 2;
    rect.origin.y += (rect.size.height - (self.contentView.frame.size.height + TextEditor_margin)) / 2;
    rect.size.width  = self.contentView.frame.size.width + TextEditor_margin;
    rect.size.height = self.contentView.frame.size.height + TextEditor_margin;
    self.frame = rect;
    
    self.contentView.center = CGPointMake(rect.size.width/2, rect.size.height/2);
    self.deleteBtn.center = _contentView.frame.origin;
    self.rotationBtn.center = CGPointMake(CGRectGetMaxX(self.contentView.frame), CGRectGetMaxY(self.contentView.frame));
    
    self.transform = CGAffineTransformMakeRotation(_arg);
}

- (void)setAvtive:(BOOL)active {
    _isActive = active;
    self.deleteBtn.hidden = !active;
    self.rotationBtn.hidden = !active;
    self.contentView.layer.borderColor = active ? [UIColor whiteColor].CGColor : [UIColor clearColor].CGColor;
    self.contentView.layer.borderWidth = active ? 1/_scale : 0;
    self.contentView.layer.cornerRadius = active ? 4/_scale : 0;
    self.textImageView.userInteractionEnabled = active;
}

#pragma mark - getter
- (CGFloat)scale
{
    return _scale;
}

- (CGFloat)rotation
{
    return _arg;
}
@end
