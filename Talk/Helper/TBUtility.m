//
//  TBUtility.m
//  Talk
//
//  Created by teambition-ios on 14/10/23.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBUtility.h"
#import "NSString+Emoji.h"
#import "constants.h"
#import <hpple/TFHpple.h>
#import "MOUser.h"
#import "TBUser.h"
#import "MOHidenMessage.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <CoreText/CoreText.h>
#import "NSDate+TBUtilities.h"

#import "TbChatTableViewCell.h"
#import "TBFileTableViewCell.h"
#import "TBImageTableViewCell.h"
#import "TBSystemMessageCell.h"
#import "TBQuoteTableViewCell.h"
#import "TBWeiboCell.h"
#import "TBAttachementMessageCell.h"

#import "Hanzi2Pinyin.h"
#import "TBVoiceCell.h"
#import "MOMessage.h"
#import "AFNetworking.h"
#import "TBMessage.h"
#import "NSString+Emoji.h"

#import "SVProgressHUD/SVProgressHUD.h"
#import <SSKeychain/SSKeychain.h>
#import <Mixpanel/Mixpanel.h>

static const CGFloat kUnknownAttachmentCellHeight = 46;
static NSString *const kDeviceUUID = @"DeviceUUID";

@implementation TBUtility

#pragma mark - DeviceUUID

+ (NSString *)deviceUUID {
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *applicationUUID = [SSKeychain passwordForService:appName account:kDeviceUUID];
    if (applicationUUID == nil) {
        applicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:applicationUUID forService:appName account:kDeviceUUID];
    }
    NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    [groupDeafaults setObject:applicationUUID forKey:kDeviceUUID];
    [groupDeafaults synchronize];
    
    return applicationUUID;
}

#pragma mark - AppDelegate

//current Appdelegate
+(AppDelegate *)currentAppDelegate {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate;
}

+ (UIWindow *)applicationTopView {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    UIScreen *mainScreen = UIScreen.mainScreen;
    UIWindow *currentWindow;
    for (UIWindow *window in frontToBackWindows)
        if (window.screen == mainScreen && window.windowLevel == UIWindowLevelNormal) {
            currentWindow = window;
            break;
        }
    
    return currentWindow;
}

#pragma mark - deal Message Content Related

+(NSString *)getDefaultInfoWithKey:(NSString *)key {
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"info-created-task", nil),@"info-created-task",
                            NSLocalizedString(@"info-created-file", nil),@"info-created-file",
                            NSLocalizedString(@"info-created-snippet", nil),@"info-created-snippet",
                            
                            NSLocalizedString(@"info-create-story", nil),@"info-create-story",
                            NSLocalizedString(@"info-update-story", nil),@"info-update-story",
                            
                            NSLocalizedString(@"info-pin-notification", nil),@"info-pin-notification",
                            NSLocalizedString(@"info-unpin-notification", nil),@"info-unpin-notification",
                            NSLocalizedString(@"info-invite-members", nil),@"info-invite-members",
                            NSLocalizedString(@"info-remove-members", nil),@"info-remove-members",
                            NSLocalizedString(@"info-leave-story", nil),@"info-leave-story",
                            NSLocalizedString(@"info-remove-message", nil),@"info-remove-message",
                            NSLocalizedString(@"info-upload-files", nil),@"info-upload-files",
                            NSLocalizedString(@"info-new-speech", nil),@"info-new-speech",
                            NSLocalizedString(@"info-invite-you", nil),@"info-invite-you",
                            
                            NSLocalizedString(@"info-update-purpose", nil),@"info-update-purpose",
                            NSLocalizedString(@"info-update-topic", nil),@"info-update-topic",
                            
                            NSLocalizedString(@"info-create-room", nil),@"info-create-room",
                            NSLocalizedString(@"info-join-room", nil),@"info-join-room",
                            NSLocalizedString(@"info-leave-room", nil),@"info-leave-room",
                            
                            NSLocalizedString(@"info-join-team", nil),@"info-join-team",
                            NSLocalizedString(@"info-leave-team", nil),@"info-leave-team",
                            NSLocalizedString(@"info-rss-new-item", nil),@"info-rss-new-item",
                            NSLocalizedString(@"info-new-mail-message", nil),@"info-new-mail-message",
                            
                            NSLocalizedString(@"info-weibo-new-mention", nil),@"info-weibo-new-mention",
                            NSLocalizedString(@"info-weibo-new-comment", nil),@"info-weibo-new-comment",
                            NSLocalizedString(@"info-weibo-new-repost", nil),@"info-weibo-new-repost",
                            NSLocalizedString(@"info-github-new-event", nil),@"info-github-new-event",
                            NSLocalizedString(@"info-create-integration", nil),@"info-create-integration",
                            NSLocalizedString(@"info-update-integration", nil),@"info-update-integration",
                            NSLocalizedString(@"info-remove-integration", nil),@"info-remove-integration",
                            
                            NSLocalizedString(@"info-mention", nil), @"info-mention",
                            NSLocalizedString(@"info-comment", nil),@"info-comment",
                            NSLocalizedString(@"info-repost", nil),@"info-repost",
                            NSLocalizedString(@"info-commit_comment", nil), @"info-commit_comment",
                            NSLocalizedString(@"info-create", nil),@"info-create",
                            NSLocalizedString(@"info-delete", nil),@"info-delete",
                            
                            NSLocalizedString(@"info-fork", nil), @"iinfo-fork",
                            NSLocalizedString(@"info-issue_comment", nil),@"info-issue_comment",
                            NSLocalizedString(@"info-issues", nil),@"info-issues",
                            
                            NSLocalizedString(@"info-pull_request_review_comment", nil), @"info-pull_request_review_comment",
                            NSLocalizedString(@"info-pull_request", nil),@"info-pull_request",
                            NSLocalizedString(@"info-push", nil),@"info-push",
                            
                            NSLocalizedString(@"info-merge_request", nil),@"info-merge_request",
                            NSLocalizedString(@"info-firim-message", nil),@"info-firim-message",
                            NSLocalizedString(@"info-gitlab-new-event", nil),@"info-gitlab-new-event",
                             
                            NSLocalizedString(@"info-invite-team-member", nil),@"info-invite-team-member",
                            NSLocalizedString(@"info-create-topic-story", nil),@"info-create-topic-story",
                            NSLocalizedString(@"info-create-link-story", nil),@"info-create-link-story",
                            NSLocalizedString(@"info-create-file-story", nil),@"info-create-file-story",
                            nil];
    if (infoDic[key] == nil) {
        return key;
    }
    return infoDic[key];
}

