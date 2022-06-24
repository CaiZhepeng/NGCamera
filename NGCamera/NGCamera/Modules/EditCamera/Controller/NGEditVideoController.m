//
//  NGEditVideoController.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/30.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGEditVideoController.h"
#import "LFGPUImageEmptyFilter.h"
#import "NGCameraFilterView.h"
#import "NGCameraEditView.h"
#import "NGVideoClipView.h"
#import "NGMusicView.h"
#import "NGCameraTool.h"
#import "MBProgressHUD.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM (NSInteger, EditButtonTag)
{
    EditButtonTagBack = 1,
    EditButtonTagSave,
    EditButtonTagRestore,
    EditButtonTagFilter,
    EditButtonTagEdit,
    EditButtonTagCrop,
    EditButtonTagMusice,
};

#define kEditVideoBarHeight 35
#define kEditViewHeight (kMainScreenHeigth - kCameraViewHeight - kEditVideoBarHeight)

@interface NGEditVideoController ()
@property (nonatomic,strong) GPUImageView *imageView;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayer *audioPlayer;
@property (nonatomic,strong) AVPlayerItem *audioPlayerItem;

@property (nonatomic,strong) UIImageView *bgView;
@property (nonatomic,strong) NGCameraFilterView *filterView;
@property (nonatomic,strong) NGCameraEditView *editView;
@property (nonatomic,strong) NGVideoClipView *clipView;
@property (nonatomic,strong) NGMusicView *musicView;

@property (nonatomic,assign) CGFloat startTime;
@property (nonatomic,assign) CGFloat endTime;
@property (nonatomic,assign) BOOL isClipVideo;
@property (nonatomic,assign) BOOL isOriginaSwitchOn;

@end

@implementation NGEditVideoController
{
    UIButton *_lastBtn;
    UIView *_lastView;
    NSString *_audioPath;
    NSString *_filterName;
    NSMutableArray *_editFilters;
    
    LFGPUImageEmptyFilter *emptyFilter;
    GPUImageMovie *movieFile;
    GPUImageMovie *tmpMovieFile;
    GPUImageMovieWriter *movieWriter;
    GPUImageFilterGroup *filterGroup;
    
    NGCameraTool *_cameraTool;
    MBProgressHUD *_HUD;
}

#pragma mark - Init
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVar];
    [self setupAVPlayer];
    [self setupView];
}

- (void)dealloc
{
    [self removeNotification];
    [self.player pause];
    [self.audioPlayer pause];
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    self.player = nil;
    self.audioPlayer = nil;
    [movieFile removeAllTargets];
    [movieFile endProcessing];
    movieFile = nil;
    NSLog(@"NGEditVideoController 释放了");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //开始播放
    [self.player play];
    [movieFile startProcessing];
    [self barItemClicked:_lastBtn];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopPlay];
    [movieFile endProcessing];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Setup
- (void)setupVar
{
    self.startTime = 0.0;
    self.endTime = 15.0;
    _editFilters = [NSMutableArray array];
    _cameraTool = [NGCameraTool shareCameraTool];
}

- (void)setupAVPlayer
{
    AVPlayer *player = [[AVPlayer alloc] init];
    AVPlayer *audioPlayer = [[AVPlayer alloc] init];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [player replaceCurrentItemWithPlayerItem:playerItem];
    self.player = player;
    self.audioPlayer = audioPlayer;

    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kCameraViewHeight)];
    [self.view addSubview:bgView];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = bgView.bounds;
    [bgView.layer insertSublayer:playerLayer atIndex:0];
    
    movieFile = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    movieFile.shouldRepeat = YES;
    
    emptyFilter = [[LFGPUImageEmptyFilter alloc] init];
    
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kCameraViewHeight)];
    imageView.transform = CGAffineTransformMakeRotation(kDegreesToRadian([NGCameraTool degressFromVideoFileWithURL:self.videoURL]));
    [bgView addSubview:imageView];
    [movieFile addTarget:emptyFilter];
    [emptyFilter addTarget:imageView];
    [bgView bringSubviewToFront:imageView];
    self.imageView = imageView;
}

