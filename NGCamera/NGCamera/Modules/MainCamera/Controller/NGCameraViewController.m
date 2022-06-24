//
//  NGCameraViewController.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/30.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraViewController.h"
#import "NGEditCameraController.h"
#import "NGEditVideoController.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "NGCameraBar.h"
#import "NGCameraPreview.h"
#import "NGCameraFocusView.h"
#import "NGCameraRatioView.h"
#import "NGCameraFlashView.h"
#import "GPUImageBeautifyFilter.h"
#import "NGCameraTool.h"
#import "MBProgressHUD.h"
#import "UIImage+Rotate.h"
#import "UIImage+Clip.h"
#import "SDAVAssetExportSession.h"

#define kCameraTabBarSize          50
#define kCameraTakePhotoIconSize   75
#define kVideoImageViewSize        40
#define kVideoTimeInterval         0.05
#define kProgressViewHeight        4
#define kCameraBtnInterval         ((kMainScreenWidth-kCameraTakePhotoIconSize)/8)

typedef NS_ENUM (NSInteger, CameraBtnTag)
{
    CameraBtnTagTakePhoto = 1,
    CameraBtnTagFlash,
    CameraBtnTagRatio,
    CameraBtnTagBeauty,
    CameraBtnTagRotate,
    CameraBtnTagDelete,
    CameraBtnTagComplete,
};

typedef NS_ENUM (NSInteger, CameraType)
{
    CameraTypeVideo = 0,
    CameraTypePhoto,
    CameraTypeAlbum
};

@interface NGCameraViewController () <TZImagePickerControllerDelegate>

@property (nonatomic,strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic,strong) GPUImageStillCamera *stillCamera;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *filter;

@property (nonatomic,strong) NGCameraPreview *imageView;
@property (nonatomic,strong) NGCameraRatioView *ratioView;
@property (nonatomic,strong) NGCameraFlashView *flashView;
@property (nonatomic,strong) NGCameraFocusView *focusView;
@property (nonatomic,strong) NGCameraBar *cameraBar;

@property (nonatomic,strong) UIButton *flashBtn;
@property (nonatomic,strong) UIButton *ratioBtn;
@property (nonatomic,strong) UIButton *beautyBtn;
@property (nonatomic,strong) UIButton *rotateBtn;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIButton *completeBtn;
@property (nonatomic,strong) UIButton *takePhotoBtn;

@property (nonatomic,strong) UIView *topBgView;
@property (nonatomic,strong) UIView *bottomBgView;
@property (nonatomic,strong) UIView *progressView;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIImageView *videoImageView;
@property (nonatomic,strong) NSArray <NSString *>* listArray;
@end

@implementation NGCameraViewController
{
    AVCaptureFlashMode _currentFlashModel;
    AVCaptureTorchMode _currentTorchModel;
    
    GPUImageMovieWriter *movieWriter;
    GPUImageMovie *movieFile;
    
    CGFloat _currentCameraRatio;
    CGFloat _lastTwoFingerDistance;
    CGFloat _videoTotalTime;
    CGFloat _currentVideoTime;
    CGFloat _lastVideoTime;
    CGFloat _progressStep;
    CGFloat _ISOValue;
    
    BOOL _isRecording;
    NSTimer *_timer;
    NSString *_pathToMovie;
    NSMutableArray *_urlArray;
    NSMutableArray *_lastTimeArray;
    MBProgressHUD *_HUD;
    CameraType _cameraType;
    NGCameraTool *_cameraTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVar];
    [self setupView];
    [self setupCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.cameraBar scrollAtIndex:_cameraType];
    [self startCameraCapture];
}