/**
 *  Relpace Regex in string
 *
 *  @param inputStr message String
 *
 *  @return string without Regex
 */
+(NSString *) getStringWithoutRegexFromString:(NSString *)inputStr {
    // such as "{{_info-join-room}}"
    inputStr = [inputStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\\{_.{1,}?\\}\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *array = nil;
    array = [regex matchesInString:inputStr options:0 range:NSMakeRange(0, [inputStr length])];
    if (array.count != 0)
    {
        __block NSString *tempReturnStr = inputStr;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSTextCheckingResult *b = array[idx];
            NSString *str1 = [inputStr substringWithRange:b.range];
            NSInteger tempLength = str1.length;
            NSString *tempDefaultStr = [TBUtility getDefaultInfoWithKey:[str1 substringWithRange:NSMakeRange(4,tempLength-6)]];
            tempReturnStr = [tempReturnStr stringByReplacingOccurrencesOfString:str1 withString:tempDefaultStr];
        }];
        return tempReturnStr;
    }
    else
    {
        return inputStr;
    }
}

/**
 *  remove html in string
 *
 *  @param inputStr  string with html
 *
 *  @return string without html
 */
+(NSString *) getStringWithoutHtmlFromString:(NSString *)inputStr {
    if ([TBUtility dealForNilWithString:inputStr].length == 0) {
        return @"";
    }
    
    NSString* resultStr;
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *array = nil;
    array = [regex matchesInString:inputStr options:0 range:NSMakeRange(0, [inputStr length])];
    if (array.count != 0)
    {
        __block NSString *tempReturnStr = inputStr;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSTextCheckingResult *b = array[idx];
            NSString *str1 = [inputStr substringWithRange:b.range];
            tempReturnStr = [tempReturnStr stringByReplacingOccurrencesOfString:str1 withString:@""];
        }];
        resultStr=tempReturnStr;
    }
    else
    {
        resultStr = inputStr;
    }
    resultStr = [resultStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    resultStr = [resultStr stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
    resultStr = [resultStr stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n"];
    resultStr = [resultStr stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    resultStr = [resultStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return resultStr;
}

+ (NSString *)getFirstImageURLStrFromHTMLString:(NSString *)htmlString {
    NSData *dataTitle=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    NSArray *elements=[xpathParser searchWithXPathQuery:@"//img"];
    
    NSString *imageURLString = nil;
    for (TFHppleElement *element in elements) {
        NSDictionary *elementContent =[element attributes];
        
        if ([[elementContent objectForKey:@"role"] isEqualToString:@"emoji"]) {
            continue;
        } else {
            imageURLString = [elementContent objectForKey:@"src"];
            break;
        }
    }
    return imageURLString;
}

+ (NSArray *)getLinkStringArrFromHtmlString:(NSString *)htmlString {
    NSData *dataTitle=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    NSMutableArray *elements=(NSMutableArray*)[xpathParser searchWithXPathQuery:@"//code"];
    [elements addObjectsFromArray:[xpathParser searchWithXPathQuery:@"//a"]];
    NSMutableArray *linkStringarray = [NSMutableArray array];
    for (TFHppleElement *element in elements) {
        if (element.text) {
            [linkStringarray addObject:element.text];
        }
    }
    return linkStringarray;
    
}

+ (NSArray *)getHightlightStringArrFromString:(NSString *)htmlString withTag:(NSString *)tag {
    NSData *dataTitle=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    NSMutableArray *elements=(NSMutableArray*)[xpathParser searchWithXPathQuery:tag];
    NSMutableArray *linkStringarray = [NSMutableArray array];
    for (TFHppleElement *element in elements) {
        if (element.text) {
            [linkStringarray addObject:element.text];
        }
    }
    return linkStringarray;
    
}

/**
 * get AttributeString From OriginString
 *
 *  @param originString origin html string
 *  @param noBrString   html string without <br>
 *
 *  @return NSMutableAttributedString
 */
+ (NSMutableAttributedString *)getAttributeStringFromOriginString:(NSString *)originString andNoBrString:(NSString *)noBrString {
    NSArray *linkStringArray = [TBUtility getLinkStringArrFromHtmlString:originString];
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    [mutableAttributes setObject:[UIFont systemFontOfSize:14.0] forKey:(NSString *)kCTFontAttributeName];
    [mutableAttributes setObject:[UIColor tb_tableHeaderGrayColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:[TBUtility dealForNilWithString:noBrString] attributes:mutableAttributes];
    for (NSString *linkString in linkStringArray) {
        [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor jl_redColor] range:[noBrString rangeOfString:linkString]];
    }
    
    return attributeString;
}

/**
 *  parse TBMessage contentArray (as
 (
 "Etta ",
 {
 id = all;
 text = "@All ";
 type = mention;
 },
 "dgggg "
 )
 *
 *  @param message TBMessage
 *
 *  @return string of the content message (as @"Etta @All dgggg")
 */

+(NSString *)parseTBMessageContentWithTBMessage:(NSString *)messageBody {
    if (!messageBody) {
        return @"";
    }
    NSString *messageContent = [self filterAtMemberFromString:messageBody];
    messageContent  = [TBUtility getStringWithoutRegexFromString:messageContent];
    messageContent = [messageContent stringByReplacingEmojiCheatCodesWithUnicode];
    return messageContent;
}

+ (NSString *)filterAtMemberFromString:(NSString *)sendmessage {
    if (!sendmessage) {
        return @"";
    }
    __block NSString *noRegularString = [NSString stringWithString:sendmessage];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<\\$(.+?)\\|(.+?)\\|(.*?)\\$>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *array = nil;
    array = [regex matchesInString:sendmessage options:0 range:NSMakeRange(0, [sendmessage length])];
    if (array.count != 0)
    {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSTextCheckingResult *b = array[idx];
            NSString *regularStr = [sendmessage substringWithRange:b.range];
            NSString *resultStr = [regularStr substringWithRange:NSMakeRange(2, regularStr.length - 4)];
            NSArray *atArray = [resultStr componentsSeparatedByString:@"|"];
            NSString *atString = [atArray objectAtIndex:2];
            noRegularString = [noRegularString stringByReplacingOccurrencesOfString:regularStr withString:atString];
        }];
        return noRegularString;
    } else {
        return sendmessage;
    }
}

/**
 *  convert Bytes to KB,MB,GB,TB
 *
 *  @param size sizeunsigned long long
 *
 *  @return like 1.2KB or 3.5MB
 */
+ (NSString *)convertBytes:(unsigned long long)size {
    NSString *formattedStr = nil;
    if (size == 0)
        formattedStr = @"Empty";
    else if (size > 0 && size < pow(1024, 2))
        formattedStr = [NSString stringWithFormat:@"%.1fKB", (size / 1024.)];
    else if (size >= pow(1024, 2) && size < pow(1024, 3))
        formattedStr = [NSString stringWithFormat:@"%.1fMB", (size / pow(1024, 2))];
    else if (size >= pow(1024, 3) && size < pow(1024, 4))
        formattedStr = [NSString stringWithFormat:@"%.1fGB", (size / pow(1024, 3))];
    else if (size >= pow(1024, 4))
        formattedStr = [NSString stringWithFormat:@"%.1fTB", (size / pow(1024, 4))];
    
    return formattedStr;
}

/**
 *  get Image Type Array contain jpg,png.gif
 *
 *  @return NSMutableArray as @[@"jpg",@"png",@"gif",@"jpeg"]
 */
+ (NSMutableArray *)getImageTypeArray {
    //image type array
    NSMutableArray *imageTypeArray = [NSMutableArray arrayWithObjects:@"jpg",@"png",@"gif",@"jpeg",nil];
    return imageTypeArray;
}

#pragma mark - message related

+ (NSInteger)numberofRowsWithMessageModel:(TBMessage *)model {
    if (model.isSystem) {
        return 1;
    }
    NSInteger rowCount;
    if (model.messageStr.length == 0) {
        rowCount = model.attachments.count + 1;
    } else {
        rowCount = model.attachments.count + 2;
    }
    return rowCount;
}

+ (CGFloat)getCellHeightWithAttachment:(TBAttachment *)attachment forModel:(TBMessage *)model {
    CGFloat cellHeight;
    NSString *category = attachment.category;
    //file
    if ([category isEqualToString:kDisplayModeFile]) {
        NSString *fileCategory = attachment.data[kFileCategory];
        if ([fileCategory isEqualToString:kFileCategoryImage]) {
            cellHeight = [TBImageTableViewCell calculateCellHeightWithMessage:model andAttachment:attachment];
        } else {
            cellHeight = [TBFileTableViewCell calculateCellHeight];
        }
    }
    // speech
    else if ([category isEqualToString:kDisplayModeSpeech]) {
        cellHeight = [TBVoiceCell calculateCellHeight];
    }
    //rtf,snippet,quote
    else if ([category isEqualToString:kDisplayModeRtf] || [category isEqualToString:kDisplayModeQuote] || [category isEqualToString:kDisplayModeSnippet]) {
        cellHeight = [TBWeiboCell calculateCellHeightWithMessage:model andAttachment:attachment];
    }
    // message attachment
    else if ([category isEqualToString:kDisplayModeMessage]) {
        cellHeight = [TBAttachementMessageCell calculateCellHeightForAttachment:attachment];
    }
    /*unknown category*/
    else {
        cellHeight = kUnknownAttachmentCellHeight;
    }
    
    return cellHeight;
}

//get private chat Identifier for message
+ (NSString *)privateChatIdentifierWithId:(NSString *)memeberId {
    NSString *currentTeamID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID];
    NSString *memberIdentifer = [NSString stringWithFormat:@"%@%@",currentTeamID,memeberId];
    return memberIdentifer;
}

+ (NSArray *)fetchLatestMessageWithRoomType:(ChatRoomType)roomType andId:(NSString *)targetID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setFetchLimit:20];
    NSPredicate *predicate;
    if (roomType == ChatRoomTypeForRoom) {
        predicate = [NSPredicate predicateWithFormat:@"roomID = %@",targetID];
    } else if (roomType == ChatRoomTypeForStory) {
        predicate = [NSPredicate predicateWithFormat:@"storyID = %@",targetID];
    } else {
        NSString *currentUserID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
        NSString *currentTeamID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID];
        predicate = [NSPredicate predicateWithFormat:@"creatorID IN {%@, %@} AND toID IN {%@, %@} AND teamID = %@",targetID,currentUserID,targetID,currentUserID,currentTeamID];
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"id" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[TBMessage managedObjectEntityName] inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    [fetchRequest setEntity:entity];
    NSArray*messageArray = [MOMessage MR_executeFetchRequest:fetchRequest];
    
    return [NSArray arrayWithArray:messageArray];
}

