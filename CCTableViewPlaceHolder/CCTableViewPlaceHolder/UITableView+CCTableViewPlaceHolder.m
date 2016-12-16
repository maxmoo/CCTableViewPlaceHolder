//
//  UITableView+CCTableViewPlaceHolder.m
//  CCTableViewPlaceHolder
//
//  Created by maxmoo on 16/12/13.
//  Copyright © 2016年 maxmoo. All rights reserved.
//

#import "UITableView+CCTableViewPlaceHolder.h"
#import <objc/runtime.h>

@interface UITableView ()

@property (nonatomic, strong) UIView *placeHolderView;
@property (nonatomic) NSNumber *oldSeparatorStyle;

@end

@implementation UITableView (CCTableViewPlaceHolder)

#pragma mark -property
- (BOOL)scrollWasEnabled {
    NSNumber *scrollWasEnabledObject = objc_getAssociatedObject(self, @selector(scrollWasEnabled));
    return [scrollWasEnabledObject boolValue];
}

- (void)setScrollWasEnabled:(BOOL)scrollWasEnabled {
    self.bounces = scrollWasEnabled;
    NSNumber *scrollWasEnabledObject = [NSNumber numberWithBool:scrollWasEnabled];
    objc_setAssociatedObject(self, @selector(scrollWasEnabled), scrollWasEnabledObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)placeHolderView {
    return objc_getAssociatedObject(self, @selector(placeHolderView));
}

- (void)setPlaceHolderView:(UIView *)placeHolderView{
    if (self.placeHolderView) {
        [self.placeHolderView removeFromSuperview];
        self.separatorStyle = (UITableViewCellSeparatorStyle)[self.oldSeparatorStyle integerValue];
    }
    objc_setAssociatedObject(self, @selector(placeHolderView), placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)oldSeparatorStyle{
    return objc_getAssociatedObject(self, @selector(oldSeparatorStyle));
}

- (void)setOldSeparatorStyle:(NSNumber *)oldSeparatorStyle{
    objc_setAssociatedObject(self, @selector(oldSeparatorStyle), oldSeparatorStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - runtime
//使用交换reloadData和自定义的cc_reloadData方法.
+ (void)load{
    
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, @selector(reloadData));
    Method swizzledMethod = class_getInstanceMethod(class, @selector(cc_reloadData));
    BOOL didAddMethod = class_addMethod(class,@selector(reloadData),
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,@selector(cc_reloadData),
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

#pragma mark - customMethod
- (void)cc_reloadData{
    //调用reloadData
    [self cc_reloadData];
    //处理默认视图
    if (self.placeHolderView) {
        //如果设置了placeholder就处理，没有设置则不处理
        [self addPlaceHolderViewIsForced:NO];
    }

}

- (void)addPlaceHolderViewIsForced:(BOOL)isForced{
    
    //分为强制模式和自动模式
    if (isForced) {
//        self.backgroundView = 
        //强制模式
        //强制模式下暂未开始写，思路也不太清楚
    }else{
        //
        if ([self cc_itemsCount]<=0) {
            //添加
            //为了显示的美观，需要先把之前的separatorStyle记录下来再把cell之间的线去掉。
            self.oldSeparatorStyle = [NSNumber numberWithInteger:self.separatorStyle];
            self.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.placeHolderView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2-32);
            UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
//            backView.backgroundColor = [UIColor redColor];
            [backView addSubview:self.placeHolderView];
            [self addSubview:backView];
        }else{
            //移除
            //恢复之前的separatorStyle
            self.separatorStyle = (UITableViewCellSeparatorStyle)[self.oldSeparatorStyle integerValue];

            [self.placeHolderView removeFromSuperview];
        }
    }
}

- (void)setCustomPlaceHolderView:(UIView *)view{
    [self setPlaceHolderView:view];
    [self reloadData];
}
//强制模式
- (void)setForcePlaceHolderView:(UIView *)view{
    [self setPlaceHolderView:view];
    if (self.placeHolderView) {
        //如果设置了placeholder就处理，没有设置则不处理
        [self addPlaceHolderViewIsForced:YES];
    }
}

#pragma mark - 计算items
//tableview或者collectionView的cell and item的个数,不过现在未提供collection的placeHolder
- (NSInteger)cc_itemsCount
{
    NSInteger items = 0;
    
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    // UITableView support
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    // UICollectionView support
    else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    return items;
}




#pragma mark - 供测试时使用
//快捷模块。默认视图，供自己使用.
- (void)networkBadPlaceHolder{
    UIView *networkBadView = [UIView new];
    networkBadView.frame = CGRectMake(0, 0, 200, 200);
    
    UIImageView *badNetworkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    badNetworkImage.image = [UIImage imageNamed:@"placeholder_remote"];
    badNetworkImage.center = CGPointMake(100, 60);
    [networkBadView addSubview:badNetworkImage];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    loadingLabel.textColor = [UIColor lightGrayColor];
    loadingLabel.font = [UIFont systemFontOfSize:14.0f];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"请检查您的网络是否通畅";
    loadingLabel.center = CGPointMake(100, 130);
    [networkBadView addSubview:loadingLabel];
    
    //...dosomething
    [self setPlaceHolderView:networkBadView];
    [self reloadData];
}
//无数据
- (void)emptyDataPlaceHolder{
    UIView *emptyDataView = [UIView new];
    emptyDataView.frame = CGRectMake(0, 0, 200, 200);
    
    UIImageView *badNetworkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    badNetworkImage.image = [UIImage imageNamed:@"placeholder_instagram"];
    badNetworkImage.center = CGPointMake(100, 60);
    [emptyDataView addSubview:badNetworkImage];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    loadingLabel.textColor = [UIColor lightGrayColor];
    loadingLabel.font = [UIFont systemFontOfSize:14.0f];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"没有更多数据哦～";
    loadingLabel.center = CGPointMake(100, 130);
    [emptyDataView addSubview:loadingLabel];
    
    //...dosomething
    [self setPlaceHolderView:emptyDataView];
    [self reloadData];
}
//加载
- (void)loadingPlaceHolder{
    UIView *loadingView = [UIView new];
    
    loadingView.frame = CGRectMake(0, 0, 100, 100);
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(50, 30);
    [activityView startAnimating];
    [loadingView addSubview:activityView];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    loadingLabel.textColor = [UIColor lightGrayColor];
    loadingLabel.font = [UIFont systemFontOfSize:14.0f];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"正在加载...";
    loadingLabel.center = CGPointMake(50, 65);
    [loadingView addSubview:loadingLabel];
    
    //...dosomething
    [self setPlaceHolderView:loadingView];
    [self reloadData];
}

@end
