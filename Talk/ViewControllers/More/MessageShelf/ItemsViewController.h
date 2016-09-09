//
//  ItemsViewController.h
//  Talk
//
//  Created by 史丹青 on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemsViewController : UIViewController
@property (strong, nonatomic) NSDictionary *filterDictionary;
@property (weak, nonatomic) IBOutlet UILabel *filterNameLabel;

@end