- (void)setupView
{
    self.view.backgroundColor = [UIColor blackColor];
    
    // TopView
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kEditVideoBarHeight)];
    topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:topView];
    
    // BackButton
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, (kEditVideoBarHeight - 28)/2, 50, 28)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTag:EditButtonTagBack];
    [topView addSubview:backBtn];
    
    // SaveButton
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth - 50 - 15, (kEditVideoBarHeight - 28)/2, 50, 28)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setTag:EditButtonTagSave];
    [topView addSubview:saveBtn];
    
    // RestoreButton
    UIButton *restoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/2-50/2, (kEditVideoBarHeight - 28)/2, 50, 28)];
    [restoreBtn setTitle:@"复原" forState:UIControlStateNormal];
    [restoreBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [restoreBtn setTag:EditButtonTagRestore];
    [topView addSubview:restoreBtn];
    
    // BottomView
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeigth - kEditVideoBarHeight, kMainScreenWidth, kEditVideoBarHeight)];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    
    // LineView
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 0.3)];
    lineView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3];
    [bottomView addSubview:lineView];
    
    // FilterButton
    UIButton *filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth/4, kEditVideoBarHeight)];
    [filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
    [filterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [filterBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn setTag:EditButtonTagFilter];
    [bottomView addSubview:filterBtn];
    _lastBtn = filterBtn;
    
    // EditButton
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/4, 0, kMainScreenWidth/4, kEditVideoBarHeight)];
    [editBtn setTitle:@"调整" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [editBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTag:EditButtonTagEdit];
    [bottomView addSubview:editBtn];
    
    // CropButton
    UIButton *cropBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/2, 0, kMainScreenWidth/4, kEditVideoBarHeight)];
    [cropBtn setTitle:@"剪切" forState:UIControlStateNormal];
    [cropBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cropBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [cropBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cropBtn setTag:EditButtonTagCrop];
    [bottomView addSubview:cropBtn];
    
    // MusiceButton
    UIButton *musiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/4 * 3, 0, kMainScreenWidth/4, kEditVideoBarHeight)];
    [musiceBtn setTitle:@"音乐" forState:UIControlStateNormal];
    [musiceBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [musiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [musiceBtn addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [musiceBtn setTag:EditButtonTagMusice];
    [bottomView addSubview:musiceBtn];
}

#pragma mark - Notification
- (void)didBecomActiveNotification:(NSNotification *)notification
{
    // 进入前台
    [self startPlay];
    [movieFile startProcessing];
}

- (void)willResignActiveNotification:(NSNotification *)notification
{
    // 进入后台
    [self stopPlay];
    [movieFile endProcessing];
}

- (void)playbackFinished:(NSNotification *)notification
{
    [self startPlay];
    [movieFile startProcessing];
}

#pragma mark - 监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {//开始播放
            [self monitoringPlayback:playerItem];
        }
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    WeakSelf(self);
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 100) queue:NULL usingBlock:^(CMTime time) {
        StrongSelf(self);
        CGFloat currentTime = 1.0*time.value/time.timescale;
        if (currentTime >= self.endTime) {
            [self stopPlay];
            [self startPlay];
        } else {
            if (self.isClipVideo) {
                self.clipView.currentTime = currentTime;
            }
        }
    }];
}

#pragma mark - 重新播放
- (void)startPlay
{
    [self.player seekToTime:CMTimeMake(self.startTime * self.player.currentItem.duration.timescale, self.player.currentItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.player play];
    }];
    if (_audioPath) {
        [self.audioPlayerItem seekToTime:kCMTimeZero];
        [self.audioPlayer play];
    }
}

- (void)stopPlay
{
    [self.player pause];
    [self.audioPlayer pause];
}

- (void)playMusic
{
    if (_audioPath) {
        NSURL *audioURL = [NSURL fileURLWithPath:_audioPath];
        self.audioPlayerItem = [AVPlayerItem playerItemWithURL:audioURL];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:self.audioPlayerItem];
        [self.audioPlayer setVolume:1.0];
        [self.audioPlayer play];
    } else {
        [self.audioPlayer pause];
    }
}

