//
//  TBUtility.h
//  Talk
//
//  Created by teambition-ios on 14/10/23.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBRoom.h"
#import "AppDelegate.h"
#import "UIColor+TBColor.h"
#import "TBAttachment.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <AMPopTip/AMPopTip.h>

@class MOUser;
@class TBUser;
@class TBMessage;

@interface TBUtility : NSObject

+ (NSString *)deviceUUID;
//as the function name (as input "{{__info-join-room}} hello" , get "join topic hello")
+(NSString *) getStringWithoutRegexFromString:(NSString *)inputStr;

//delete Html 
+(NSString *) getStringWithoutHtmlFromString:(NSString *)inputStr;

//get link String
+ (NSArray *)getLinkStringArrFromHtmlString:(NSString *)htmlString;

//get highlight string for search
+ (NSArray *)getHightlightStringArrFromString:(NSString *)htmlString withTag:(NSString *)tag;

//get AttributeString From OriginString
+ (NSMutableAttributedString *)getAttributeStringFromOriginString:(NSString *)originString andNoBrString:(NSString *)noBrString;

//get First Image URL String from HTML
+(NSString *)getFirstImageURLStrFromHTMLString:(NSString *)htmlString;


//currentAppDelegate
+(AppDelegate *)currentAppDelegate;
+ (UIWindow *)applicationTopView;

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
+(NSString *)parseTBMessageContentWithTBMessage:(NSString *)messageBody;

//create image with color
+(UIImage*) createImageWithColor: (UIColor*) color;

//get color with file type
+(UIColor *) fileColorWithType:(NSString *)type;

//get topic color with colorStr
+(UIColor *)getTopicRoomColorWith:(NSString *)colorStr;

//get topic name
+(NSString *)getTopicNameWithIsGeneral:(BOOL)isGeneral andTopicName:(NSString *)name;

//get tableView row height for diff tabBar height,just for tableView's controller has navigationBar
+(CGFloat)getTableRowHeightWithTabBarHieght:(CGFloat)tabBarHeight;

//deal string for nil
+(NSString *)dealForNilWithString:(NSString *)originString;

//get size for string with margin ,space and font
+(CGSize)getSizeWith:(NSString *)importStr andMargin:(CGFloat)margin andLineSpace:(CGFloat)space andFont:(CGFloat)font;

//get NSAttributedString with importString ,lineSpace and Font
+(NSAttributedString *)getAttributedStringWith:(NSString *)importStr andLineSpace:(CGFloat)lineSpace andFont:(CGFloat)font;

/**
 *  convert Bytes to KB,MB,GB,TB
 *
 *  @param size sizeunsigned long long
 *
 *  @return like 1.2KB or 3.5MB
 */
+ (NSString *)convertBytes:(unsigned long long)size;

/**
 *  get Image Type Array contain jpg,png.gif
 *
 *  @return NSMutableArray as @[@"jpg",@"png",@"gif",@"jpeg"]
 */
+ (NSMutableArray *)getImageTypeArray;

#pragma mark - message related

/**
 *  get CellHeight for Attachment
 *
 *  @param attachment TBAttachment
 *  @param model      TBMessage
 *
 *  @return CGFloat
 */
+ (CGFloat)getCellHeightWithAttachment:(TBAttachment *)attachment forModel:(TBMessage *)model;

+ (NSInteger)numberofRowsWithMessageModel:(TBMessage *)model;

//get private chat Identifier for message
+ (NSString *)privateChatIdentifierWithId:(NSString *)memeberId;

/**
 *  jadge received RecentMessage is In CurrentChat or not
 *
 *  @param recentMessage received message
 *
 *  @return BOOL
 */
+ (BOOL)isInCurrentChatForRecentMessage:(TBMessage *)recentMessage;


#pragma mark - User related
//get robot talkai name with MOUser
+(NSString *)getFinalUserNameWithMOUser:(MOUser *)user;

//get robot talkai name with TBUser
+(NSString *)getFinalUserNameWithTBUser:(TBUser *)user;

//get creator name for TBMessage
+ (NSString *)getCreatorNameForMessage:(TBMessage *)message;

//get creator avatar url for TBMessage
+ (NSURL *)getCreatorAvatarURLForMessage:(TBMessage *)message;

+(NSString *)getTargetIdWithMessageCreatorId:(NSString *)creatorId andToID:(NSString *)toId;

/**
 *  judge CurrentAccount is Manager or Nots
 *
 *  @return BOOL
 */
+ (BOOL)isManagerForCurrentAccount;

/**
 *  judge is Admin or not For Member With Member ID
 *
 *  @return BOOL
 */
+ (BOOL)isAdminForMemberWithMemberID:(NSString *)memberID;

#pragma mark - Highlight key String in targetString

+ (NSMutableAttributedString *)highLightString:(NSString *)tintString inString:(NSString *)targetString;
+ (NSMutableAttributedString *)getHighlightStringFromMessageHighlightDictionary:(NSDictionary *)dictionary withKeyString:(NSString *)tintString;

#pragma mark -  Date related
+ (NSDateFormatter *)dateFormatter;
+ (NSString *)getDateStringFromTimeInterval:(NSTimeInterval)duration;

#pragma mark - voice related

+ (NSString *)getVoiceLocalPathWithFileKey:(NSString *)fileKey;
//get time string like 00:10 style
+ (NSString *)getTimeStringWithDuration:(NSInteger)duration;

#pragma mark - MOClass Predicate Filter

+ (NSPredicate *)storyPredicateForCurrentTeamWithRoomId:(NSString *)storyID;
+ (NSPredicate *)roomPredicateForCurrentTeamWithRoomId:(NSString *)roomID;
+ (NSPredicate *)memberPredicateForCurrentTeamWithMemberId:(NSString *)memberID;
+ (NSPredicate *)notificationPredictForCurrentTeamWithTargetId:(NSString *)targetID;

#pragma mark - sort MOUSer
//sort method
NSInteger UserNameSort(id user1, id user2, void *context);

#pragma mark - get error code

+ (NSString *)getApiErrorCodeWithError:(NSError *)error;
+ (NSDictionary *)errorInfoDictionaryInError:(NSError *)error;
+ (void)showMessageInError:(NSError *)error;

#pragma mark - login&signup related

+ (void) customizeTextfield: (UITextField *)textField withPlaceHolder:(NSString *)placeHolder;
+ (NSString *)getNumberString:(NSString *) everyStr;
+ (BOOL)checkChinaTelNumber:(NSString *) telNumber;
+ (BOOL)checkInternationalTelNumber:(NSString *) telNumber;
+ (BOOL)checkPhoneNumberWithString:(NSString *)phoneNumber;
+ (BOOL)checkEmail:(NSString *)email;
+ (BOOL)checkNumberString:(NSString *)code;
+ (BOOL)checkNumberString:(NSString *)code withCount:(int)count;

#pragma mark - language

+ (NSString*)getPreferredLanguage;
+ (BOOL)systemLanguageIsChinese;

#pragma mark - Analytics Event

+ (void)sendAnalyticsEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
+ (void)startimingEventWithAction:(NSString *)action;
+ (void)endTimingEventWithAction:(NSString *)action;

# pragma mark - Search History

+ (void)saveSearchHistoryWithString:(NSString *)searchText;

@end
