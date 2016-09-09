//
//  TBContentViewFactory.h
//  Talk
//
//  Created by Suric on 14/10/11.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ChatMessageOriginType) {
    ChatMessageOriginTypeSend = 0,
    ChatMessageOriginTypeReceived
};

typedef NS_ENUM(NSInteger, ChatMessageMediaType) {
     ChatMessageMediaTypeText = 0,
     ChatMessageMediaTypeFile = 1,
     ChatMessageMediaTypeImage = 2,
     ChatMessageMediaTypeHyperText = 3,
     ChatMessageMediaTypeSystem= 4,
     ChatMessageMediaTypeQuote = 5,
     ChatMessageMediaTypeWeibo = 6,
     ChatMessageMediaTypeGithub = 7,
     ChatMessageMediaTypeVoice= 8,
};

typedef NS_ENUM(NSUInteger, MessageSendStatus) {
    sendStatusSucceed,
    sendStatusSending,
    sendStatusFailed,
    sendStatusRecording,
};

@interface TBContentViewDefine : NSObject

@end