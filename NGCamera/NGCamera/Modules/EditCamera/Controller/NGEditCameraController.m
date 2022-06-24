//
//  NGEditCameraController.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/30.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGEditCameraController.h"
#import "TKImageView.h"
#import "NGCameraFilterView.h"
#import "NGCameraEditView.h"
#import "NGCameraCropView.h"
#import "NGCameraTextView.h"
#import "NGTextEditor.h"
#import "MBProgressHUD.h"
#import <Photos/Photos.h>
#import "UIImage+Rotate.h"
#import "UIImage+Clip.h"
#import "UIImage+Resize.h"

typedef NS_ENUM (NSInteger, EditButtonTag)
{
    EditButtonTagBack = 1,
    EditButtonTagSave,
    EditButtonTagRestore,
    EditButtonTagFilter,
    EditButtonTagEdit,
    EditButtonTagCrop,
    EditButtonTagText,
};

#define kEditCameraBarHeight 35
#define kEditViewHeight (kMainScreenHeigth - kCameraViewHeight - kEditCameraBarHeight)

@interface NGEditCameraController ()

@property (nonatomic,strong) UIView *imageViewHolder;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) TKImageView *imageCropView;
@property (nonatomic,strong) NGCameraFilterView *filterView;
@property (nonatomic,strong) NGCameraEditView *editView;
@property (nonatomic,strong) NGCameraCropView *cropView;

@end

@implementation NGEditCameraController
{
    BOOL _isRestore;
    
    UIImage *_currentImage;
    UIImage *_cropImage;
    UIButton *_lastBtn;
    
    NGTextEditor *_selectTextEditor;
    MBProgressHUD *_HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVar];
    [self setupView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.filterView.image = _currentImage;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    NSLog(@"NGEditCameraController 释放了");
}

- (void)setupVar
{
    _currentImage = self.image;
    _isRestore = NO;
}

- (void)setupView
{
    self.view.backgroundColor = [UIColor blackColor];

    // ImageViewHodler
    UIView *imageViewHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kCameraViewHeight)];
    [self.view addSubview:imageViewHolder];
    self.imageViewHolder = imageViewHolder;
    
    // UIImageView
    CGRect imageFrame = [self updateFramWithImage:self.image];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = self.image;
    [imageViewHolder addSubview:imageView];
    self.imageView = imageView;
    [self.imageCropView hide];
    
    // TopView
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kEditCameraBarHeight)];
    topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:topView];
    self.topView = topView;
    
    // BackButton
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, (kEditCameraBarHeight - 28)/2, 50, 28)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTag:EditButtonTagBack];
    [topView addSubview:backBtn];
    
    // SaveButton
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth - 50 - 15, (kEditCameraBarHeight - 28)/2, 50, 28)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setTag:EditButtonTagSave];
    [topView addSubview:saveBtn];
    
    // RestoreButton
    UIButton *restoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/2-50/2, (kEditCameraBarHeight - 28)/2, 50, 28)];
    [restoreBtn setTitle:@"复原" forState:UIControlStateNormal];
    [restoreBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [restoreBtn setTag:EditButtonTagRestore];
    [topView addSubview:restoreBtn];
    
    // BottomView
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeigth - kEditCameraBarHeight, kMainScreenWidth, kEditCameraBarHeight)];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    
    // LineView
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 0.3)];
    lineView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3];
    [bottomView addSubview:lineView];
    
    // FilterButton
    UIButton *filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth/4, kEditCameraBarHeight)];
    [filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
    [filterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [filterBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn setTag:EditButtonTagFilter];
    [bottomView addSubview:filterBtn];
    filterBtn.selected = YES;
    _lastBtn = filterBtn;
    
    // EditButton
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/4, 0, kMainScreenWidth/4, kEditCameraBarHeight)];
    [editBtn setTitle:@"调整" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [editBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTag:EditButtonTagEdit];
    [bottomView addSubview:editBtn];
    
    // CropButton
    UIButton *cropBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/2, 0, kMainScreenWidth/4, kEditCameraBarHeight)];
    [cropBtn setTitle:@"剪切" forState:UIControlStateNormal];
    [cropBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cropBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [cropBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cropBtn setTag:EditButtonTagCrop];
    [bottomView addSubview:cropBtn];
    
    // TextButton
    UIButton *textBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/4 * 3, 0, kMainScreenWidth/4, kEditCameraBarHeight)];
    [textBtn setTitle:@"文字" forState:UIControlStateNormal];
    [textBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [textBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [textBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [textBtn setTag:EditButtonTagText];
    [bottomView addSubview:textBtn];
}

#pragma mark - event
- (void)buttonClicked:(UIButton *)btn
{
    switch (btn.tag) {
        case EditButtonTagBack: {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case EditButtonTagSave: {
            UIImage *saveImage = [self generateFrameOnImage:_currentImage];
            [self saveImageToAlbum:saveImage];
            break;
        }
        case EditButtonTagRestore: {
            _isRestore = YES;
            _currentImage = self.image;
            self.imageView.image = self.image;
            [self barItemClicked:_lastBtn];
            [self removeTextView];
            break;
        }
    }
}

- (void)barItemClicked:(UIButton *)btn
{
    if (btn.tag != EditButtonTagText) {
        _lastBtn.selected = NO;
        btn.selected = YES;
        _lastBtn = btn;
    }
    self.imageView.hidden = NO;
    [self showTopView];
    [self.imageCropView hide];

    switch (btn.tag) {
        case EditButtonTagFilter: {
            self.filterView.hidden = NO;
            self.editView.hidden = self.cropView.hidden = YES;
            [self.filterView reloadData];
            self.filterView.image = _currentImage;
            break;
        }
        case EditButtonTagEdit: {
            self.editView.hidden = NO;
            self.filterView.hidden = self.cropView.hidden = YES;
            [self.editView reloadData];
            self.editView.image = _currentImage;
            break;
        }
        case EditButtonTagCrop: {
            self.cropView.hidden = NO;
            self.filterView.hidden = self.editView.hidden = YES;
            self.imageView.hidden = YES;
            [self hideTopView];
            [self.cropView reloadData];
            _cropImage = _currentImage;
            if (_isRestore) {
                self.imageCropView.cropAspectRatio = 0.0;
                _isRestore = NO;
            }
            [self.imageCropView setToCropImage:_currentImage];
            [self.imageCropView show];
            break;
        }
        case EditButtonTagText: {
            [self showTextViewWithText:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 保存图片
- (void)saveImageToAlbum:(UIImage *)image
{
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        [self saveImage:image];
    } else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self saveImage:image];
            }
        }];
    } else {
        _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _HUD.label.text = @"请在设置界面, 授权访问相册";
    }
}

- (void)saveImage:(UIImage *)image
{
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.label.text = @"照片保存中...";
    __block NSString *createdAssetID = nil; //唯一标识，可以用于图片资源获取
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self->_HUD hideAnimated:YES];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                self->_HUD.label.text = @"照片保存失败";
                [self->_HUD hideAnimated:YES afterDelay:1.0];
            }
        });
    }];
}