- (void)dealloc {
    [self.videoCamera stopCameraCapture];
    [self.videoCamera removeInputsAndOutputs];
    [self.videoCamera removeAllTargets];
    self.videoCamera = nil;
    self.filter = nil;
    [_HUD hideAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - SETUP
- (void)setupVar
{
    _currentCameraRatio = 1.33f;
    _videoTotalTime = 15;
    _lastVideoTime = 0;
    _currentVideoTime = 0;
    _progressStep = kMainScreenWidth * kVideoTimeInterval / _videoTotalTime;
    _currentFlashModel = AVCaptureFlashModeOff;
    _currentTorchModel = AVCaptureTorchModeOff;
    _cameraType = CameraTypePhoto;
    _cameraTool = [NGCameraTool shareCameraTool];
    _lastTimeArray = [NSMutableArray array];
    _urlArray = [NSMutableArray array];
}

- (void)setupView
{
    WeakSelf(self);
    
    // NavigationBar
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    // GPUImageView
    self.imageView = [[NGCameraPreview alloc] initWithFrame:CGRectZero];
    self.imageView.frame = CGRectMake(0, 0, kMainScreenWidth, kCameraViewHeight);
    self.imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:self.imageView];
    
    // 自动对焦
    self.imageView.handleTapGestureBlock = ^(UITapGestureRecognizer * _Nonnull tapGesture) {
        StrongSelf(self);
        if ([self.ratioView hide] || [self.flashView hide]) {
            return;
        }
        CGPoint center = [tapGesture locationInView:self.view];
        CGPoint foucus = CGPointMake(center.x/self.imageView.width, 1.0-center.y/self.imageView.height);
        [self.focusView foucusAtPoint:center withPreViewFrame:self.imageView.frame];
        [self->_cameraTool focusAtPoint:foucus];
        if (self->_ISOValue > 0) {
            [self->_cameraTool setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:self->_ISOValue completionHandler:^(CMTime syncTime) {}];
        }
    };

    // 视频缩放
    self.imageView.handlePinchGestureBlock = ^(UIPinchGestureRecognizer * _Nonnull pinchGesture) {
        StrongSelf(self);
        if (pinchGesture.numberOfTouches == 2) {
            CGPoint first = [pinchGesture locationOfTouch:0 inView:self.imageView];
            CGPoint second = [pinchGesture locationOfTouch:1 inView:self.imageView];
            if (pinchGesture.state == UIGestureRecognizerStateBegan) {
                self->_lastTwoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
            }else if (pinchGesture.state == UIGestureRecognizerStateChanged) {
                CGFloat twoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
                CGFloat scale = (twoFingerDistance - self->_lastTwoFingerDistance)/self->_lastTwoFingerDistance;
                [self->_cameraTool setVideoZoomFactor:scale + self->_cameraTool.videoZoomFactor];
                self->_lastTwoFingerDistance = twoFingerDistance;
            }else if (pinchGesture.state == UIGestureRecognizerStateEnded) {
                self->_lastTwoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
            }else if (pinchGesture.state == UIGestureRecognizerStateCancelled) {
                self->_lastTwoFingerDistance = sqrt(pow(first.x - second.x, 2) + pow(first.y-second.y, 2));
            }
        }
    };
    
    // 顶部背景
    self.topBgView = [[UIView alloc] initWithFrame:CGRectZero];
    self.topBgView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.topBgView];

    // 底部背景
    self.bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kCameraViewHeight - kCameraViewHeight)];
    self.bottomBgView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bottomBgView];

    // 记录时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kCameraTabBarSize)];
    timeLabel.font = [UIFont systemFontOfSize:17.0f];
    timeLabel.text = @"00:00";
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6f];
    timeLabel.hidden = YES;
    [self.view addSubview:timeLabel];
    self.timeLabel = timeLabel;

    // TabBar
    self.cameraBar = [[NGCameraBar alloc] initWithFrame:CGRectMake(0, kMainScreenHeigth-kCameraTabBarSize, kMainScreenWidth, kCameraTabBarSize) withListArray:self.listArray];
    self.cameraBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.001];
    [self.view addSubview:self.cameraBar];

    self.cameraBar.handleClickBlock = ^(NSInteger index) {
        StrongSelf(self);
        self->_cameraType = index;
        [self.ratioView hide];
        [self.flashView hide];
        if (index == 0) {
            [UIView animateWithDuration:0.3f animations:^{
                self.videoImageView.alpha = 1.0;
                self.videoImageView.left = (kCameraTakePhotoIconSize - kVideoImageViewSize)/2;
            }];
        } else if (index == 1) {
            [self stopRecording:nil];
            [UIView animateWithDuration:0.3f animations:^{
                self.videoImageView.left = 0;
                self.videoImageView.alpha = 0.0;
            }];
        } else {
            [self stopRecording:nil];
            [self setupImagePickerController];
        }
    };
    
    // 拍照
    UIButton *takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    takePhotoBtn.frame = CGRectMake(kMainScreenWidth/2-kCameraTakePhotoIconSize/2, (kMainScreenHeigth-kCameraTabBarSize-kCameraViewHeight-kCameraTakePhotoIconSize)/2 + kCameraViewHeight, kCameraTakePhotoIconSize, kCameraTakePhotoIconSize);
    takePhotoBtn.tag = CameraBtnTagTakePhoto;
    [takePhotoBtn setImage:[UIImage imageNamed:@"icon_takephoto_btn"] forState:UIControlStateNormal];
    [takePhotoBtn setImage:[UIImage imageNamed:@"icon_takephoto_btn"] forState:UIControlStateHighlighted];
    [takePhotoBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoBtn];
    self.takePhotoBtn = takePhotoBtn;
    [self.takePhotoBtn addSubview:self.videoImageView];
    
    // 闪光灯
    UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    flashBtn.frame = CGRectMake(0, 0, kCameraTabBarSize, kCameraTabBarSize);
    flashBtn.center = CGPointMake(kCameraBtnInterval, takePhotoBtn.center.y);
    flashBtn.tag = CameraBtnTagFlash;
    [flashBtn setImage:[UIImage imageNamed:@"icon_no_flash_btn"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"icon_no_flash_btn"] forState:UIControlStateHighlighted];
    [flashBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    self.flashBtn = flashBtn;

    // 比例按钮
    UIButton *ratioBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    ratioBtn.frame = CGRectMake(0, 0, kCameraTabBarSize, kCameraTabBarSize);
    ratioBtn.center = CGPointMake(kCameraBtnInterval * 2.8, takePhotoBtn.center.y);
    ratioBtn.tag = CameraBtnTagRatio;
    [ratioBtn setImage:[UIImage imageNamed:@"icon_ratio_34_white"] forState:UIControlStateNormal];
    [ratioBtn setImage:[UIImage imageNamed:@"icon_ratio_34_white"] forState:UIControlStateHighlighted];
    [ratioBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ratioBtn];
    self.ratioBtn = ratioBtn;

    // 美颜按钮
    UIButton *beautyBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    beautyBtn.frame = CGRectMake(0, 0, kCameraTabBarSize, kCameraTabBarSize);
    beautyBtn.center = CGPointMake(kCameraBtnInterval * 1.2 + takePhotoBtn.width + takePhotoBtn.left, takePhotoBtn.center.y);
    beautyBtn.tag = CameraBtnTagBeauty;
    [beautyBtn setImage:[UIImage imageNamed:@"beautyOFF"] forState:UIControlStateNormal];
    [beautyBtn setImage:[UIImage imageNamed:@"beautyON"] forState:UIControlStateSelected];
    [beautyBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beautyBtn];
    self.beautyBtn = beautyBtn;

    // 前后镜头
    UIButton *rotateBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    rotateBtn.frame = CGRectMake(0, 0, kCameraTabBarSize, kCameraTabBarSize);
    rotateBtn.center = CGPointMake(kCameraBtnInterval * 3 + takePhotoBtn.width + takePhotoBtn.left, takePhotoBtn.center.y);
    rotateBtn.tag = CameraBtnTagRotate;
    [rotateBtn setImage:[UIImage imageNamed:@"cammera"] forState:UIControlStateNormal];
    [rotateBtn setImage:[UIImage imageNamed:@"cammera"] forState:UIControlStateHighlighted];
    [rotateBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotateBtn];
    self.rotateBtn = rotateBtn;

    // 删除按钮
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    deleteBtn.frame = CGRectMake(30, 0, kCameraTabBarSize, kCameraTabBarSize);
    deleteBtn.centerY = takePhotoBtn.center.y;
    deleteBtn.tag = CameraBtnTagDelete;
    deleteBtn.hidden = YES;
    [deleteBtn setImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"del"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;

    // 完成按钮
    UIButton *completeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    completeBtn.frame = CGRectMake(kMainScreenWidth - kCameraTabBarSize - 30, 0, kCameraTabBarSize, kCameraTabBarSize);
    completeBtn.centerY = takePhotoBtn.center.y;
    completeBtn.tag = CameraBtnTagComplete;
    completeBtn.hidden = YES;
    [completeBtn setImage:[UIImage imageNamed:@"complete"] forState:UIControlStateNormal];
    [completeBtn setImage:[UIImage imageNamed:@"complete"] forState:UIControlStateHighlighted];
    [completeBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBtn];
    self.completeBtn = completeBtn;
}

- (void)setupCamera
{
    self.videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    [self.videoCamera addAudioInputsAndOutputs];
    _cameraTool.inputCamera = self.videoCamera.inputCamera;
    self.filter = [[GPUImageCropFilter alloc] init];
    [self.videoCamera addTarget:self.filter];
    [self.filter addTarget:self.imageView];
    [self startCameraCapture];
}

- (void)setupImagePickerController
{
    TZImagePickerController* imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVC.allowTakePicture = NO;
    imagePickerVC.allowPickingGif = NO;
    imagePickerVC.allowPickingImage = YES;
    imagePickerVC.allowPickingVideo = YES;
    imagePickerVC.isSelectOriginalPhoto = YES;
    imagePickerVC.sortAscendingByModificationDate = NO;

    WeakSelf(self);
    // 照片
    [imagePickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        NSLog(@"照片");
        StrongSelf(self);
        self->_HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self->_HUD.label.text = @"照片导出中...";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_HUD hideAnimated:YES afterDelay:1];
            [self.videoCamera stopCameraCapture];
            NGEditCameraController *editVC = [[NGEditCameraController alloc] init];
            editVC.image = photos.firstObject;
            [self.navigationController pushViewController:editVC animated:YES];
        });
    }];

    // 视频
    [imagePickerVC setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
        NSLog(@"视频");
        StrongSelf(self);
        self->_HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self->_HUD.label.text = @"视频导出中...";
        [[TZImageManager manager] getVideoWithAsset:asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            AVURLAsset *avasset = (AVURLAsset *)playerItem.asset;
            NSURL *url = avasset.URL;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.videoCamera stopCameraCapture];
                NGEditVideoController *editVC = [[NGEditVideoController alloc] init];
                editVC.videoURL = url;
                [self.navigationController pushViewController:editVC animated:YES];
                [self->_HUD hideAnimated:YES];
            });
        }];
    }];

    // 取消
    [imagePickerVC setImagePickerControllerDidCancelHandle:^{
        NSLog(@"取消");
        StrongSelf(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_HUD hideAnimated:YES];
        });
    }];

    [self presentViewController:imagePickerVC animated:YES completion:nil];
    _cameraType -= 1;
}

