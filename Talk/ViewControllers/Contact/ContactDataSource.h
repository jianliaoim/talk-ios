//
//  ContactDataSource.h
//  Talk
//
//  Created by 王卫 on 15/11/4.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommonTableViewDataSourceProtocol.h"

@interface ContactDataSource : NSObject <UITableViewDataSource, UISearchResultsUpdating, CommonTableViewDataSourceProtocol>

@property (assign, nonatomic) BOOL isSearching;
@property (weak, nonatomic) id<CommonTableViewDataSourceSearchDelegate> delegate;

@end
