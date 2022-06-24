//
//  NGSuspensionView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/9/11.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGSuspensionView.h"

#define kSuspensionCollectionViewCellID          @"SuspensionCollectionViewCellID"
#define kSuspensionCollectionImageViewTag        101

@interface NGSuspensionView() <UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation NGSuspensionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6f]];
        [self buildCollectionView];
    }
    return self;
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60,self.height-20);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    return layout;
}

- (void)buildCollectionView
{
    // collectionView
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.width,self.height) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSuspensionCollectionViewCellID];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

#pragma mark - PublicMethod
- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)toggleInView:(UIView *)view withBottom:(CGFloat)bottom
{
    if (!self.superview) {
        [self showInView:view withBottom:bottom];
    } else {
        self.hidden = !self.hidden;
    }
}

- (void)showInView:(UIView *)view withBottom:(CGFloat)bottom
{
    if (self.superview) {
        return;
    }
    self.hidden = NO;
    self.top = bottom - self.height - kCameraRatioSuspensionViewMargin;
    [view addSubview:self];
}

- (BOOL)hide
{
    if (self.isHidden) {
        return NO;
    }else {
        self.hidden = YES;
        return YES;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _suspensionModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSuspensionCollectionViewCellID forIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:kSuspensionCollectionImageViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kSuspensionCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
    }
    NGSuspensionModel *model = _suspensionModels[indexPath.row];
    imageView.image = [UIImage imageNamed:model.icon];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NGSuspensionModel *model = _suspensionModels[indexPath.row];
    if (self.suspensionModelClickBlock) {
        self.suspensionModelClickBlock(model);
    }
}

@end

@implementation NGSuspensionModel

+ (NSArray<NGSuspensionModel *> *)buildSuspensionModelsWithJson:(NSString *)jsonStr
{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (!array) {
        return nil;
    }
    
    NSMutableArray *cropsArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NGSuspensionModel *model = [NGSuspensionModel yy_modelWithDictionary:dict];
        if (model) {
            [cropsArray addObject:model];
        }
    }
    return cropsArray;
}

+ (NSArray<NGSuspensionModel *> *)buildSuspensionModelsWithConfig:(NSString *)path
{
    NSData *jsonConfig = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonConfig options:NSJSONReadingMutableContainers error:nil];
    if (!array) {
        return nil;
    }
    
    NSMutableArray *cropsArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NGSuspensionModel *model = [NGSuspensionModel yy_modelWithDictionary:dict];
        if (model) {
            [cropsArray addObject:model];
        }
    }
    return cropsArray;
}

@end
