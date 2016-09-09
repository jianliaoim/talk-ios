//
//  FilesTableViewController.h
//  Talk
//
//  Created by 史丹青 on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBItemsTableViewController.h"

@interface FilesTableViewController : TBItemsTableViewController

@property (strong, nonatomic) NSMutableArray *photos;
@property (nonatomic) NSInteger photosTotal;

@end
