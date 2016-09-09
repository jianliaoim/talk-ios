// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MONotification.h instead.

#import <CoreData/CoreData.h>

extern const struct MONotificationAttributes {
	__unsafe_unretained NSString *authorName;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *creatorID;
	__unsafe_unretained NSString *creatorName;
	__unsafe_unretained NSString *emitterID;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isHidden;
	__unsafe_unretained NSString *isMute;
	__unsafe_unretained NSString *isPinned;
	__unsafe_unretained NSString *latestReadMessageID;
	__unsafe_unretained NSString *sendStatus;
	__unsafe_unretained NSString *target;
	__unsafe_unretained NSString *targetID;
	__unsafe_unretained NSString *teamID;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *unreadNum;
	__unsafe_unretained NSString *updatedAt;
} MONotificationAttributes;

extern const struct MONotificationRelationships {
	__unsafe_unretained NSString *draft;
	__unsafe_unretained NSString *story;
} MONotificationRelationships;

@class MODraft;
@class MOStory;

@class NSObject;

@interface MONotificationID : NSManagedObjectID {}
@end

@interface _MONotification : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MONotificationID* objectID;

@property (nonatomic, strong) NSString* authorName;

//- (BOOL)validateAuthorName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorID;

//- (BOOL)validateCreatorID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorName;

//- (BOOL)validateCreatorName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* emitterID;

//- (BOOL)validateEmitterID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isHidden;

@property (atomic) BOOL isHiddenValue;
- (BOOL)isHiddenValue;
- (void)setIsHiddenValue:(BOOL)value_;

//- (BOOL)validateIsHidden:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isMute;

@property (atomic) BOOL isMuteValue;
- (BOOL)isMuteValue;
- (void)setIsMuteValue:(BOOL)value_;

//- (BOOL)validateIsMute:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isPinned;

@property (atomic) BOOL isPinnedValue;
- (BOOL)isPinnedValue;
- (void)setIsPinnedValue:(BOOL)value_;

//- (BOOL)validateIsPinned:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* latestReadMessageID;

//- (BOOL)validateLatestReadMessageID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sendStatus;

@property (atomic) int16_t sendStatusValue;
- (int16_t)sendStatusValue;
- (void)setSendStatusValue:(int16_t)value_;

//- (BOOL)validateSendStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id target;

//- (BOOL)validateTarget:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* targetID;

//- (BOOL)validateTargetID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamID;

//- (BOOL)validateTeamID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* unreadNum;

@property (atomic) int64_t unreadNumValue;
- (int64_t)unreadNumValue;
- (void)setUnreadNumValue:(int64_t)value_;

//- (BOOL)validateUnreadNum:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MODraft *draft;

//- (BOOL)validateDraft:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MOStory *story;

//- (BOOL)validateStory:(id*)value_ error:(NSError**)error_;

@end

@interface _MONotification (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthorName;
- (void)setPrimitiveAuthorName:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCreatorID;
- (void)setPrimitiveCreatorID:(NSString*)value;

- (NSString*)primitiveCreatorName;
- (void)setPrimitiveCreatorName:(NSString*)value;

- (NSString*)primitiveEmitterID;
- (void)setPrimitiveEmitterID:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsHidden;
- (void)setPrimitiveIsHidden:(NSNumber*)value;

- (BOOL)primitiveIsHiddenValue;
- (void)setPrimitiveIsHiddenValue:(BOOL)value_;

- (NSNumber*)primitiveIsMute;
- (void)setPrimitiveIsMute:(NSNumber*)value;

- (BOOL)primitiveIsMuteValue;
- (void)setPrimitiveIsMuteValue:(BOOL)value_;

- (NSNumber*)primitiveIsPinned;
- (void)setPrimitiveIsPinned:(NSNumber*)value;

- (BOOL)primitiveIsPinnedValue;
- (void)setPrimitiveIsPinnedValue:(BOOL)value_;

- (NSString*)primitiveLatestReadMessageID;
- (void)setPrimitiveLatestReadMessageID:(NSString*)value;

- (NSNumber*)primitiveSendStatus;
- (void)setPrimitiveSendStatus:(NSNumber*)value;

- (int16_t)primitiveSendStatusValue;
- (void)setPrimitiveSendStatusValue:(int16_t)value_;

- (id)primitiveTarget;
- (void)setPrimitiveTarget:(id)value;

- (NSString*)primitiveTargetID;
- (void)setPrimitiveTargetID:(NSString*)value;

- (NSString*)primitiveTeamID;
- (void)setPrimitiveTeamID:(NSString*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (NSNumber*)primitiveUnreadNum;
- (void)setPrimitiveUnreadNum:(NSNumber*)value;

- (int64_t)primitiveUnreadNumValue;
- (void)setPrimitiveUnreadNumValue:(int64_t)value_;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (MODraft*)primitiveDraft;
- (void)setPrimitiveDraft:(MODraft*)value;

- (MOStory*)primitiveStory;
- (void)setPrimitiveStory:(MOStory*)value;

@end