/**
 *  jadge received RecentMessage is In CurrentChat or not
 *
 *  @param recentMessage received message
 *
 *  @return BOOL
 */
+ (BOOL)isInCurrentChatForRecentMessage:(TBMessage *)recentMessage {
    if ([TBUtility currentAppDelegate].currentChatViewController) {
        if (recentMessage.roomID) {
            if ([[TBUtility currentAppDelegate].currentRoom.id isEqualToString:recentMessage.roomID]) {
                return YES;
            }
        } else if (recentMessage.storyID) {
            if ([[TBUtility currentAppDelegate].currentStory.id isEqualToString:recentMessage.storyID]) {
                return YES;
            }
        }
        else {
            NSString *messageTargetID = [TBUtility getTargetIdWithMessageCreatorId:recentMessage.creatorID andToID:recentMessage.toID];
            if ([[TBUtility currentAppDelegate].currentChatViewController.currentToMember.id isEqualToString:messageTargetID]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - deal for Color

//get color with file type
+(UIColor *) fileColorWithType:(NSString *)type {
    if ([type isEqualToString:@"doc"] || [type isEqualToString:@"docx"]) {
        return [UIColor tb_blueberryColor];
    }
    else if  ([type isEqualToString:@"xls"] || [type isEqualToString:@"xlsx"]) {
        return [UIColor tb_grassColor];
    }
    else if  ([@[@"mp3",@"wma",@"wmv",@"ogg",@"wav",@"wpga",@"mp2"] containsObject:type]||[@[@"mp4",@"3gp",@"avi",@"mpe",@"mpeg",@"mpg",@"mov"] containsObject:type]) {
        return [UIColor tb_orangeColor];
    }
    else if  ([@[@"ppt",@"pptx",@"pps"] containsObject:type]) {
        return [UIColor tb_redorangeColor];
    }
    else if  ([type isEqualToString:@"pdf"]) {
        return [UIColor tb_redColor];
    }
    else if  ([@[@"rar",@"zip"] containsObject:type]) {
        return [UIColor tb_purpleColor];
    }
    else if  ([type isEqualToString:@"psd"]) {
        return [UIColor tb_lightBlueColor];
    }
    else if  ([type isEqualToString:@"ai"]) {
        return [UIColor tb_brownColor];
    }
    else if  ([type isEqualToString:@"ind"]) {
        return [UIColor tb_pinkColor];
    }
    else {
        return [UIColor tb_otherFileColor];
    }
}

//get topic color with colorStr
+(UIColor *)getTopicRoomColorWith:(NSString *)colorStr {
    // Transform topic color to corresponding UIColor selector
    NSString *bubbleTintColorStr = colorStr;
    if (!bubbleTintColorStr) {
        bubbleTintColorStr = @"doc";
    }
    NSString *teamColor = [NSString stringWithFormat:@"tb_%@Color", bubbleTintColorStr];
    SEL aSelector = NSSelectorFromString(teamColor);
    
    // Set corresponding color for every team
    if ([UIColor respondsToSelector:aSelector]) {
       return [UIColor performSelector:aSelector];
    }
    else {
       return [UIColor tb_defaultColor];
    }
}

//create image with color
+ (UIImage*) createImageWithColor: (UIColor*) color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - deal for name related

//deal string for nil or NULL
+(NSString *)dealForNilWithString:(NSString *)originString {
    if ([originString isKindOfClass:[NSNull class]]) {
        return @"";
    }
    if (!originString) {
        return @"";
    }
    if ([[NSString stringWithFormat:@"%@",originString].lowercaseString isEqualToString:@"null"])
    {
        return @"";
    }
    return originString;
}

//get topic name 
+(NSString *)getTopicNameWithIsGeneral:(BOOL)isGeneral andTopicName:(NSString *)name {
    if (isGeneral) {
        return NSLocalizedString(@"General", @"General");
    } else {
        return name;
    }
}

//get robot talkai name with MOUser
+ (NSString *)getFinalUserNameWithMOUser:(MOUser *)user {
    if ([user.service isEqualToString:@"talkai"] && user.isRobotValue) {
        return NSLocalizedString(@"talkai", @"talkai");
    }
    if ([TBUtility dealForNilWithString:user.alias].length > 0) {
        return user.alias;
    }
    return [TBUtility dealForNilWithString:user.name];
}

//get robot talkai name with TBUser
+ (NSString *)getFinalUserNameWithTBUser:(TBUser *)user {
    if ([user.service isEqualToString:@"talkai"] && user.isRobot) {
        return NSLocalizedString(@"talkai", @"talkai");
    }
    if ([TBUtility dealForNilWithString:user.alias].length > 0) {
        return user.alias;
    } else {
        return user.name;
    }
}

//get creator name for TBMessage
+ (NSString *)getCreatorNameForMessage:(TBMessage *)message {
    if (message.authorName) {
        return message.authorName;
    }
    if ([message.creator.service isEqualToString:@"talkai"] && message.creator.isRobot) {
        return NSLocalizedString(@"talkai", @"talkai");
    }
    if (!message.creator) {
        return message.creator.name;
    }
    if ([TBUtility dealForNilWithString:message.creator.alias].length > 0) {
        return message.creator.alias;
    } else {
        return message.creator.name;
    }
}

//get creator avatar url for TBMessage
+ (NSURL *)getCreatorAvatarURLForMessage:(TBMessage *)message {
    if (message.authorAvatarUrl) {
        return message.authorAvatarUrl;
    }
    return message.creator.avatarURL;
}

+ (NSString *)getTargetIdWithMessageCreatorId:(NSString *)creatorId andToID:(NSString *)toId {
    NSString *targetUserID;
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
    if ([toId isEqualToString:currentUserID]) {
        targetUserID = creatorId;
    } else {
        targetUserID = toId;
    }
    return targetUserID;
}

#pragma mark - memeber role related

/**
 *  judge CurrentAccount is Manager or Nots
 *
 *  @return BOOL
 */
+ (BOOL)isManagerForCurrentAccount {
    MOUser *currentMOMembe = [MOUser currentUser];
    if ([currentMOMembe.role isEqualToString:@"owner"] || [currentMOMembe.role isEqualToString:@"admin"]) {
        return  YES;
    } else {
        return  NO;
    }
}

/**
 *  judge is Admin or not For Member With Member ID
 *
 *  @return BOOL
 */
+ (BOOL)isAdminForMemberWithMemberID:(NSString *)memberID {
    MOUser *currentMOMembe = [MOUser findFirstWithId:memberID];
    if ([currentMOMembe.role isEqualToString:@"admin"]) {
        return  YES;
    } else {
        return  NO;
    }
}

#pragma mark - deal for cell height related

//get tableView row height for diff tabBar height,just for tableView's controller has navigationBar
+(CGFloat)getTableRowHeightWithTabBarHieght:(CGFloat)tabBarHeight {
    CGFloat tableViewRowHeight;
    NSInteger screenHeight = kScreenHeight;
    switch (screenHeight) {
        case iPhone4:
            tableViewRowHeight = (kScreenHeight - kNavigationBarHeight - tabBarHeight)/6;
            break;
        case iphone5:
            tableViewRowHeight = (kScreenHeight - kNavigationBarHeight - tabBarHeight)/7;
            break;
        case iPhone6: 
            tableViewRowHeight = (kScreenHeight - kNavigationBarHeight - tabBarHeight)/8;
            break;
        case iphone6Plus:
            tableViewRowHeight = (kScreenHeight - kNavigationBarHeight - tabBarHeight)/9;
            break;
        default:
            break;
    }
    return tableViewRowHeight;
}

//get size for string
+ (CGSize)getSizeWith:(NSString *)importStr andMargin:(CGFloat)margin andLineSpace:(CGFloat)space andFont:(CGFloat)font {
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width - margin * 2;
    CGSize tempsize = CGSizeMake(contentViewWidth,CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setLineSpacing:space];
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:font], NSParagraphStyleAttributeName : paragraphStyle };
    UILabel *temLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines  = 0 ;
    temLabel.font = [UIFont systemFontOfSize:font];
    temLabel.textAlignment = NSTextAlignmentCenter;
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [temLabel setAttributedText:[[NSAttributedString alloc] initWithString:importStr attributes:attributes]];
    CGSize needSize = [temLabel sizeThatFits:tempsize];
    return CGSizeMake(ceil(needSize.width), ceil(needSize.height));
}

//get NSAttributedString with importString ,lineSpace and Font
+ (NSAttributedString *)getAttributedStringWith:(NSString *)importStr andLineSpace:(CGFloat)lineSpace andFont:(CGFloat)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [paragraphStyle setLineSpacing:lineSpace];
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:font], NSParagraphStyleAttributeName : paragraphStyle };
    NSAttributedString *resultAttributeString = [[NSAttributedString alloc] initWithString:importStr attributes:attributes];
    return resultAttributeString;
}

