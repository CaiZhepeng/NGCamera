//
//  NGMusicView.m
//  NGCamera
//
//  Created by caizhepeng on 2020/4/25.
//  Copyright © 2020 caizhepeng. All rights reserved.
//

#import "NGMusicView.h"
#import "NGMusicViewCell.h"
#import "NGMusicModel.h"

#define kMusicCollectionViewCellID  @"MusicFilteCollectionViewCellID"

@interface NGMusicView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UISwitch *swh;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic,strong) NSArray<NGMusicModel *> *musicModels;

@end

@implementation NGMusicView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupData];
        [self setupUI];
    }
    return self;
}

- (void)setupData
{
    self.musicModels = [NGMusicModel buildMusicModels];
}

- (void)setupUI
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.width-15, 44)];
    label.text = [NSString stringWithFormat:@"删除原声"];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.hidden = YES;
    [self addSubview:label];
    self.label = label;
    
    UISwitch *swh = [[UISwitch alloc] initWithFrame:CGRectMake(self.width - 50 - 15, 6, 50, 30)];
    swh.hidden = YES;
    swh.onTintColor = [UIColor colorWithRed:16/255.0 green:118/255.0 blue:241/255.0 alpha:1.0];
    [swh addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:swh];
    self.swh = swh;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 38, self.width,self.height-38) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"NGMusicViewCell" bundle:nil] forCellWithReuseIdentifier:kMusicCollectionViewCellID];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)switchClicked:(UISwitch *)swh
{
    swh.selected = !swh.selected;
    if (self.editTheOriginaSwitch) {
        self.editTheOriginaSwitch(swh.selected);
    }
}

- (void)reloadData
{
    self.swh.on = NO;
    self.swh.selected = NO;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.musicModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NGMusicViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMusicCollectionViewCellID forIndexPath:indexPath];
    NGMusicModel *musicModel = self.musicModels[indexPath.row];
    cell.label.text = musicModel.name;
    cell.imageView.image = [UIImage imageNamed:musicModel.iconPath];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *lastSelectCell = [collectionView cellForItemAtIndexPath:self.lastSelectedIndexPath];
    [lastSelectCell setSelected:NO];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:YES];
    
    if (self.lastSelectedIndexPath != indexPath) {
        if (self.musicClick) {
            NGMusicModel *model = self.musicModels[indexPath.row];
            self.musicClick(model.audioPath);
        }
    }
    _lastSelectedIndexPath = indexPath;
    
    if (indexPath.row == 0) {
        self.swh.hidden = YES;
        self.label.hidden = YES;
    } else {
        self.swh.hidden = NO;
        self.label.hidden = NO;
        NSLog(@"%d",self.swh.selected);
        if (self.editTheOriginaSwitch) {
            self.editTheOriginaSwitch(self.swh.selected);
        }
    }
}


@end
