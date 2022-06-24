//
//  NGCameraFilterView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/10/10.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraFilterView.h"
#import "NGFilterViewCell.h"
#import "NGFilterModel.h"

#define kCameraFilteCollectionViewCellID  @"CameraFilteCollectionViewCellID"

@interface NGCameraFilterView() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic,strong) NSArray<NGFilterModel *> *filterArray;
@end

@implementation NGCameraFilterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createData];
        [self createCollectionView];
    }
    return self;
}

- (void)createData
{
    self.filterArray = [NGFilterModel buildFilterModels];
}

- (void)createCollectionView
{
    // collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 110);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"NGFilterViewCell" bundle:nil] forCellWithReuseIdentifier:kCameraFilteCollectionViewCellID];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.filterArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NGFilterViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCameraFilteCollectionViewCellID forIndexPath:indexPath];
    NGFilterModel *filterModel = self.filterArray[indexPath.row];
    cell.label.text = filterModel.listName;
    cell.imageView.image = filterModel.filterImage;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *lastSelectCell = [collectionView cellForItemAtIndexPath:self.lastSelectedIndexPath];
    [lastSelectCell setSelected:NO];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:YES];
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if (self.lastSelectedIndexPath != indexPath) {
        if (self.filterClick) {
            UIImage *image = nil;
            if (self.image) {
                image = [NGFilterModel selectedFilterAtIndex:indexPath.row image:self.image];
            }
            NGFilterModel *filterModel = self.filterArray[indexPath.row];
            self.filterClick(image, filterModel.filterName);
        }
    }
    _lastSelectedIndexPath = indexPath;
}


@end
