//
//  JLSharePoster.h
//  Talk
//
//  Created by 王卫 on 15/11/27.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLShareViewController.h"

@interface JLSharePoster : NSObject

@property (strong, nonatomic) NSString *selectedRoomId;
@property (strong, nonatomic) NSString *selectedMemberId;
@property (strong, nonatomic) NSString *selectedTeamId;

@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) NSData *fileData;
@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) BOOL isImage;
@property (strong, nonatomic) NSString *link;

@property (assign, nonatomic) BOOL isCreateStory;
@property (strong, nonatomic) NSArray *memberIds;
@property (weak, nonatomic) id<JLShareExtensionDelegate> delegate;

+ (instancetype)sharedPoster;
- (void)sendTextMessageToServer:(NSString *)messageText;
- (void)sendImageDataToStriker: (NSData *)imageData andName: (NSString *)imageName isImage:(BOOL)isImage;
- (void)sendImageInfoToServerWith:(NSDictionary *)imageDic andIsImage:(BOOL)isImage;
- (void)createStoryWithLink:(NSString *)link title:(NSString *)title;
- (void)createStoryWithIdea:(NSString *)idea;

@end
