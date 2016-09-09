//
//  TBQuote.h
//  Talk
//
//  Created by teambition-ios on 14/11/18.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBQuote : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>
@property (nonatomic, copy) NSString* authorName;
@property (nonatomic, copy) NSURL* authorAvatarURL;
@property (nonatomic, copy) NSString* category;
@property (nonatomic, copy) NSString* openId;
@property (nonatomic, copy) NSURL* redirectURL;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSURL* userAvatarURL;
@property (nonatomic, copy) NSURL* thumbnailPicURL;
@property (nonatomic, copy) NSString* userName;
@end
