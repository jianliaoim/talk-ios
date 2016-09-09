//
//  JLSharingTableViewController.h
//  Talk
//
//  Created by 王卫 on 15/11/25.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLShareViewController.h"

@interface JLSharingTableViewController : UITableViewController

@property (weak, nonatomic) id<JLShareExtensionDelegate> delegate;

@end
