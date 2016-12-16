//
//  ViewController.m
//  CCTableViewPlaceHolder
//
//  Created by maxmoo on 16/12/13.
//  Copyright © 2016年 maxmoo. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+CCTableViewPlaceHolder.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *testTableView;
@property (nonatomic, copy) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    _dataArray = [NSMutableArray array];
    
    [self initTableView];
}
#pragma mark -- tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"mainCell";
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return tableCell;
}
#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (void)initTableView{
    _testTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _testTableView.delegate = self;
    _testTableView.dataSource = self;
    [_testTableView loadingPlaceHolder];
    _testTableView.scrollWasEnabled = YES;
    [self.view addSubview:_testTableView];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(testAction1)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(testAction2)];
}

- (void)testAction1{
    [_dataArray addObject:@"1"];
    [_testTableView reloadData];
}

- (void)testAction2{
    [_dataArray removeAllObjects];
    [_testTableView emptyDataPlaceHolder];
}

@end