#pragma mark - PrivateMethod
- (void)startCameraCapture
{
    [self.videoCamera startCameraCapture];
    self.takePhotoBtn.userInteractionEnabled = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self->_cameraTool setFlashModel:self->_currentFlashModel];
        [self->_cameraTool setTorchModel:self->_currentTorchModel];
        [self->_cameraTool setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    });
}

- (void)stopStillCameraCapture
{
    self.stillCamera = (GPUImageStillCamera *)self.videoCamera;
    [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        [self.stillCamera stopCameraCapture];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.takePhotoBtn.userInteractionEnabled = YES;
            NGEditCameraController *editVC = [[NGEditCameraController alloc] init];
            editVC.image = [UIImage clipImage: [processedImage fixOrientation] withRatio:self->_currentCameraRatio];
            [self.navigationController pushViewController:editVC animated:YES];
        });
    }];
}

- (void)startRecording:(UIButton *)btn
{
    if (btn.selected) {
        btn.selected = NO;
        self.cameraBar.hidden = NO;
        self.cameraBar.hidden = NO;
        self.beautyBtn.hidden = NO;
        self.rotateBtn.hidden = NO;
        self.rotateBtn.origin = CGPointMake(kMainScreenWidth - 1.25 * kCameraTabBarSize, 0);
        self.beautyBtn.origin = CGPointMake(kMainScreenWidth - 2.25 * kCameraTabBarSize, 0);
        if (_pathToMovie == nil) {
            return;
        }
        if (_isRecording) {
            [movieWriter finishRecording];
            self.videoCamera.audioEncodingTarget = nil;
            [self.filter removeTarget:movieWriter];
            [_urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_pathToMovie]]];
            _isRecording = NO;
            [self changeVedioImage:_isRecording];
        }
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        self.deleteBtn.hidden = !_urlArray.count;
    } else {
        btn.selected = YES;
        _isRecording = YES;
        self.cameraBar.hidden = YES;
        self.flashBtn.hidden = YES;
        self.ratioBtn.hidden = YES;
        self.beautyBtn.hidden = YES;
        self.rotateBtn.hidden = YES;
        self.deleteBtn.hidden = YES;
        self.timeLabel.hidden = NO;
        [self changeVedioImage:_isRecording];

        _lastVideoTime = _currentVideoTime;
        [_lastTimeArray addObject:[NSString stringWithFormat:@"%f",_lastVideoTime]];

        _pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie%lu.mov",(unsigned long)_urlArray.count]];
        unlink([_pathToMovie UTF8String]);
        NSURL *movieURL = [NSURL fileURLWithPath:_pathToMovie];
        NSLog(@"movieURL: %@",movieURL);
        movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
        movieWriter.encodingLiveVideo = YES;
        movieWriter.shouldPassthroughAudio = YES;
        movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid;
        [self.filter addTarget:movieWriter];
        self.videoCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];
        _timer = [NSTimer scheduledTimerWithTimeInterval:kVideoTimeInterval
                                                  target:self
                                                selector:@selector(updateTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)stopRecording:(UIButton *)btn
{
    self.videoCamera.audioEncodingTarget = nil;
    if (_pathToMovie == nil) {
        return;
    }
    if (_isRecording) {
        [movieWriter finishRecording];
        [self.filter removeTarget:movieWriter];
        _isRecording = NO;
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_cameraType == CameraTypeVideo) {
        _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _HUD.label.text = @"视频生成中...";
        if (self.takePhotoBtn.selected) {
            [_urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_pathToMovie]]];
        }
        NSString *outPath = [self getVideoOutPath];
        NSLog(@"_urlArray: %@  outPath: %@",_urlArray, outPath);
        [NGCameraTool mergeFreeVideoFilePath:self->_urlArray mergeFilePath:outPath withCropRatio:self->_currentCameraRatio withCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_HUD hideAnimated:YES];
                [self.videoCamera stopCameraCapture];
                NGEditVideoController *editVC = [[NGEditVideoController alloc] init];
                editVC.videoURL = [NSURL fileURLWithPath:outPath];
                [self.navigationController pushViewController:editVC animated:YES];
            });
        }];
    }
    [_urlArray removeAllObjects];
    [_lastTimeArray removeAllObjects];
    _currentVideoTime = 0;
    _lastVideoTime = 0;
    [self changeVedioImage:_isRecording];
    self.timeLabel.text = @"00:00";
    self.timeLabel.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.completeBtn.hidden = YES;
    self.cameraBar.hidden = NO;
    self.flashBtn.hidden = NO;
    self.ratioBtn.hidden = NO;
    self.beautyBtn.hidden = NO;
    self.rotateBtn.hidden = NO;
    self.progressView.width = 0;
    self.takePhotoBtn.selected = NO;
    self.rotateBtn.center = CGPointMake(kCameraBtnInterval * 3 + self.takePhotoBtn.width + self.takePhotoBtn.left, self.takePhotoBtn.center.y);
    self.beautyBtn.center = CGPointMake(kCameraBtnInterval * 1.2 + self.takePhotoBtn.width + self.takePhotoBtn.left, self.takePhotoBtn.center.y);
}