#pragma mark - Event
- (void)buttonClicked:(UIButton *)btn
{
    switch (btn.tag) {
        case EditButtonTagBack: {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case EditButtonTagSave: {
            if (_filterName || _editFilters.count != 0) {
                // 滤镜合成
                [self filterCompositionForFilter:filterGroup withVideoUrl:self.videoURL];
            } else if (_audioPath) {
                // 合成音乐
                [self musicComposition:self.videoURL];
            } else {
                //什么都不需要合成，直接返回成功
                [self compressedVideo:self.videoURL];
            }
            break;
        }
        case EditButtonTagRestore: {
            self.startTime = 0.0;
            self.endTime = 15.0;
            
            [self.editView reloadData];
            [self.filterView reloadData];
            [self.clipView reloadData];
            [self.musicView reloadData];
            
            [movieFile removeAllTargets];
            [filterGroup removeAllTargets];
            [movieFile addTarget:emptyFilter];
            [emptyFilter addTarget:self.imageView];
            
            _audioPath = nil;
            _filterName = nil;
            [_editFilters removeAllObjects];
            [self.player setVolume:1];
            [self stopPlay];
            [self startPlay];
            break;
        }
    }
}

- (void)barItemClicked:(UIButton *)btn
{
    _lastBtn.selected = NO;
    btn.selected = YES;
    _lastBtn = btn;
    [_lastView removeFromSuperview];
    self.isClipVideo = NO;
    
    switch (btn.tag) {
        case EditButtonTagFilter: {
            [self.view addSubview:self.filterView];
            _lastView = self.filterView;
            break;
        }
        case EditButtonTagEdit: {
            [self.view addSubview:self.editView];
            _lastView = self.editView;
            break;
        }
        case EditButtonTagCrop: {
            [self.view addSubview:self.clipView];
            _lastView = self.clipView;
            self.isClipVideo = YES;
            [self.player pause];
            [self startPlay];
            break;
        }
        case EditButtonTagMusice: {
            [self.view addSubview:self.musicView];
            _lastView = self.musicView;
            break;
        }
        default:
            break;
    }
}

#pragma mark - 保存到相册
- (void)saveVideoToLibraryWithOutPath:(NSURL *)videoURL
{
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.label.text = @"视频保存中...";
    __block NSString *localIdentifier;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        localIdentifier = req.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self->_HUD.label.text = @"视频保存成功";
                [self->_HUD hideAnimated:YES afterDelay:1.0];
            } else {
                self->_HUD.label.text = @"视频保存失败";
                [self->_HUD hideAnimated:YES afterDelay:1.0];
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

#pragma mark - 合成滤镜
- (void)filterCompositionForFilter:(GPUImageFilterGroup *)filterGroup withVideoUrl:(NSURL *)videoURL
{
    NSUInteger a = [NGCameraTool degressFromVideoFileWithURL:videoURL];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(a / 180.0 * M_PI );
    
    GPUImageFilterGroup *tmpFilterGroup = [[GPUImageFilterGroup alloc] init];
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    GPUImageWhiteBalanceFilter *whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    GPUImageHighlightShadowFilter *highlightFilter = [[GPUImageHighlightShadowFilter alloc] init];
    GPUImageHighlightShadowFilter *lowlightFilter = [[GPUImageHighlightShadowFilter alloc] init];
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    
    NSMutableArray *filters = [NSMutableArray array];
    [filters addObject:brightnessFilter];
    [filters addObject:contrastFilter];
    [filters addObject:whiteBalanceFilter];
    [filters addObject:saturationFilter];
    [filters addObject:highlightFilter];
    [filters addObject:lowlightFilter];
    [filters addObject:exposureFilter];
    [filters addObject:sharpenFilter];
    
    Class class = NSClassFromString(_filterName);
    GPUImageOutput<GPUImageInput> *filter = [[class alloc] init];
    [filters addObject:filter];
    
    for (NSInteger i = 0; i < filters.count; i++) {
        for (NGEditFilterModel *model in _editFilters) {
            if (i == model.index) {
                [_editView changeValueForFilter:filters[i]
                                          index:model.index
                                          value:model.value
                                          image:nil];
            }
        }
        [_editView addGPUImageFilter:filters[i] filterGroup:tmpFilterGroup];
    }
    
    tmpMovieFile = [[GPUImageMovie alloc] initWithURL:videoURL];
    tmpMovieFile.runBenchmark = YES;
    tmpMovieFile.playAtActualSpeed = NO;
    [tmpMovieFile addTarget:tmpFilterGroup];

    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/filter_video.mp4"];
    unlink([pathToMovie UTF8String]);
    NSURL *outputURL = [NSURL fileURLWithPath:pathToMovie];

    CGSize videoSize = self.player.currentItem.presentationSize;
    NSLog(@"%f,%f",self.player.currentItem.presentationSize.height,self.player.currentItem.presentationSize.width);
    if (a == 90 || a == 270) {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:outputURL size:videoSize];
    movieWriter.transform = rotate;
    movieWriter.shouldPassthroughAudio = YES;
    tmpMovieFile.audioEncodingTarget = movieWriter;
    [tmpMovieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];

    [tmpFilterGroup addTarget:movieWriter];

    [movieWriter startRecording];
    [tmpMovieFile startProcessing];

    WeakSelf(self);
    __weak GPUImageMovieWriter *weakmovieWriter = movieWriter;
    [movieWriter setCompletionBlock:^{
        StrongSelf(self);
        NSLog(@"滤镜添加成功");
        [tmpFilterGroup removeTarget:weakmovieWriter];
        [weakmovieWriter finishRecording];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_audioPath) {
                NSLog(@"滤镜添加成功,添加音乐");
                [self musicComposition:outputURL];
            } else {
                NSLog(@"滤镜添加成功,压缩视频");
                [self compressedVideo:outputURL];
            }
        });
    }];
}

