//
//  MemberGroupDataSource.h
//  Talk
//
//  Created by 王卫 on 15/12/23.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommonTableViewDataSourceProtocol.h"

@interface MemberGroupDataSource : NSObject<UITableViewDataSource, UISearchResultsUpdating, CommonTableViewDataSourceProtocol>

@property (assign, nonatomic) BOOL isSearching;
@property (weak, nonatomic) id<CommonTableViewDataSourceSearchDelegate> delegate;

@end