- (void)buttonClicked:(UIButton *)btn
{
    WeakSelf(self);
    switch (btn.tag) {
        case CameraBtnTagFlash: {
            self.flashView.flashCallBack = ^(AVCaptureFlashMode flash, AVCaptureTorchMode torch, NSString * _Nonnull icon) {
                StrongSelf(self);
                self->_currentFlashModel = flash;
                self->_currentTorchModel = torch;
                [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
                [self->_cameraTool setFlashModel:flash];
                [self->_cameraTool setTorchModel:torch];
            };
            [self.ratioView hide];
            [self.flashView toggleInView:self.view withBottom:kCameraViewHeight];
            break;
        }
        case CameraBtnTagRatio: {
            self.ratioView.ratioCallBack = ^(NGSuspensionModel * _Nonnull model) {
                StrongSelf(self);
                [self setCameraRatio:model.value];
                [btn setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:model.icon] forState:UIControlStateHighlighted];
            };
            [self.flashView hide];
            [self.ratioView toggleInView:self.view withBottom:kCameraViewHeight];
            break;
        }
        case CameraBtnTagTakePhoto: {
            [self.ratioView hide];
            [self.flashView hide];
            switch (self->_cameraType) {
                case CameraTypeVideo: {
                    [self startRecording:btn];
                    break;
                }
                case CameraTypePhoto: {
                    btn.userInteractionEnabled = NO;
                    [self stopStillCameraCapture];
                    break;
                }
                case CameraTypeAlbum: {
                    break;
                }
            }
            break;
        }
        case CameraBtnTagBeauty: {
            [self.ratioView hide];
            [self.flashView hide];
            if (!btn.selected) {
                btn.selected = YES;
                [self.videoCamera removeAllTargets];
                self.filter = [[GPUImageBeautifyFilter alloc] init];
                [self.videoCamera addTarget:self.filter];
                [self.filter addTarget:self.imageView];
            } else {
                btn.selected = NO;
                [self.videoCamera removeAllTargets];
                self.filter = [[GPUImageCropFilter alloc] init];
                [self.videoCamera addTarget:self.filter];
                [self.filter addTarget:self.imageView];
            }
            break;
        }
        case CameraBtnTagRotate: {
            [self.ratioView hide];
            [self.flashView hide];
            [self.videoCamera rotateCamera];
            _cameraTool.inputCamera = self.videoCamera.inputCamera;
            break;
        }
        case CameraBtnTagDelete: {
            _currentVideoTime = [_lastTimeArray.lastObject floatValue];
            self.progressView.width = _currentVideoTime/10*kMainScreenWidth;
            self.progressView.top = self.imageView.top + self.imageView.height - kProgressViewHeight;
            self.timeLabel.text = [NSString stringWithFormat:@"00:%02d",(int)_currentVideoTime];
            if (_urlArray.count) {
                [_urlArray removeLastObject];
                [_lastTimeArray removeLastObject];
                if (_urlArray.count == 0) {
                    self.deleteBtn.hidden = YES;
                }
                if (_currentVideoTime < 3) {
                    self.completeBtn.hidden = YES;
                }
            }
            break;
        }
        case CameraBtnTagComplete: {
            [self stopRecording:btn];
            break;
        }
    }
}