#pragma mark - Highlight key String in targetString

+ (NSMutableAttributedString *)highLightString:(NSString *)tintString inString:(NSString *)targetString {
    NSMutableAttributedString *roomAttributeStr = [[NSMutableAttributedString alloc]initWithString:[TBUtility dealForNilWithString:targetString]];
    if (!targetString) {
        return roomAttributeStr;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:tintString options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRange range = NSMakeRange(0,targetString.length);
    
    [regex enumerateMatchesInString:targetString
                            options:kNilOptions
                              range:range
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             [roomAttributeStr addAttribute:NSForegroundColorAttributeName
                                                      value:[UIColor tb_HighlightColor]
                                                      range:result.range];
                         }];
    
    if ([Hanzi2Pinyin hasChineseCharacter:targetString]) {
        for (int i = 0; i<[targetString length]; i++) {
            NSString *tempChar = [targetString substringWithRange:NSMakeRange(i, 1)];
            if (i < [targetString length] - 1) {
                NSString *tempEmojiChar = [targetString substringWithRange:NSMakeRange(i, 2)];
                if ([NSString isContainsEmoji:tempEmojiChar]) {
                    i++;
                    continue;
                }
            }
            if ([Hanzi2Pinyin hasChineseCharacter:tempChar]) {
                if ([tintString rangeOfString:[Hanzi2Pinyin convertToAbbreviation:tempChar]].location != NSNotFound) {
                    [roomAttributeStr addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor tb_HighlightColor]
                                             range:NSMakeRange(i, 1)];
                }
            }
        }
        
    }

    return roomAttributeStr;
}

