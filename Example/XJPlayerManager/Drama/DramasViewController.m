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
#import "XJPlayerUtils.h"
#import <XJUtil/UIViewController+XJStatusBar.h>

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.playerManager remove];
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
        make.top.equalTo(self.view).mas_offset(20.0f);
        make.left.bottom.right.equalTo(self.view);
    }];

    self.collectionView = collectionView;
    /*
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }*/


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
    CGFloat vw = XJP_PortraitW;
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
        url = (i%2) ? @"https://dlhdl-cdn.zhanqi.tv/zqlive/7032_0s2qn.m3u8" : @"http://www.youtube.com/embed/19JrIWjBIJI";
        //url = @"ulKrn-3GraI";
        NSString *imageUrl = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", @"4ZVUmEUFwaY"];
        model.playerModel = [XJPlayerModel initWithUrl:url
                                         coverImageUrl:imageUrl];
        //model.playerModel.muted = YES;
        CGFloat vw = CGRectGetWidth(self.view.frame) - 40.0f;
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

- (BOOL)prefersStatusBarHidden {
    return [super prefersStatusBarHidden];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