- (UIImage *)generateFrameOnImage:(UIImage *)image
{
    CGFloat scaleX = self.imageView.width/CGImageGetWidth(image.CGImage);
    CGFloat scaleY = self.imageView.height/CGImageGetHeight(image.CGImage);
    CGFloat scaleFactor = MIN(scaleX, scaleY);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    for (UIView *view in self.imageViewHolder.subviews) {
        if ([view isKindOfClass:[NGTextEditor class]]) {
            NGTextEditor *originTextEditor = (NGTextEditor *)view;
            NGTextEditor *textEditor = [originTextEditor copyWithScaleFactor:scaleFactor relativedView:self.imageView];
            [NGTextEditor setActiveTextEditor:nil];
            [imageView addSubview:textEditor];
        }
    }
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [imageView.layer renderInContext:contextRef];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGRect)updateFramWithImage:(UIImage *)image
{
    CGFloat aspect = image.size.width/image.size.height;
    CGFloat imageW = kMainScreenWidth;
    CGFloat imageH = kMainScreenWidth/aspect;
    if (imageH > kCameraViewHeight) {
        imageH = kCameraViewHeight;
        imageW = kCameraViewHeight * aspect;
    }
    
    CGFloat imageX = (kMainScreenWidth - imageW)/2;
    CGFloat imageY = (kCameraViewHeight - imageH)/2;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

#pragma mark - text
- (void)showTextViewWithText:(NGText *)text
{
    NGCameraTextView *textView = [[NGCameraTextView alloc] initWithFrame:self.view.bounds];
    textView.text = text;
    [self.view addSubview:textView];

    textView.didFinishTextBlock = ^(NGCameraTextView * _Nonnull textView, NGText * _Nonnull text) {
        if (text) {
            if (textView.text) {
                self->_selectTextEditor.text = text;
                [NGTextEditor setActiveTextEditor:self->_selectTextEditor];
            } else {
                NGTextEditor *textEditor = [[NGTextEditor alloc] initWithText:text];
                textEditor.center = self.imageView.center;
                [self.imageViewHolder addSubview:textEditor];
                [NGTextEditor setActiveTextEditor:textEditor];
                
                WeakSelf(self);
                textEditor.tapTextBlock = ^(NGTextEditor * _Nonnull textEditor) {
                    StrongSelf(self);
                    if (textEditor.isActive) {
                        self->_selectTextEditor = textEditor;
                        [self showTextViewWithText:self->_selectTextEditor.text];
                    }
                };
                textEditor.moveCenter = ^BOOL(CGRect rect) {
                    return !CGRectIntersectsRect(CGRectInset(self.imageView.frame, 30, 30), rect);
                };
            }
        } else {
            if (textView.text) {
                [self->_selectTextEditor removeFromSuperview];
            }
        }
    };
    textView.didCancelBlock = ^(NGCameraTextView * _Nonnull textView) {
        if (textView.text) {
            [NGTextEditor setActiveTextEditor:self->_selectTextEditor];
        }
    };
}

- (void)removeTextView
{
    for (UIView *view in self.imageViewHolder.subviews) {
        if ([view isKindOfClass:[NGTextEditor class]]) {
            [(NGTextEditor *)view removeFromSuperview];
        }
    }
}

#pragma mark - topView
- (void)showTopView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.top = 0;
    } completion:^(BOOL finished) {}];
}

