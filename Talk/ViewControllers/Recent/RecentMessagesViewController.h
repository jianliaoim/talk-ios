//
//  RecentMessagesViewController.h
//  Talk
//
//  Created by Shire on 10/22/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSearchController.h"

@interface RecentMessagesViewController : BaseSearchController

- (void)popChatViewController;
- (void)enterChatWithRoom:(MORoom *)selectedMORoom;
- (void)enterChatWithMember:(MOUser *)tempMOUser;
- (void)enterChatWithStory:(MOStory *)selectedMOStory;

@end
