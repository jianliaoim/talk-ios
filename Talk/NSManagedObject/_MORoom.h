// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MORoom.h instead.

#import <CoreData/CoreData.h>

extern const struct MORoomAttributes {
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *creatorID;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isArchived;
	__unsafe_unretained NSString *isGeneral;
	__unsafe_unretained NSString *isMute;
	__unsafe_unretained NSString *isPrivate;
	__unsafe_unretained NSString *isQuit;
	__unsafe_unretained NSString *pinnedAt;
	__unsafe_unretained NSString *purpose;
	__unsafe_unretained NSString *teamID;
	__unsafe_unretained NSString *topic;
	__unsafe_unretained NSString *unread;
	__unsafe_unretained NSString *updatedAt;
} MORoomAttributes;

extern const struct MORoomRelationships {
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *teams;
} MORoomRelationships;

@class MOUser;
@class MOTeam;

@interface MORoomID : NSManagedObjectID {}
@end

@interface _MORoom : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MORoomID* objectID;

@property (nonatomic, strong) NSString* color;

//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorID;

//- (BOOL)validateCreatorID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isArchived;

@property (atomic) BOOL isArchivedValue;
- (BOOL)isArchivedValue;
- (void)setIsArchivedValue:(BOOL)value_;

//- (BOOL)validateIsArchived:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isGeneral;

@property (atomic) BOOL isGeneralValue;
- (BOOL)isGeneralValue;
- (void)setIsGeneralValue:(BOOL)value_;

//- (BOOL)validateIsGeneral:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isMute;

@property (atomic) BOOL isMuteValue;
- (BOOL)isMuteValue;
- (void)setIsMuteValue:(BOOL)value_;

//- (BOOL)validateIsMute:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isPrivate;

@property (atomic) BOOL isPrivateValue;
- (BOOL)isPrivateValue;
- (void)setIsPrivateValue:(BOOL)value_;

//- (BOOL)validateIsPrivate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isQuit;

@property (atomic) BOOL isQuitValue;
- (BOOL)isQuitValue;
- (void)setIsQuitValue:(BOOL)value_;

//- (BOOL)validateIsQuit:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* pinnedAt;

//- (BOOL)validatePinnedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* purpose;

//- (BOOL)validatePurpose:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamID;

//- (BOOL)validateTeamID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* topic;

//- (BOOL)validateTopic:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* unread;

@property (atomic) int64_t unreadValue;
- (int64_t)unreadValue;
- (void)setUnreadValue:(int64_t)value_;

//- (BOOL)validateUnread:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *members;

- (NSMutableSet*)membersSet;

@property (nonatomic, strong) MOTeam *teams;

//- (BOOL)validateTeams:(id*)value_ error:(NSError**)error_;

@end

@interface _MORoom (MembersCoreDataGeneratedAccessors)
- (void)addMembers:(NSSet*)value_;
- (void)removeMembers:(NSSet*)value_;
- (void)addMembersObject:(MOUser*)value_;
- (void)removeMembersObject:(MOUser*)value_;

@end

@interface _MORoom (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveColor;
- (void)setPrimitiveColor:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCreatorID;
- (void)setPrimitiveCreatorID:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsArchived;
- (void)setPrimitiveIsArchived:(NSNumber*)value;

- (BOOL)primitiveIsArchivedValue;
- (void)setPrimitiveIsArchivedValue:(BOOL)value_;

- (NSNumber*)primitiveIsGeneral;
- (void)setPrimitiveIsGeneral:(NSNumber*)value;

- (BOOL)primitiveIsGeneralValue;
- (void)setPrimitiveIsGeneralValue:(BOOL)value_;

- (NSNumber*)primitiveIsMute;
- (void)setPrimitiveIsMute:(NSNumber*)value;

- (BOOL)primitiveIsMuteValue;
- (void)setPrimitiveIsMuteValue:(BOOL)value_;

- (NSNumber*)primitiveIsPrivate;
- (void)setPrimitiveIsPrivate:(NSNumber*)value;

- (BOOL)primitiveIsPrivateValue;
- (void)setPrimitiveIsPrivateValue:(BOOL)value_;

- (NSNumber*)primitiveIsQuit;
- (void)setPrimitiveIsQuit:(NSNumber*)value;

- (BOOL)primitiveIsQuitValue;
- (void)setPrimitiveIsQuitValue:(BOOL)value_;

- (NSDate*)primitivePinnedAt;
- (void)setPrimitivePinnedAt:(NSDate*)value;

- (NSString*)primitivePurpose;
- (void)setPrimitivePurpose:(NSString*)value;

- (NSString*)primitiveTeamID;
- (void)setPrimitiveTeamID:(NSString*)value;

- (NSString*)primitiveTopic;
- (void)setPrimitiveTopic:(NSString*)value;

- (NSNumber*)primitiveUnread;
- (void)setPrimitiveUnread:(NSNumber*)value;

- (int64_t)primitiveUnreadValue;
- (void)setPrimitiveUnreadValue:(int64_t)value_;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSMutableSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableSet*)value;

- (MOTeam*)primitiveTeams;
- (void)setPrimitiveTeams:(MOTeam*)value;

@end