+ (NSMutableAttributedString *)getHighlightStringFromMessageHighlightDictionary:(NSDictionary *)dictionary withKeyString:(NSString *)keyString {
    NSArray *contentArray = [dictionary objectForKey:keyString];
    NSArray *highlightStringArray = [TBUtility getHightlightStringArrFromString:contentArray.firstObject withTag:@"//em"];
    NSString *targetString = [TBUtility getStringWithoutRegexFromString:[TBUtility getStringWithoutHtmlFromString:contentArray.firstObject]];
    NSMutableAttributedString *roomAttributeStr = [[NSMutableAttributedString alloc]initWithString:[TBUtility dealForNilWithString:targetString]];
    if (!targetString) {
        return roomAttributeStr;
    }
    for (NSString *highlightString in highlightStringArray) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:highlightString options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSRange range = NSMakeRange(0,targetString.length);
        
        [regex enumerateMatchesInString:targetString
                                options:kNilOptions
                                  range:range
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                 [roomAttributeStr addAttribute:NSForegroundColorAttributeName
                                                          value:[UIColor tb_HighlightColor]
                                                          range:result.range];
                             }];

    }
    return roomAttributeStr;
}

#pragma mark - Date related

+ (NSDateFormatter *)dateFormatter {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *formatter = [threadDictionary objectForKey: @"DDMyDateFormatter"] ;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:kDefaultDateFormatString];
        [threadDictionary setObject:formatter forKey: @"DDMyDateFormatter"] ;
    }
    return formatter;
}