- (void)hideTopView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.top = -kEditCameraBarHeight;
    } completion:^(BOOL finished) {}];
}

#pragma mark - cropImageView
- (void)showCropImageView
{
    if (!self.imageCropView.isShow) {
        [self.imageCropView show];
        self.imageView.hidden = YES;
        [self hideTopView];
    }
}

#pragma mark - getter
- (NGCameraFilterView *)filterView
{
    if (!_filterView) {
        _filterView = [[NGCameraFilterView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kEditViewHeight)];
        _filterView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_filterView];

        WeakSelf(self);
        _filterView.filterClick = ^(UIImage * _Nonnull image, NSString * _Nonnull filterName) {
            StrongSelf(self);
            self.imageView.image = image;
            self->_currentImage = image;
        };
    }
    return _filterView;
}

- (NGCameraEditView *)editView
{
    if (!_editView) {
        _editView = [[NGCameraEditView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kEditViewHeight)];
        _editView.isVideo = NO;
        _editView.backgroundColor = [UIColor blackColor];
        _editView.hidden = YES;
        [self.view addSubview:_editView];
        
        WeakSelf(self);
        _editView.editClick = ^(UIImage * _Nonnull image) {
            StrongSelf(self);
            self.imageView.image = image;
            self->_currentImage = image;
        };
    }
    return _editView;
}

- (NGCameraCropView *)cropView
{
    if (!_cropView) {
        _cropView = [[NGCameraCropView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kEditViewHeight)];
        _cropView.backgroundColor = [UIColor blackColor];
        _cropView.hidden = YES;
        [self.view addSubview:_cropView];
        
        WeakSelf(self);
        _cropView.sliderBlock = ^(CGFloat rotation) {
            StrongSelf(self);
            [self showCropImageView];
            CGRect imageFrame = [self updateFramWithImage:self->_cropImage];
            self.imageCropView.toCropImage = [self->_cropImage imageRotatedByDegrees:rotation cropSize:imageFrame.size];
        };
        
        _cropView.clickBlock = ^(CGSize aspect, CGFloat rotation, UIImageOrientation imageOrientation) {
            StrongSelf(self);
            [self showCropImageView];
            
            if (imageOrientation != UIImageOrientationUp) {
                self.imageCropView.toCropImage = [self.imageCropView.toCropImage rotate:imageOrientation];
            } else if (rotation != 0) {
                [self.imageCropView rotate:rotation];
            } else {
                [self.imageCropView setCropAspectRatio:aspect.width/aspect.height];
            }
        };
        
        _cropView.didFinishBlock = ^{
            StrongSelf(self);
            self->_cropImage = [self.imageCropView currentCroppedImage];
            self->_currentImage = self->_cropImage;
            self.imageCropView.toCropImage = self->_cropImage;
            self.imageView.image = self->_cropImage;
            [self.imageCropView hide];
            self.imageView.hidden = NO;
            self.imageView.frame = [self updateFramWithImage:self->_cropImage];
            [self showTopView];
        };
    }
    return _cropView;
}

- (TKImageView *)imageCropView
{
    if (!_imageCropView) {
        _imageCropView = [[TKImageView alloc] initWithFrame:CGRectMake(1, 1, kMainScreenWidth-2, kCameraViewHeight-2)];
        _imageCropView.showMidLines = YES;
        _imageCropView.needScaleCrop = YES;
        _imageCropView.showCrossLines = YES;
        _imageCropView.cornerBorderInImage = NO;
        _imageCropView.cropAreaCornerWidth = 44;
        _imageCropView.cropAreaCornerHeight = 44;
        _imageCropView.minSpace = 30;
        _imageCropView.cropAreaCornerLineColor = [UIColor whiteColor];
        _imageCropView.cropAreaBorderLineColor = [UIColor whiteColor];
        _imageCropView.cropAreaCornerLineWidth = 4;
        _imageCropView.cropAreaBorderLineWidth = 2;
        _imageCropView.cropAreaMidLineWidth = 1;
        _imageCropView.cropAreaMidLineHeight = 1;
        _imageCropView.cropAreaMidLineColor = [UIColor whiteColor];
        _imageCropView.cropAreaCrossLineColor = [UIColor whiteColor];
        _imageCropView.cropAreaCrossLineWidth = 1;
        _imageCropView.initialScaleFactor = 1.0f;
        _imageCropView.cropAspectRatio = 0.0f;
        [self.view addSubview:_imageCropView];
    }
    return _imageCropView;
}

@end
