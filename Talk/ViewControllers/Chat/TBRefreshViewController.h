//
//  ZXLRefreshViewController.h
//
//  Created by zhangxiaolian on 14-11-2.
//  Copyright (c) 2014年 zhangxiaolian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBFooterView.h"
@class JLLoadingTableView;
@class TBFooterView;

@interface TBRefreshViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
 @protected
     BOOL isDragging;
     BOOL isRefreshing;
     BOOL isLoadingMore;
     BOOL isLoadingMewest;
}
@property (weak, nonatomic) IBOutlet JLLoadingTableView *tableView;
@property (nonatomic, strong) TBFooterView *loadingFooterView;       // The view used for "load more"
@property (nonatomic, strong) TBFooterView *loadingHeaderView;       // The view used for "load newest"
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) BOOL canLoadNewest;
// Defaults to YES
@property (nonatomic) BOOL clearsSelectionOnViewWillAppear;

#pragma mark - Load More

// The value of the height starting from the bottom that the user needs to scroll down to in order
// to trigger -loadMore. By default, this will be the height of -footerView.
- (CGFloat)footerLoadMoreHeight;

// Override to perform fetching of next page of data. It's important to call and get the value of
// of [super loadMore] first. If it's NO, -loadMore should be aborted.
- (BOOL)loadMore;

// Called when all the conditions are met and -loadMore will begin.
- (void)willBeginLoadingMore;

// Call to signal that "load more" was completed. This should be called so -isLoadingMore is
// properly set to NO.
- (void)loadMoreCompleted;

// Helper to show/hide -footerView
- (void)setFooterViewVisibility:(BOOL)visible;

#pragma mark - Load Newest

//load newest
- (BOOL)loadNewest;
- (void)loadNewestCompleted;

#pragma mark -

// A helper method that calls refreshCompleted and/or loadMoreCompleted if any are active.
- (void)allLoadingCompleted;
- (void)setLoadingFooterView:(TBFooterView *)loadingFooterView;

#pragma mark - scoll To Top
- (void)scrollToTop;

@end
