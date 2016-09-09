//
//  SelectCountryToInputMobileNumberViewController.h
//  Teambition
//
//  Created by hongxin on 15/6/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBCountry.h"

@protocol SelectCountryCodeDelegate

- (void)selectedCountry:(TBCountry *)selectedCountry;

@end

@interface SelectCountryToInputMobileNumberViewController : UITableViewController

@property (nonatomic) id<SelectCountryCodeDelegate> delegate;
@property (nonatomic) TBCountry *selectedCountry;
@property BOOL isLinkPhone;

@end
