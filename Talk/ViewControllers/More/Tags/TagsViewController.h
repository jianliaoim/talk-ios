//
//  TagsViewController.h
//  Talk
//
//  Created by 史丹青 on 7/13/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsViewModel.h"

@interface TagsViewController : UITableViewController

@property (nonatomic, strong) TagsViewModel *viewModel;
@property (nonatomic, weak) IBOutlet UITableView *tagTableView;

@end
