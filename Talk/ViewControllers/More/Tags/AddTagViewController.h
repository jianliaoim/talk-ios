//
//  AddTagViewController.h
//  Talk
//
//  Created by 史丹青 on 7/13/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTagViewModel.h"
#import "VENTokenField.h"

@interface AddTagViewController : UIViewController <VENTokenFieldDelegate, VENTokenFieldDataSource, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AddTagViewModel *viewModel;

@property (nonatomic, weak) IBOutlet VENTokenField *tagField;
@property (nonatomic, weak) IBOutlet UITableView *tagTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tokenFieldHeightConstraint;

@end
