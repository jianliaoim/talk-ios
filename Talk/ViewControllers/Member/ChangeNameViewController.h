//
//  ChangeNameViewController.h
//  Talk
//
//  Created by Shire on 9/29/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeNameViewController : UITableViewController

@property (nonatomic, copy) NSString *name;
@property (nonatomic) BOOL isEditTeamName;
@property (nonatomic) BOOL isEditEmail;
@property (nonatomic) BOOL isEditAlias;

@property (nonatomic) BOOL isEditTag;
@property (nonatomic, copy) NSString *tagId;

@end
