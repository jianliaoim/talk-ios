//
//  CommonTableViewDataSourceProtocol.h
//  Talk
//
//  Created by 王卫 on 15/11/5.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommonTableViewDataSourceSearchDelegate <NSObject>

- (void)didUpdateSearchResults;

@end

@protocol CommonTableViewDataSourceProtocol <NSObject>

@required
@property (assign, nonatomic) BOOL isSearching;
@property (weak, nonatomic) id<CommonTableViewDataSourceSearchDelegate> delegate;

- (void)refreshData;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