+ (NSString *)getDateStringFromTimeInterval:(NSTimeInterval)duration {
    int minutes = floor(duration/60);
    int seconds = round(duration - minutes * 60);
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    
    return timeString;
}

#pragma mark -  voice related

+ (NSString *)getVoiceLocalPathWithFileKey:(NSString *)fileKey {
    NSString *fileExtension = @"amr";
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"com.jianliao.Voice"];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:&error];
        if (!isDirectoryCreated) {
            NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                             reason:@"Failed to crate cache directory"
                                                           userInfo:@{ NSUnderlyingErrorKey : error }];
            @throw exception;
        }
    }
    NSString *temporaryFilePath = [[cacheDirectory stringByAppendingPathComponent:fileKey] stringByAppendingPathExtension:fileExtension];
    return temporaryFilePath;
}

//get time string like 00:10 style
+ (NSString *)getTimeStringWithDuration:(NSInteger)duration {
    int minutes = floor(duration/60);
    int seconds = round(duration - minutes * 60);
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    
    return timeString;
}

#pragma mark - MOClass Predicate Filter

+ (NSPredicate *)storyPredicateForCurrentTeamWithRoomId:(NSString *)storyID {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    NSPredicate *topicFilter = [NSPredicate predicateWithFormat:@"id = %@ AND teamID = %@ ",storyID, currentTeamID];
    return topicFilter;
}

