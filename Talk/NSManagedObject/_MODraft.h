// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MODraft.h instead.

#import <CoreData/CoreData.h>

extern const struct MODraftAttributes {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *updatedAt;
} MODraftAttributes;

extern const struct MODraftRelationships {
	__unsafe_unretained NSString *notification;
} MODraftRelationships;

@class MONotification;

@interface MODraftID : NSManagedObjectID {}
@end

@interface _MODraft : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MODraftID* objectID;

@property (nonatomic, strong) NSString* content;

//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MONotification *notification;

//- (BOOL)validateNotification:(id*)value_ error:(NSError**)error_;

@end

@interface _MODraft (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveContent;
- (void)setPrimitiveContent:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (MONotification*)primitiveNotification;
- (void)setPrimitiveNotification:(MONotification*)value;

@end
