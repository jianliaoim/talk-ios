//
//  TBItemsTableViewController.h
//  Talk
//
//  Created by 史丹青 on 8/10/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceHolderView.h"
#import "MWPhotoBrowser.h"
#import "TBSearchQuoteCell.h"

static NSString *QuoteCellIdentifier = @"TBSearchQuoteCell";

@interface TBItemsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (nonatomic) NSInteger messagesTotal;
@property (nonatomic) int pageNumber;
@property (strong, nonatomic) NSDictionary *filterDictionary;
@property (strong, nonatomic) PlaceHolderView *noItemsplaceHolder;

- (void)setMJRefresh;
- (void)syncData;
- (void)processResponseData:(NSDictionary *)responseObject;
- (void)filterDataWith:(NSDictionary *)newFilterDictionary;
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer;

- (void)favoriteMessageWithID:(NSString *)messageID;
- (void)addTagWithID:(NSString *)messageID withArray:(NSArray *)tags;
- (void)forwardMessageWithMessageIdArray:(NSArray *)messageIdArray;
- (void)deleteMessageWithMessageID:(NSString *)deletedMessageID andPhotoBrowser:(MWPhotoBrowser *)browser;

@end