+ (NSPredicate *)roomPredicateForCurrentTeamWithRoomId:(NSString *)roomID {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    NSPredicate *topicFilter = [NSPredicate predicateWithFormat:@"id = %@ AND teams.id = %@ ",roomID, currentTeamID];
    return topicFilter;
}

+ (NSPredicate *)memberPredicateForCurrentTeamWithMemberId:(NSString *)memberID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"userID = %@ AND team.id = %@",memberID, currentTeamID];
    return filter;
}

+ (NSPredicate *)notificationPredictForCurrentTeamWithTargetId:(NSString *)targetID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"targetID = %@ AND teamID= %@",targetID, currentTeamID];
    return filter;
}

#pragma mark - sort MOUSer

//sort method
NSInteger UserNameSort(id user1, id user2, void *context) {
    MOUser *u1,*u2;
    u1 = (MOUser*)user1;
    u2 = (MOUser*)user2;
    return  [u1.name localizedCompare:u2.name
             ];
}

#pragma mark - get error code

+ (NSString *)getApiErrorCodeWithError:(NSError *)error {
    NSString *httpStatusCode = [NSString stringWithFormat:@"%ld",(long)[error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode]];
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    
    NSString *customerStatusCode = nil;
    if (errorData) {
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        customerStatusCode = [NSString stringWithFormat:@"%@", serializedData[@"code"]];
    }
    
    NSMutableString *apiErrorCode = [[NSMutableString alloc] init];
    [apiErrorCode appendString:httpStatusCode];
    if ((customerStatusCode != nil) && ([customerStatusCode isEqualToString:@"(null)"] == NO)) {
        [apiErrorCode appendString:customerStatusCode];
    }
    
    return apiErrorCode;
}

