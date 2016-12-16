//
//  UITableView+CCTableViewPlaceHolder.h
//  CCTableViewPlaceHolder
//
//  Created by maxmoo on 16/12/13.
//  Copyright © 2016年 maxmoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (CCTableViewPlaceHolder)


//holder设计
/*
 1,
 2,使用＋load方法交换之前的reloadData方法，无需改变即可使用。
 3,加载时图，网络出错等异常视图都可使用。且提供一套默认的视图。
 */

//视图是否可以滚动。默认为yes，即可以滚动
@property (nonatomic, assign) BOOL scrollWasEnabled;
//自定义placeHolder视图
- (void)setCustomPlaceHolderView:(UIView *)view;

//强制为tableView添加placeHolderview
/*我在考虑有时在刷新的过程中table中本有数据，此时网络断开根据需要可能会替换为无网络的提示,
 但是大多数在有数据的情况下由于网络原因加载失败时会保持之前的数据，选择其他方式提醒用户网络出错,而不是采用替换的方式
 但也不排除有这样强制的需求，谁知道呢*/
- (void)setForcePlaceHolderView:(UIView *)view;



//快捷模块。默认视图，供自己使用.
- (void)networkBadPlaceHolder;
//无数据
- (void)emptyDataPlaceHolder;
//加载
- (void)loadingPlaceHolder;

@end
