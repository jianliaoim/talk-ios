//
//  BaseSearchController.h
//  Talk
//
//  Created by Suric on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBSearchBar.h"

@interface BaseSearchController : UITableViewController

@property (weak, nonatomic) IBOutlet TBSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic)  UIButton *customTeamButton;
@property (strong, nonatomic) UIButton *rightItemBtn;
@property (strong, nonatomic) UIButton *rightClickRegion;
@property (strong, nonatomic) UIButton *callItemBtn;
@property (strong, nonatomic) UIButton *callClickRegion;

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)updateOtherTeamUnread;
- (void)setNavigationBar;
- (void)failedFetchRemoteData;
- (void)renderNavigationBar;

@end
