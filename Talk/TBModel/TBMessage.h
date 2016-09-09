//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBModelObject.h"
#import "TBContentViewDefine.h"
#import "TBUser.h"
#import "TBStory.h"

@interface TBMessage : TBModelObject

@property (nonatomic, copy) NSString * body;
@property (nonatomic, copy) NSString * creatorID;
@property (nonatomic, copy) NSString * storyID;
@property (nonatomic, copy) NSString * roomID;
@property (nonatomic, copy) NSString * teamID;
@property (nonatomic, copy) NSString * toID;
@property (nonatomic, copy) NSString * displayMode;
@property (nonatomic, copy) NSString * authorName;
@property (nonatomic, copy) NSURL * authorAvatarUrl;
@property (nonatomic) BOOL isSystem;
@property (nonatomic) BOOL isUnread;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSDictionary*highlight;
@property (nonatomic, strong) TBUser *creator;
@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) NSArray *mentions;
@property (nonatomic, strong) NSArray *receiptors;
@property (nonatomic, strong) TBStory *story;

@property (copy, nonatomic) NSString *messageStr;
@property (copy, nonatomic) NSString *captureImageUrlStr;
@property (assign, nonatomic) MessageSendStatus  sendStatus;
@property (nonatomic, assign) BOOL isSend;
@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) NSInteger numbersOfRows;

// just for send  Message
@property (assign, nonatomic) CGFloat sendImageWidth;
@property (assign, nonatomic) CGFloat sendImageHeight;
@property (copy, nonatomic) NSString *uuid;
@property (strong, nonatomic) UIImage* sendImage;
@property (copy, nonatomic)   NSString *sendImageCategory;

//for voice
@property (assign, nonatomic) CGFloat duration;
@property (copy, nonatomic)  NSString *voiceLocalAMRPath;

//for search/favorite/messageShelf
@property (assign, nonatomic) CGFloat searchCellHeight;
@property (copy, nonatomic) NSString *originMessageId;

@end