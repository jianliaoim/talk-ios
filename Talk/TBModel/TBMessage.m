//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBMessage.h"
#import "ArrayToDataTransformer.h"
#import "TBFile.h"
#import "TBQuote.h"
#import "TBUser.h"
#import "DictionaryToDataTransformer.h"
#import "TBAttachment.h"
#import "TBUtility.h"
#import "TBSystemMessageCell.h"
#import "TbChatTableViewCell.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@implementation TBMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    _messageStr = [TBUtility parseTBMessageContentWithTBMessage:self.body];
    _sendStatus = sendStatusSucceed;
    
    NSString *currentUserID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
    _isSend = [self.creatorID isEqualToString:currentUserID];
    
    TBAttachment *attachment = self.attachments.firstObject;
    NSString *quoteText = attachment.data[kQuoteText];
    if (quoteText) {
        if ([attachment.category isEqualToString:kDisplayModeRtf]) {
            _captureImageUrlStr = [TBUtility getFirstImageURLStrFromHTMLString:quoteText];
        }
    }
    
    for (TBAttachment *attachment in self.attachments) {
        attachment.cellHeight = [TBUtility getCellHeightWithAttachment:attachment forModel:self];
    }
    
    if (self.isSystem) {
        _cellHeight = [TBSystemMessageCell calculateCellHeightWithMessage:self];
    } else {
        _cellHeight = [TbChatTableViewCell calculateCellHeightWithMessage:self];
    }
    
    _numbersOfRows = [TBUtility numberofRowsWithMessageModel:self];

    return self;
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
            @"toID" : @"_toId",
            @"creatorID" : @"_creatorId",
            @"storyID" : @"_storyId",
            @"roomID" : @"_roomId",
            @"teamID" : @"_teamId",
            @"attachments" : @"attachments",
    }];
    return dictionary;
}

+ (NSValueTransformer *)authorAvatarUrlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)creatorJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *userDictionary) {
        TBUser *originUSer = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:[MOUser findFirstWithId:userDictionary[@"id"]] error:NULL];
        if (originUSer) {
            return originUSer;
        } else {
            TBUser *newUSer = [MTLJSONAdapter modelOfClass:[TBUser class] fromJSONDictionary:userDictionary error:NULL];
            return newUSer;
        }
    }];
}

+ (NSValueTransformer *)attachmentsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[TBAttachment class]];
}

+ (NSValueTransformer *)storyJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[TBStory class]];
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Message";
}

+(NSDictionary *)relationshipModelClassesByPropertyKey{
    return @{
            @"creator" : [TBUser class],
            @"attachments" : [TBAttachment class],
            @"story":[TBStory class]
    };
}

#pragma mark - Entity Transformer

+ (NSValueTransformer *)authorAvatarUrlEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

@end