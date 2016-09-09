//
//  FavoritesTableViewController.h
//  Talk
//
//  Created by Suric on 15/6/1.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTag.h"

typedef enum : NSUInteger {
    JLCategoryTypeFavourite,
    JLCategoryTypeTag,
    JLCategoryTypeAt,
} JLCategoryType;

@interface FavoritesTableViewController : UITableViewController

@property (assign, nonatomic) JLCategoryType type;
@property (strong, nonatomic) TBTag *tag;

@end
