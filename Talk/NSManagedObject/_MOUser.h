// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOUser.h instead.

#import <CoreData/CoreData.h>

extern const struct MOUserAttributes {
	__unsafe_unretained NSString *alias;
	__unsafe_unretained NSString *avatarURL;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *hideMobile;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isGuest;
	__unsafe_unretained NSString *isMute;
	__unsafe_unretained NSString *isQuit;
	__unsafe_unretained NSString *isRobot;
	__unsafe_unretained NSString *mobile;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *phoneForLogin;
	__unsafe_unretained NSString *phoneNumber;
	__unsafe_unretained NSString *pinyin;
	__unsafe_unretained NSString *role;
	__unsafe_unretained NSString *service;
	__unsafe_unretained NSString *sourceId;
	__unsafe_unretained NSString *unread;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *userID;
} MOUserAttributes;

extern const struct MOUserRelationships {
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *rooms;
	__unsafe_unretained NSString *teams;
} MOUserRelationships;

@class MOMessage;
@class MORoom;
@class MOTeam;

@interface MOUserID : NSManagedObjectID {}
@end

@interface _MOUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOUserID* objectID;

@property (nonatomic, strong) NSString* alias;

//- (BOOL)validateAlias:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* avatarURL;

//- (BOOL)validateAvatarURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* hideMobile;

@property (atomic) BOOL hideMobileValue;
- (BOOL)hideMobileValue;
- (void)setHideMobileValue:(BOOL)value_;

//- (BOOL)validateHideMobile:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isGuest;

@property (atomic) BOOL isGuestValue;
- (BOOL)isGuestValue;
- (void)setIsGuestValue:(BOOL)value_;

//- (BOOL)validateIsGuest:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isMute;

@property (atomic) BOOL isMuteValue;
- (BOOL)isMuteValue;
- (void)setIsMuteValue:(BOOL)value_;

//- (BOOL)validateIsMute:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isQuit;

@property (atomic) BOOL isQuitValue;
- (BOOL)isQuitValue;
- (void)setIsQuitValue:(BOOL)value_;

//- (BOOL)validateIsQuit:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isRobot;

@property (atomic) BOOL isRobotValue;
- (BOOL)isRobotValue;
- (void)setIsRobotValue:(BOOL)value_;

//- (BOOL)validateIsRobot:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mobile;

//- (BOOL)validateMobile:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* phoneForLogin;

//- (BOOL)validatePhoneForLogin:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* phoneNumber;

//- (BOOL)validatePhoneNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* pinyin;

//- (BOOL)validatePinyin:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* role;

//- (BOOL)validateRole:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* service;

//- (BOOL)validateService:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* sourceId;

//- (BOOL)validateSourceId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* unread;

@property (atomic) int64_t unreadValue;
- (int64_t)unreadValue;
- (void)setUnreadValue:(int64_t)value_;

//- (BOOL)validateUnread:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* userID;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) NSSet *rooms;

- (NSMutableSet*)roomsSet;

@property (nonatomic, strong) MOTeam *teams;

//- (BOOL)validateTeams:(id*)value_ error:(NSError**)error_;

@end

@interface _MOUser (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(MOMessage*)value_;
- (void)removeMessagesObject:(MOMessage*)value_;

@end

@interface _MOUser (RoomsCoreDataGeneratedAccessors)
- (void)addRooms:(NSSet*)value_;
- (void)removeRooms:(NSSet*)value_;
- (void)addRoomsObject:(MORoom*)value_;
- (void)removeRoomsObject:(MORoom*)value_;

@end

@interface _MOUser (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAlias;
- (void)setPrimitiveAlias:(NSString*)value;

- (NSString*)primitiveAvatarURL;
- (void)setPrimitiveAvatarURL:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSNumber*)primitiveHideMobile;
- (void)setPrimitiveHideMobile:(NSNumber*)value;

- (BOOL)primitiveHideMobileValue;
- (void)setPrimitiveHideMobileValue:(BOOL)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsGuest;
- (void)setPrimitiveIsGuest:(NSNumber*)value;

- (BOOL)primitiveIsGuestValue;
- (void)setPrimitiveIsGuestValue:(BOOL)value_;

- (NSNumber*)primitiveIsMute;
- (void)setPrimitiveIsMute:(NSNumber*)value;

- (BOOL)primitiveIsMuteValue;
- (void)setPrimitiveIsMuteValue:(BOOL)value_;

- (NSNumber*)primitiveIsQuit;
- (void)setPrimitiveIsQuit:(NSNumber*)value;

- (BOOL)primitiveIsQuitValue;
- (void)setPrimitiveIsQuitValue:(BOOL)value_;

- (NSNumber*)primitiveIsRobot;
- (void)setPrimitiveIsRobot:(NSNumber*)value;

- (BOOL)primitiveIsRobotValue;
- (void)setPrimitiveIsRobotValue:(BOOL)value_;

- (NSString*)primitiveMobile;
- (void)setPrimitiveMobile:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitivePhoneForLogin;
- (void)setPrimitivePhoneForLogin:(NSString*)value;

- (NSString*)primitivePhoneNumber;
- (void)setPrimitivePhoneNumber:(NSString*)value;

- (NSString*)primitivePinyin;
- (void)setPrimitivePinyin:(NSString*)value;

- (NSString*)primitiveRole;
- (void)setPrimitiveRole:(NSString*)value;

- (NSString*)primitiveService;
- (void)setPrimitiveService:(NSString*)value;

- (NSString*)primitiveSourceId;
- (void)setPrimitiveSourceId:(NSString*)value;

- (NSNumber*)primitiveUnread;
- (void)setPrimitiveUnread:(NSNumber*)value;

- (int64_t)primitiveUnreadValue;
- (void)setPrimitiveUnreadValue:(int64_t)value_;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (NSMutableSet*)primitiveRooms;
- (void)setPrimitiveRooms:(NSMutableSet*)value;

- (MOTeam*)primitiveTeams;
- (void)setPrimitiveTeams:(MOTeam*)value;

@end