#pragma mark - 定时器
- (void)updateTimer:(NSTimer *)timer
{
    _currentVideoTime += kVideoTimeInterval;
    self.timeLabel.text = [NSString stringWithFormat:@"00:%02d",(int)_currentVideoTime];
    self.progressView.width = _progressView.width + _progressStep;
    self.progressView.top = self.imageView.top + self.imageView.height - kProgressViewHeight;

    if (_currentVideoTime > 3) {
        self.completeBtn.hidden = NO;
    }
    if (_currentVideoTime >= _videoTotalTime) {
        self.takePhotoBtn.userInteractionEnabled = NO;
        [self stopRecording:nil];
    }
}

#pragma mark - 调整相机比例
- (void)setCameraRatio:(CGFloat)ratio
{
    _currentCameraRatio = ratio;
    float height = kMainScreenWidth * ratio;
    [UIView animateWithDuration:0.3f animations:^{
        CGFloat topViewHeight = kMainScreenHeigth-height-(kMainScreenHeigth-kCameraViewHeight);
        if (topViewHeight >= 0) {
            self.topBgView.frame = CGRectMake(0, 0, kMainScreenWidth, topViewHeight);
            self.bottomBgView.frame = CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kCameraViewHeight);
            self.imageView.frame = CGRectMake(0, topViewHeight, kMainScreenWidth, height);
        }else {
            self.topBgView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeigth-height);
            self.imageView.frame = CGRectMake(0, kMainScreenHeigth-height, kMainScreenWidth, height);
            self.bottomBgView.frame = CGRectMake(0, kMainScreenHeigth, kMainScreenWidth, kMainScreenHeigth-kCameraViewHeight);
        }
    }];
}

