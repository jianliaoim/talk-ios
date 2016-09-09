//
//  TBButton.h
//  Talk
//
//  Created by Suric on 15/3/30.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBButton : UIButton

@property (strong, nonatomic) UIActivityIndicatorView *loadingView;
@property (strong, nonatomic) NSIndexPath *indexPath;
- (void)startLoading;
- (void)stopLoading;

@end
