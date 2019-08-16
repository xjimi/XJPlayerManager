//
//  AlbumsViewController.m
//  Demo
//
//  Created by XJIMI on 2019/6/4.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "AlbumsViewController.h"
#import "AlbumModel.h"
#import "AlbumCell.h"
#import "AlbumHeader.h"
#import <Masonry/Masonry.h>

@interface AlbumsViewController () < XJTableViewDelegate >

@property (nonatomic, strong) XJTableViewManager *tableView;

@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (weak, nonatomic) IBOutlet UIView *controlsView;

@property (nonatomic, strong) XJPlayerManager *playerManager;

@end

@implementation AlbumsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createTableView];
    [self reloadData];

    self.playerManager = [[XJPlayerManager alloc] init];
}

#pragma mark - Create XJTableView and dataModel

- (void)xj_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.playerManager playInScrollView:self.tableView indexPath:indexPath rootViewController:self];

}

- (void)createTableView
{
    XJTableViewManager *tableView = [XJTableViewManager managerWithStyle:UITableViewStylePlain];
    tableView.tableViewDelegate = self;
    tableView.backgroundColor = [UIColor lightGrayColor];
    [tableView disableGroupHeaderHeight];
    [tableView disableGroupFooterHeight];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
    }];

    self.tableView = tableView;
}

- (void)reloadData {
    [self.tableView refreshDataModel:[self createDataModelWithIndex:0]];
}

- (XJTableViewDataModel *)createDataModelWithIndex:(NSInteger)index
{
    XJTableViewDataModel *dataModel = [XJTableViewDataModel
                                       modelWithSection:[self createHeaderModelWithIndex:index]
                                       rows:[self createRows]];
    return dataModel;
}

- (XJTableViewHeaderModel *)createHeaderModelWithIndex:(NSInteger)index
{
    NSString *setion = [NSString stringWithFormat:@"New Album %ld", (long)self.tableView.allDataModels.count + index];
    XJTableViewHeaderModel *headerModel = [XJTableViewHeaderModel
                                           modelWithReuseIdentifier:[AlbumHeader identifier]
                                           headerHeight:80
                                           data:setion];
    return headerModel;
}

- (NSMutableArray *)createRows
{
    NSMutableArray *rows = [NSMutableArray array];
    for (int i = 0; i < 30; i++)
    {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        AlbumModel *model = [[AlbumModel alloc] init];
        model.albumName = @"Scorpion (OVO Updated Version) [iTunes][2018]";
        model.artistName = [NSString stringWithFormat:@"%f - Drake", time];
        model.imageName = @"drake";
        NSString *url = @"https://www.youtube.com/watch?v=4ZVUmEUFwaY";
        //url = @"4ZVUmEUFwaY";
        url = (i%2) ? @"http://d2e6xlgy8sg8ji.cloudfront.net/liveedge/eratv1/chunklist.m3u8" : @"http://www.youtube.com/embed/19JrIWjBIJI";
        //url = @"ulKrn-3GraI";
        NSString *imageUrl = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", @"4ZVUmEUFwaY"];
        model.playerModel = [XJPlayerModel initWithUrl:url
                                         coverImageUrl:imageUrl];

        XJTableViewCellModel *cellModel = [XJTableViewCellModel
                                           modelWithReuseIdentifier:[AlbumCell identifier]
                                           cellHeight:self.view.frame.size.width
                                           data:model];
        [rows addObject:cellModel];
    }
    return rows;
}

#pragma mark - Controls Action

- (IBAction)action_appendRows
{
    if (!self.inputField.text.length) return;

    NSInteger sectionIndex = [self.inputField.text integerValue];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        XJTableViewHeaderModel *section = nil;
        if (sectionIndex < self.tableView.allDataModels.count)
        {
            XJTableViewDataModel *dataModel = [self.tableView.allDataModels objectAtIndex:sectionIndex];
            section = dataModel.section;
        }

        XJTableViewDataModel *newDataModel = [XJTableViewDataModel
                                              modelWithSection:section
                                              rows:[self createRows]];
        [self.tableView appendRowsWithDataModel:newDataModel];

    });
}

- (IBAction)action_appendDataModel
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *dataModels = [NSMutableArray array];
        for (NSInteger i = 0 ; i < 3; i ++) {

            /*XJTableViewHeaderModel *headerModel = [XJTableViewHeaderModel emptyModel];
            XJTableViewDataModel *newDataModel = [XJTableViewDataModel
                                                  modelWithSection:headerModel
                                                  rows:[self createRows]];*/

            XJTableViewDataModel *dataModel = [self createDataModelWithIndex:i];
            [dataModels addObject:dataModel];
        }
        [self.tableView appendDataModels:dataModels];

    });
}

- (IBAction)action_insertSection
{
    if (!self.inputField.text.length) return;

    NSInteger sectionIndex = [self.inputField.text integerValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *dataModels = [NSMutableArray array];
        for (NSInteger i = 0 ; i < 3; i ++) {
            XJTableViewDataModel *dataModel = [self createDataModelWithIndex:i];
            [dataModels addObject:dataModel];
        }

        [self.tableView insertDataModels:dataModels atSectionIndex:sectionIndex];

    });
}


@end
