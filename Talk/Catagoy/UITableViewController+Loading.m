//
//  UITableViewController+Loading.m
//  Talk
//
//  Created by Suric on 15/11/27.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "UITableViewController+Loading.h"
#import "SVProgressHUD.h"

@implementation UITableViewController (Loading)

- (void)startLoading {
    [SVProgressHUD showWithStatus:@""];
}

- (void)stopLoading {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}


@end