+ (NSDictionary *)errorInfoDictionaryInError:(NSError *)error {
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        NSDictionary *serializedDictionary = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        return serializedDictionary;
    } else {
        return [NSDictionary dictionary];
    }
}

+ (void)showMessageInError:(NSError *)error {
    NSDictionary *infoDic = [TBUtility errorInfoDictionaryInError:error];
    NSString *errorMesage = infoDic[@"message"];
    if (errorMesage != nil) {
        [SVProgressHUD showErrorWithStatus:errorMesage];
    } else {
        if (error.localizedRecoverySuggestion) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        } else if (error.localizedDescription) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetWork connect fault,Please check!", @"NetWork connect fault,Please check!")];
        }
    }
    
}

#pragma mark - login&signup related

+ (void) customizeTextfield: (UITextField *)textField withPlaceHolder:(NSString *)placeHolder {
    [textField setBorderStyle:UITextBorderStyleNone];
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 0)];
    textField.leftView.userInteractionEnabled = NO;
    textField.leftViewMode = UITextFieldViewModeAlways;
    [textField setPlaceholder:placeHolder];
}

+ (NSString *)getNumberString:(NSString *) everyStr {
    NSString *onlyNumStr = [everyStr stringByReplacingOccurrencesOfString:@"[^0-9,]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [everyStr length])];
    return onlyNumStr;
}

+ (BOOL)checkChinaTelNumber:(NSString *) telNumber {
    NSString *pattern = @"^1[3578]\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [pred evaluateWithObject:telNumber];
}

+ (BOOL)checkInternationalTelNumber:(NSString *) telNumber {
    NSString *pattern = @"[0-9]{1,4}-[0-9]{3,11}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [pred evaluateWithObject:telNumber];
}

+ (BOOL)checkPhoneNumberWithString:(NSString *)phoneNumber {
    NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789\n"] invertedSet];
    NSString *filtered = [[phoneNumber componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
    return [phoneNumber isEqualToString:filtered];
}

+ (BOOL)checkEmail:(NSString *)email {
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [pred evaluateWithObject:email];
}

+ (BOOL)checkNumberString:(NSString *)code {
    NSString *pattern = @"^[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [pred evaluateWithObject:code]&&code.length>0;
}

+ (BOOL)checkNumberString:(NSString *)code withCount:(int)count {
    NSString *pattern = [NSString stringWithFormat:@"\\d{%d}",count];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [pred evaluateWithObject:code];
}

#pragma mark - language

+ (NSString*)getPreferredLanguage {
    NSString *languageID = [[NSBundle mainBundle] preferredLocalizations].firstObject;
    return languageID;
}

+ (BOOL)systemLanguageIsChinese {
    NSString *language = [TBUtility getPreferredLanguage];
    return [language  containsString: @"zh-Hans"] || [language containsString: @"zh-Hant"];
}

#pragma mark - Google Analytics Event

+ (void)sendAnalyticsEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
    [[[GAI sharedInstance] defaultTracker] send:[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value].build];
    if (label && label.length > 0) {
        [[Mixpanel sharedInstance] track:action properties:@{@"category":category,@"label":label}];
    } else {
        [[Mixpanel sharedInstance] track:action properties:@{@"category":category}];
    }
}

+ (void)startimingEventWithAction:(NSString *)action {
    [TBUtility currentAppDelegate].timedEvents[action] = @([[NSDate date] timeIntervalSince1970]);
    [[Mixpanel sharedInstance] timeEvent:action];
}

+ (void)endTimingEventWithAction:(NSString *)action {
    NSNumber *eventStartTime = [TBUtility currentAppDelegate].timedEvents[action];
    if (eventStartTime) {
        double epochInterval = [[NSDate date] timeIntervalSince1970];
        [[TBUtility currentAppDelegate].timedEvents removeAllObjects];
        CGFloat duration = [[NSString stringWithFormat:@"%.3f", epochInterval - [eventStartTime doubleValue]] floatValue];
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createTimingWithCategory:kAnalyticsCategoryLogin
                                                             interval:@((NSUInteger)duration)
                                                                 name:action
                                                                label:nil] build]];
    }
    [[Mixpanel sharedInstance] track:action];
}

# pragma mark - Search History

+ (void)saveSearchHistoryWithString:(NSString *)searchText {
    NSMutableArray *existHistoryArray = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] arrayForKey:kSearchHistory];
    NSMutableArray *historyArray = [NSMutableArray arrayWithArray:existHistoryArray];
    if (![historyArray containsObject:searchText]) {
        if (historyArray.count == 0) {
            [historyArray addObject:searchText];
        } else {
            [historyArray insertObject:searchText atIndex:0];
        }
        [[NSUserDefaults standardUserDefaults] setObject:historyArray forKey:kSearchHistory];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
