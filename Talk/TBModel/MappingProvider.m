//
//  MappingProvider.m
//
//  Created by Suric on 14/10/11.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "MappingProvider.h"
#import <FEMManagedObjectMapping.h>
#import "TBModelObject.h"
#import "constants.h"

@implementation MappingProvider

+ (FEMMapping *)roomMapping {
    FEMMapping *mapping = [[FEMMapping alloc] initWithEntityName:@"Room"];
    [mapping setPrimaryKey:@"id"];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"createdAt" toKeyPath:@"createdAt" dateFormat:kDefaultDateFormatString]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"updatedAt" toKeyPath:@"updatedAt" dateFormat:kDefaultDateFormatString]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"pinnedAt" toKeyPath:@"pinnedAt" dateFormat:kDefaultDateFormatString]];
    [mapping addAttributesFromDictionary:@{@"creatorID" : @"_creatorId",
                                           @"teamID" : @"_teamId",
                                           @"isMute" : @"prefs.isMute"
                                           }];
    [mapping addAttributesFromArray:@[@"id",@"purpose",@"topic",@"isQuit",@"isArchived",@"isGeneral",@"isPrivate",@"unread",@"color"]];
    
    return mapping;
}

+ (FEMMapping *)userMapping {
    FEMMapping *mapping = [[FEMMapping alloc] initWithEntityName:@"User"];
    [mapping setPrimaryKey:@"userID"];
    
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"userID" toKeyPath:@"id" map:^id(id value) {
        NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
        return [currentTeamID stringByAppendingString:value];
    }]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"createdAt" toKeyPath:@"createdAt" dateFormat:kDefaultDateFormatString]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"updatedAt" toKeyPath:@"updatedAt" dateFormat:kDefaultDateFormatString]];
    
    [mapping addAttributesFromDictionary:@{@"avatarURL" : @"avatarUrl",
                                           @"isMute" : @"prefs.isMute",
                                           @"alias" : @"prefs.alias",
                                           @"hideMobile": @"prefs.hideMobile",
                                           }];
    [mapping addAttributesFromArray:@[@"id",@"name",@"pinyin",@"email",@"sourceId",@"isRobot",@"service",@"mobile",@"phoneForLogin",@"role",@"unread",@"isQuit",@"isGuest"]];

    return mapping;
}

+ (FEMMapping *)recentMessageMapping {
    FEMMapping *mapping = [[FEMMapping alloc] initWithEntityName:@"RecentMessage"];
    [mapping setPrimaryKey:@"id"];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"createdAt" toKeyPath:@"createdAt" dateFormat:kDefaultDateFormatString]];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"updatedAt" toKeyPath:@"updatedAt" dateFormat:kDefaultDateFormatString]];
    [mapping addAttributesFromDictionary:@{@"toID" : @"_toId",
                                           @"creatorID" : @"_creatorId",
                                           @"roomID" : @"_roomId",
                                           @"teamID" : @"_teamId"}];
    [mapping addAttributesFromArray:@[@"id",@"text",@"isSystem",@"displayMode",@"sendStatus",@"body"]];
    [mapping addRelationshipMapping:[self userMapping] forProperty:@"creator" keyPath:@"creator"];
    [mapping addRelationshipMapping:[self quoteMapping] forProperty:@"quote" keyPath:@"quote"];
    [mapping addToManyRelationshipMapping:[self attachmentMapping] forProperty:@"attachments" keyPath:@"attachments"];

    return mapping;
}

+ (FEMMapping *)quoteMapping {
    FEMMapping *mapping = [[FEMMapping alloc] initWithEntityName:@"Quote"];
    [mapping addAttributesFromDictionary:@{@"redirectURL" : @"redirectUrl",
                                           @"userAvatarURL": @"userAvatarUrl",
                                           @"authorAvatarURL" : @"authorAvatarUrl",
                                           @"thumbnailPicURL": @"thumbnailPicUrl"}];
    
    [mapping addAttributesFromArray:@[@"authorName",@"category",@"openId",@"text",@"title",@"userName"]];

    return mapping;
}
+ (FEMMapping *)attachmentMapping {
    FEMMapping *mapping = [[FEMMapping alloc] initWithEntityName:@"Attachment"];
    [mapping addAttribute:[FEMAttribute mappingOfProperty:@"data" toKeyPath:@"data" map:^id(id value) {
        //Take an NSDictionary archive to NSData
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
        return data;
    } reverseMap:^id(id value) {
        //Take NSData unarchive to NSDictionary
        NSDictionary *dictionary = (NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:value];
        return dictionary;
    }]];
    [mapping addAttributesFromArray:@[@"id",@"category"]];

    return mapping;
}
@end
