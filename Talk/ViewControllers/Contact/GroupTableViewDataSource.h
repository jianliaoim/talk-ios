//
//  GroupTableViewController.h
//  Talk
//
//  Created by 王卫 on 15/11/5.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommonTableViewDataSourceProtocol.h"

@interface GroupTableViewDataSource : NSObject <UITableViewDataSource, UISearchResultsUpdating, CommonTableViewDataSourceProtocol>

@property (assign, nonatomic) BOOL isSearching;
@property (weak, nonatomic) id<CommonTableViewDataSourceSearchDelegate> delegate;

@end
