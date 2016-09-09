// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOStory.h instead.

#import <CoreData/CoreData.h>

extern const struct MOStoryAttributes {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *creatorID;
	__unsafe_unretained NSString *data;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isPublic;
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *teamID;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
} MOStoryAttributes;

extern const struct MOStoryRelationships {
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *notification;
} MOStoryRelationships;

@class MOMessage;
@class MONotification;

@class NSObject;

@class NSObject;

@interface MOStoryID : NSManagedObjectID {}
@end

@interface _MOStory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOStoryID* objectID;

@property (nonatomic, strong) NSString* category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorID;

//- (BOOL)validateCreatorID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isPublic;

@property (atomic) BOOL isPublicValue;
- (BOOL)isPublicValue;
- (void)setIsPublicValue:(BOOL)value_;

//- (BOOL)validateIsPublic:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id members;

//- (BOOL)validateMembers:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamID;

//- (BOOL)validateTeamID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) MONotification *notification;

//- (BOOL)validateNotification:(id*)value_ error:(NSError**)error_;

@end

@interface _MOStory (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(MOMessage*)value_;
- (void)removeMessagesObject:(MOMessage*)value_;

@end

@interface _MOStory (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCategory;
- (void)setPrimitiveCategory:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCreatorID;
- (void)setPrimitiveCreatorID:(NSString*)value;

- (id)primitiveData;
- (void)setPrimitiveData:(id)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsPublic;
- (void)setPrimitiveIsPublic:(NSNumber*)value;

- (BOOL)primitiveIsPublicValue;
- (void)setPrimitiveIsPublicValue:(BOOL)value_;

- (id)primitiveMembers;
- (void)setPrimitiveMembers:(id)value;

- (NSString*)primitiveTeamID;
- (void)setPrimitiveTeamID:(NSString*)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (MONotification*)primitiveNotification;
- (void)setPrimitiveNotification:(MONotification*)value;

@end
