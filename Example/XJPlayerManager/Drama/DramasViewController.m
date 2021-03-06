//
//  AlbumsViewController.m
//  XJCollectionViewManager_Example
//
//  Created by XJIMI on 2019/6/10.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "DramasViewController.h"
#import <Masonry/Masonry.h>
#import "DramaHeader.h"
#import "DramaCell.h"

#import <XJCollectionViewManager/XJCollectionViewManager.h>
#import <XJUtil/UIWindow+XJVisible.h>
#import <XJUtil/UIViewController+XJStatusBar.h>

//#import <XJPlayerManager/XJPlayerManager.h>
//#import <XJPlayerManager/XJPlayerModel.h>
//#import <XJPlayerManager/XJPlayerFullScreenViewController.h>
//#import <XJPlayerManager/XJPlayerUtils.h>

#import "XJPlayerManager.h"
#import "XJPlayerModel.h"
#import "XJPlayerFullScreenViewController.h"
#import "XJPlayerUtils.h"


#import "CustomControlsView.h"


@interface DramasViewController () < XJCollectionViewDelegate >

@property (nonatomic, strong) XJCollectionViewManager *collectionView;

@property (nonatomic, strong) XJPlayerManager *playerManager;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation DramasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createCollectionView];
    [self reloadData];

    XJPlayerMANAGER.defaultControlsView = [CustomControlsView class];

    self.playerManager = [[XJPlayerManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /*
    if (self.indexPath) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.playerManager playInScrollView:self.collectionView indexPath:self.indexPath rootViewController:self];
        });
    }*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.playerManager remove];
}

- (void)xj_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
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
        make.top.equalTo(self.view).mas_offset(100.0f);
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
                                            modelWithSection:nil//[self createHeaderModel]
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
        //https://dlhdl-cdn.zhanqi.tv/zqlive/7032_0s2qn.m3u8

    //https://webapi.setn.com/api/Event/GetVideoUrl?domain=video.setn.com&url=dest/2019/06/05/121332_1631/master.m3u8&DeviceType=0&videoId=121332
        url = (i%2) ? @"http://live.chosun.gscdn.com/live/_definst_/tvchosun1.stream/playlist.m3u8" : @"http://www.youtube.com/embed/4ZVUmEUFwaY";
        //url = @"ulKrn-3GraI";
        NSString *imageUrl = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", @"4ZVUmEUFwaY"];
        model.playerModel = [XJPlayerModel initWithUrl:url
                                         coverImageUrl:imageUrl];
        model.playerModel.preRollAdUrl = @"https://pubads.g.doubleclick.net/gampad/ads?sz=1024x768&iu=/123939770/Vidol-test20180420&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
        
        CGFloat vw = CGRectGetWidth(self.view.frame) - 40.0f;
        CGFloat cellh = roundf(vw * (9.0 / 16.0)) + 70.0f;
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
