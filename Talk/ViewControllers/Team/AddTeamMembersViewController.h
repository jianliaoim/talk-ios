//
// Created by Shire on 10/16/14.
// Copyright (c) 2014 jiaoliao. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "APTokenField.h"
#import "TBTeam.h"

@interface AddTeamMembersViewController : UIViewController <APTokenFieldDataSource, APTokenFieldDelegate>

@property(nonatomic, strong) APTokenField *tokenField;
@property(nonatomic, strong) NSArray *contacts;
@property(nonatomic, strong) NSArray *filteredContacts;
@property(nonatomic, copy) NSString * boundToObjectType;
@property(nonatomic, copy) NSString * boundToObjectId;
@property(nonatomic, strong) TBTeam *creatingTeam; //use for create new team

- (IBAction)submit:(id)sender;

@end