#pragma mark - 合成视频路径
- (NSString *)getVideoOutPath
{
    //沙盒中Temp路径
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    filePath = [filePath stringByAppendingPathComponent:@"ng_album"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[filePath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"_ng_video.mp4"];
    return fileName;
}

- (void)changeVedioImage:(BOOL)isRecording
{
    self.videoImageView.image = isRecording ? [UIImage imageNamed:@"icon_material_record_white~iphone"] : [UIImage imageNamed:@"icon_material_video_white~iphone"];
}

#pragma mark - Getter
- (NGCameraFocusView *)focusView
{
    if (!_focusView) {
        _focusView = [NGCameraFocusView focusView];
        [self.view addSubview:_focusView];
        WeakSelf(self);
        [_focusView setLuminanceChangeBlock:^(CGFloat value) {
            StrongSelf(self);
            self->_ISOValue = value;
            [self->_cameraTool setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:value completionHandler:^(CMTime syncTime) {}];
        }];
    }
    return _focusView;
}

- (NGCameraFlashView *)flashView
{
    if (!_flashView) {
        _flashView = [NGCameraFlashView flashSuspensionView];
    }
    return _flashView;
}

- (NGCameraRatioView *)ratioView{
    if (!_ratioView) {
        _ratioView = [NGCameraRatioView ratioSuspensionView];
    }
    return _ratioView;
}

- (UIImageView *)videoImageView
{
    if (!_videoImageView) {
        UIImage *videoImage = [UIImage imageNamed:@"icon_material_video_white~iphone"];
        _videoImageView = [[UIImageView alloc] initWithImage:videoImage];
        _videoImageView.frame = CGRectMake(0, (kCameraTakePhotoIconSize - kVideoImageViewSize)/2, kVideoImageViewSize, kVideoImageViewSize);
        _videoImageView.alpha = 0;
    }
    return _videoImageView;
}

- (UIView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.imageView.height - kProgressViewHeight , 0, kProgressViewHeight)];
        _progressView.backgroundColor = [UIColor orangeColor];
        _progressView.layer.cornerRadius = kProgressViewHeight/2;
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (NSArray *)listArray
{
    if (!_listArray) {
        _listArray = @[@"视频", @"拍摄", @"相册"];
    }
    return _listArray;
}

@end
