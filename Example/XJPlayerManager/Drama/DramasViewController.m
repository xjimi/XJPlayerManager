//
//  AlbumsViewController.m
//  XJCollectionViewManager_Example
//
//  Created by XJIMI on 2019/6/10.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "DramasViewController.h"
#import <XJCollectionViewManager/XJCollectionViewManager.h>
#import <Masonry/Masonry.h>
#import "DramaHeader.h"
#import "DramaCell.h"

//#import <XJPlayerManager/XJPlayerModel.h>
//#import <XJPlayerManager/XJPlayerFullScreenViewController.h>
#import <XJUtil/UIWindow+XJVisible.h>
#import "XJPlayerModel.h"
#import "XJPlayerFullScreenViewController.h"

@interface DramasViewController () < XJCollectionViewDelegate >

@property (nonatomic, strong) XJCollectionViewManager *collectionView;

@property (nonatomic, strong) XJPlayerManager *playerManager;

@end

@implementation DramasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createCollectionView];
    [self reloadData];

    self.playerManager = [[XJPlayerManager alloc] init];
    //[self.playerManager autoPlayInScrollView:self.collectionView rootViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)xj_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.playerManager playInScrollView:self.collectionView indexPath:indexPath rootViewController:self];
}

#pragma mark - Create XJCollectionView and dataModel

- (void)createCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 3;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 3, 0);
    
    XJCollectionViewManager *collectionView = [XJCollectionViewManager managerWithCollectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor lightGrayColor];
    collectionView.collectionViewDelegate = self;
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.collectionView = collectionView;

    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }

}

- (void)reloadData {
    self.collectionView.data = @[[self createDataModel]].mutableCopy;
}

- (XJCollectionViewDataModel *)createDataModel
{
    XJCollectionViewDataModel *dataModel = [XJCollectionViewDataModel
                                            modelWithSection:[self createHeaderModel]
                                            rows:[self createRows]];
    return dataModel;
}

- (XJCollectionReusableModel *)createHeaderModel
{
    NSString *setion = [NSString stringWithFormat:@"New Drama %ld", (long)self.collectionView.data.count + 1];
    CGFloat vw = CGRectGetWidth(self.view.frame);
    XJCollectionReusableModel *headerModel = [XJCollectionReusableModel
                                              modelWithReuseIdentifier:[DramaHeader identifier]
                                              size:CGSizeMake(vw, 50)
                                              data:setion];
    return headerModel;
}

- (NSMutableArray *)createRows
{
    NSMutableArray *rows = [NSMutableArray array];
    for (int i = 0; i < 9; i++)
    {
        DramaModel *model = [[DramaModel alloc] init];
        model.dramaName = @"Signal";
        model.detailInfo = @"tvN Korean Drama of 2018";
        model.imageName = @"drama";
        
        NSString *url = @"https://www.youtube.com/watch?v=4ZVUmEUFwaY";
        //url = @"4ZVUmEUFwaY";
        //url = @"http://d2e6xlgy8sg8ji.cloudfront.net/liveedge/eratv1/chunklist.m3u8";
        url = @"ulKrn-3GraI";
        //NSString *imageUrl = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", url];
        model.playerModel = [XJPlayerModel initWithUrl:url
                                         coverImageUrl:nil];

        CGFloat vw = CGRectGetWidth(self.view.frame);
        CGFloat cellh = roundf(vw * (9.0 / 16.0)) + 70;
        XJCollectionViewCellModel *cellModel = [XJCollectionViewCellModel
                                                modelWithReuseIdentifier:[DramaCell identifier]
                                                size:CGSizeMake(vw, cellh)
                                                data:model];
        [rows addObject:cellModel];
    }
    return rows;
}

#pragma mark - Controls Action

- (IBAction)action_appendRows
{
    XJCollectionViewDataModel *newDataModel = [XJCollectionViewDataModel
                                               modelWithSection:0
                                               rows:[self createRows]];
    [self.collectionView appendRowsWithDataModel:newDataModel];
}

- (IBAction)action_appendDataModel
{
    XJCollectionViewDataModel *newDataModel = [XJCollectionViewDataModel
                                               modelWithSection:nil
                                               rows:[self createRows]];
    [self.collectionView appendDataModel:newDataModel];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
