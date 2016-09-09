// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOTeam.h instead.

#import <CoreData/CoreData.h>

extern const struct MOTeamAttributes {
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *creatorID;
	__unsafe_unretained NSString *hasUnread;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *inviteCode;
	__unsafe_unretained NSString *inviteURL;
	__unsafe_unretained NSString *minDate;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *nonJoinable;
	__unsafe_unretained NSString *signCode;
	__unsafe_unretained NSString *source;
	__unsafe_unretained NSString *sourceId;
	__unsafe_unretained NSString *unread;
	__unsafe_unretained NSString *updatedAt;
} MOTeamAttributes;

extern const struct MOTeamRelationships {
	__unsafe_unretained NSString *rooms;
	__unsafe_unretained NSString *users;
} MOTeamRelationships;

@class MORoom;
@class MOUser;

@interface MOTeamID : NSManagedObjectID {}
@end

@interface _MOTeam : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOTeamID* objectID;

@property (nonatomic, strong) NSString* color;

//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorID;

//- (BOOL)validateCreatorID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* hasUnread;

@property (atomic) BOOL hasUnreadValue;
- (BOOL)hasUnreadValue;
- (void)setHasUnreadValue:(BOOL)value_;

//- (BOOL)validateHasUnread:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* inviteCode;

//- (BOOL)validateInviteCode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* inviteURL;

//- (BOOL)validateInviteURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* minDate;

//- (BOOL)validateMinDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* nonJoinable;

@property (atomic) BOOL nonJoinableValue;
- (BOOL)nonJoinableValue;
- (void)setNonJoinableValue:(BOOL)value_;

//- (BOOL)validateNonJoinable:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* signCode;

//- (BOOL)validateSignCode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* source;

//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* sourceId;

//- (BOOL)validateSourceId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* unread;

@property (atomic) int64_t unreadValue;
- (int64_t)unreadValue;
- (void)setUnreadValue:(int64_t)value_;

//- (BOOL)validateUnread:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *rooms;

- (NSMutableSet*)roomsSet;

@property (nonatomic, strong) NSSet *users;

- (NSMutableSet*)usersSet;

@end

@interface _MOTeam (RoomsCoreDataGeneratedAccessors)
- (void)addRooms:(NSSet*)value_;
- (void)removeRooms:(NSSet*)value_;
- (void)addRoomsObject:(MORoom*)value_;
- (void)removeRoomsObject:(MORoom*)value_;

@end

@interface _MOTeam (UsersCoreDataGeneratedAccessors)
- (void)addUsers:(NSSet*)value_;
- (void)removeUsers:(NSSet*)value_;
- (void)addUsersObject:(MOUser*)value_;
- (void)removeUsersObject:(MOUser*)value_;

@end

@interface _MOTeam (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveColor;
- (void)setPrimitiveColor:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCreatorID;
- (void)setPrimitiveCreatorID:(NSString*)value;

- (NSNumber*)primitiveHasUnread;
- (void)setPrimitiveHasUnread:(NSNumber*)value;

- (BOOL)primitiveHasUnreadValue;
- (void)setPrimitiveHasUnreadValue:(BOOL)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveInviteCode;
- (void)setPrimitiveInviteCode:(NSString*)value;

- (NSString*)primitiveInviteURL;
- (void)setPrimitiveInviteURL:(NSString*)value;

- (NSDate*)primitiveMinDate;
- (void)setPrimitiveMinDate:(NSDate*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveNonJoinable;
- (void)setPrimitiveNonJoinable:(NSNumber*)value;

- (BOOL)primitiveNonJoinableValue;
- (void)setPrimitiveNonJoinableValue:(BOOL)value_;

- (NSString*)primitiveSignCode;
- (void)setPrimitiveSignCode:(NSString*)value;

- (NSString*)primitiveSource;
- (void)setPrimitiveSource:(NSString*)value;

- (NSString*)primitiveSourceId;
- (void)setPrimitiveSourceId:(NSString*)value;

- (NSNumber*)primitiveUnread;
- (void)setPrimitiveUnread:(NSNumber*)value;

- (int64_t)primitiveUnreadValue;
- (void)setPrimitiveUnreadValue:(int64_t)value_;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSMutableSet*)primitiveRooms;
- (void)setPrimitiveRooms:(NSMutableSet*)value;

- (NSMutableSet*)primitiveUsers;
- (void)setPrimitiveUsers:(NSMutableSet*)value;

@end