#pragma mark - 音乐混合
- (void)musicComposition:(NSURL *)videoURL
{
    if (_audioPath) {
        NSURL *audioURL = [NSURL fileURLWithPath:_audioPath];
        
        // 合成后视频输出的路径
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/music_video.mp4"];
        unlink([pathToMovie UTF8String]);
        NSURL *outputURL = [NSURL fileURLWithPath:pathToMovie];
        
        // 视频时间起点、范围
        CGFloat length = [self videoTotalTime];
        CMTime startTime = CMTimeMakeWithSeconds(self.startTime, self.player.currentItem.duration.timescale);
        CMTime videoLenth = CMTimeMakeWithSeconds(length, self.player.currentItem.duration.timescale);
        CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoLenth);
        
        // 创建可变的音视频组合
        AVMutableComposition *composition = [AVMutableComposition composition];
        
        // 视频采集
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:options];
        
        // 视频通道
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // 视频采集通道
        AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        
        // 把采集轨道数据加入到可变轨道之中
        [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:startTime error:nil];
        
        // 声音采集
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:options];
        
        // 音乐时间范围
        CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoLenth);
        
        // 音频通道
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // 音频采集通道
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        // 加入合成轨道之中
        [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
        
        if (!self.isOriginaSwitchOn) {
            AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
            AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
            [mixParameters setVolume:0.5f atTime:kCMTimeZero];
            mutableAudioMix.inputParameters = @[mixParameters];

            AVMutableCompositionTrack *audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:kCMTimeZero error:nil];

            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
            exportSession.audioMix = mutableAudioMix;
            exportSession.timeRange = videoTimeRange;
            exportSession.outputURL = outputURL;
            exportSession.outputFileType = AVFileTypeMPEG4;
            exportSession.shouldOptimizeForNetworkUse = YES;

            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                        NSLog(@"混音添加成功");
                        [self saveVideoToLibraryWithOutPath:outputURL];
                    } else {
                        NSLog(@"混音添加压缩视频失败");
                    }
                });
            }];
        } else {
            
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
            exportSession.timeRange = videoTimeRange;
            exportSession.outputURL = outputURL;
            exportSession.outputFileType = AVFileTypeMPEG4;
            exportSession.shouldOptimizeForNetworkUse = YES;

            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                        NSLog(@"音乐添加成功");
                        [self saveVideoToLibraryWithOutPath:outputURL];
                    } else {
                        NSLog(@"音乐添加压缩视频失败");
                    }
                });
            }];
        }
    }
}

