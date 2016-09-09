//
//  TBNavigationController.m
//  Talk
//
//  Created by Suric on 15/12/3.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "TBNavigationController.h"

@implementation TBNavigationController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    return self.customPreviewActionItems;
}

@end
