//
//  CallingViewController.h
//  Talk
//
//  Created by 史丹青 on 9/24/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MOUser;

@interface CallingViewController : UIViewController

- (void)callUser:(MOUser *)user;
- (void)callGroup:(NSArray *)userArray;

@end