#pragma mark - 压缩视频
- (void)compressedVideo:(NSURL *)videoURL
{
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:options];

    CGFloat length = [self videoTotalTime];
    CMTime startTime = CMTimeMakeWithSeconds(self.startTime, self.player.currentItem.duration.timescale);
    CMTime videoLenth = CMTimeMakeWithSeconds(length, self.player.currentItem.duration.timescale);
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoLenth);
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/compressed_Video.mp4"];
    unlink([pathToMovie UTF8String]);
    NSURL *outputURL = [NSURL fileURLWithPath:pathToMovie];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exportSession.timeRange = videoTimeRange;
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"压缩视频成功");
                [self saveVideoToLibraryWithOutPath:outputURL];
            } else {
                NSLog(@"压缩视频失败");
            }
        });
    }];
}

- (CGFloat)videoTotalTime
{
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.videoURL options:options];

    CGFloat length = asset.duration.value*1.0f / asset.duration.timescale;
    if (length > 15 ) {
        length = 15;
    } else if (length > (self.endTime - self.startTime)) {
        length = self.endTime - self.startTime;
    }
    return length;
}

#pragma mark - getter
- (NGCameraFilterView *)filterView
{
    if (!_filterView) {
        _filterView = [[NGCameraFilterView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kEditViewHeight)];
        _filterView.backgroundColor = [UIColor blackColor];
        
        WeakSelf(self);
        _filterView.filterClick = ^(UIImage * _Nonnull image, NSString * _Nonnull filterName) {
            StrongSelf(self);
            [self->movieFile removeAllTargets];
            
            self->_filterName = filterName;
            Class class = NSClassFromString(filterName);
            GPUImageOutput<GPUImageInput> *filter = [[class alloc] init];
            self->filterGroup = [[GPUImageFilterGroup alloc] init];
            self.editView.filterGroup = self->filterGroup;
            [self.editView addFilter:filter];
            
            [self->movieFile addTarget:self->filterGroup];
            [self->filterGroup addTarget:self.imageView];
        };
    }
    return _filterView;
}

- (NGCameraEditView *)editView
{
    if (!_editView) {
        _editView = [[NGCameraEditView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kEditViewHeight)];
        _editView.isVideo = YES;
        _editView.backgroundColor = [UIColor blackColor];
        if (!filterGroup) {
            filterGroup = [[GPUImageFilterGroup alloc] init];
            _editView.filterGroup = filterGroup;
        }
        
        WeakSelf(self);
        _editView.editVdeoClick = ^(NGEditFilterModel * _Nonnull editFilterModel) {
            StrongSelf(self);
            [self->_editFilters addObject:editFilterModel];
            [self->movieFile removeAllTargets];
            [self->movieFile addTarget:self->filterGroup];
            [self->filterGroup addTarget:self.imageView];
        };
    }
    return _editView;
}

- (NGVideoClipView *)clipView
{
    if (!_clipView) {
        _clipView = [[NGVideoClipView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kEditViewHeight) videoURL:self.videoURL];
        _clipView.backgroundColor = [UIColor blackColor];
        
        WeakSelf(self);
        _clipView.getVideoTimeRange = ^(CGFloat startTime, CGFloat endTime, CGFloat jumpTime) {
            StrongSelf(self);
            self.startTime = startTime;
            self.endTime = endTime;
            [self.player pause];
            CMTime time = CMTimeMake(jumpTime * self.player.currentItem.duration.timescale, self.player.currentItem.duration.timescale);
            [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {}];
        };
        _clipView.didDragEnd = ^{
            StrongSelf(self);
            [self startPlay];
        };
    }
    return _clipView;
}

- (NGMusicView *)musicView
{
    if (!_musicView) {
        _musicView = [[NGMusicView alloc] initWithFrame:CGRectMake(0, kCameraViewHeight, kMainScreenWidth, kEditViewHeight)];
        _musicView.backgroundColor = [UIColor blackColor];
        
        WeakSelf(self);
        _musicView.musicClick = ^(NSString * _Nonnull audioPath) {
            StrongSelf(self);
            if (!audioPath) {
                [self.player setVolume:1];
            }
            self->_audioPath = audioPath;
            [self playMusic];
        };
        _musicView.editTheOriginaSwitch = ^(BOOL isON) {
            StrongSelf(self);
            if (isON) {
                self.isOriginaSwitchOn = NO;
                [self.player setVolume:1];
            } else {
                self.isOriginaSwitchOn = YES;
                [self.player setVolume:0];
            }
        };
    }
    return _musicView;
}

#pragma mark - 移除通知
- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
