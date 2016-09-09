//
//  ZXLRefreshViewController.m
//
//  Created by zhangxiaolian on 14-11-2.
//  Copyright (c) 2014年 zhangxiaolian. All rights reserved.
//

#import "TBRefreshViewController.h"

@interface TBRefreshViewController ()

@end

@implementation TBRefreshViewController

#define DEFAULT_HEIGHT_OFFSET  44

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _canLoadMore = YES;
    _canLoadNewest = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCanLoadMore:(BOOL)canLoadMore {
    _canLoadMore = canLoadMore;
    if (![self.tableView.tableHeaderView isKindOfClass:[TBFooterView class]]) {
        return;
    }
    TBFooterView*temp = (TBFooterView*)self.tableView.tableHeaderView;
    if (!_canLoadMore) {
        temp.dotsView.hidden = YES;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [temp.dotsView stopAnimating];
        });
        temp.dotsView.hidden = YES;
    }
}

- (void)setCanLoadNewest:(BOOL)canLoadNewest {
    _canLoadNewest = canLoadNewest;
    if (![self.tableView.tableFooterView isKindOfClass:[TBFooterView class]]) {
        return;
    }
    TBFooterView*temp = (TBFooterView*)self.tableView.tableFooterView;
    if (!_canLoadNewest) {
        temp.dotsView.hidden = YES;
        self.tableView.tableFooterView = nil;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [temp.dotsView stopAnimating];
        });
        temp.dotsView.hidden = YES;
    }
}


#pragma mark - Load More

- (void)setLoadingFooterView:(TBFooterView *)loadingFooterView {
    if (!self.tableView)
        return;
    if (loadingFooterView) {
        loadingFooterView.dotsView.hidden = YES;
        self.tableView.tableFooterView = loadingFooterView;
    }
}

- (void)setLoadingHeaderView:(TBFooterView *)loadingHeaderView {
    if (!self.tableView)
        return;
    if (loadingHeaderView) {
        loadingHeaderView.dotsView.hidden = YES;
        self.tableView.tableHeaderView = loadingHeaderView;
    }
}

- (void)scrollToTop {
}

- (void)willBeginLoadingMore {
    TBFooterView*temp = (TBFooterView *)self.tableView.tableHeaderView;
    if ([temp isKindOfClass:[TBFooterView class]]) {
        temp.dotsView.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [temp.dotsView startAnimating];
        });
    }
}

- (void)willBeginLoadingNewest {
    TBFooterView*temp = (TBFooterView *)self.tableView.tableFooterView;
    if ([temp isKindOfClass:[TBFooterView class]]) {
        temp.dotsView.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [temp.dotsView startAnimating];
        });
    }
}

- (void)loadMoreCompleted {
    TBFooterView*temp = (TBFooterView*)self.tableView.tableHeaderView;
    isLoadingMore = NO;
    if ([temp isKindOfClass:[TBFooterView class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            temp.dotsView.hidden = YES;
            [temp.dotsView stopAnimating];
        });
    }
}

- (void)loadNewestCompleted {
    TBFooterView*temp = (TBFooterView*)self.tableView.tableFooterView;
    isLoadingMewest = NO;
    if ([temp isKindOfClass:[TBFooterView class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            temp.dotsView.hidden = YES;
            [temp.dotsView stopAnimating];
        });
    }
}


- (BOOL)loadMore {
    if (isLoadingMore)
        return NO;
    
    [self willBeginLoadingMore];
    isLoadingMore = YES;
    return YES;
}

- (BOOL)loadNewest {
    if (isLoadingMewest)
        return NO;
    
    [self willBeginLoadingNewest];
    isLoadingMewest = YES;
    return YES;
}

- (CGFloat) footerLoadMoreHeight {
    if (_loadingFooterView)
        return _loadingFooterView.frame.size.height;
    else
        return DEFAULT_HEIGHT_OFFSET;
}

- (void) setFooterViewVisibility:(BOOL)visible {
    if (visible && self.tableView.tableFooterView != _loadingFooterView)
        self.tableView.tableFooterView = _loadingFooterView;
    else if (!visible)
        self.tableView.tableFooterView = nil;
}


#pragma mark -

- (void) allLoadingCompleted {
    if (isLoadingMore)
        [self loadMoreCompleted];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isRefreshing)
        return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //scroll to bottom
    CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
    //DDLogDebug(@"scrollPosition:%f",scrollPosition);
    if (scrollPosition == 0) {
        [self scrollToTop];
    }
    if (!scrollView.isDragging) {
        return;
    }
    
    //load newest
    if (!self.canLoadNewest) {
        [self setCanLoadNewest:NO];
        //load more
        if (!self.canLoadMore) {
            [self setCanLoadMore:NO];
            return;
        }
        if (!isLoadingMore && _canLoadMore) {
            CGFloat scrollPosition = scrollView.contentOffset.y;
            if (scrollPosition != 0 && scrollPosition < [self footerLoadMoreHeight]) {
                [self loadMore];
            }
        }
        return;
    }
    if (!isLoadingMewest && _canLoadNewest) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < [self footerLoadMoreHeight] ) {
            [self loadNewest];
        }
    }
    
    //load more
    if (!self.canLoadMore) {
        [self setCanLoadMore:NO];
        return;
    }
    if (!isLoadingMore && _canLoadMore) {
        CGFloat scrollPosition = scrollView.contentOffset.y;
        if (scrollPosition != 0 && scrollPosition < [self footerLoadMoreHeight]) {
            [self loadMore];
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
