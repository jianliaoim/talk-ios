//
//  PhoneContactViewController.h
//  Talk
//
//  Created by 史丹青 on 6/24/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Talk-Swift.h"

@interface PhoneContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, RemindViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (strong, nonatomic) NSString *currentTeamId;
@end
