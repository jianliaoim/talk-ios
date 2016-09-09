// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOGroup.h instead.

#import <CoreData/CoreData.h>

extern const struct MOGroupAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *creatorId;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *teamId;
	__unsafe_unretained NSString *updatedAt;
} MOGroupAttributes;

@class NSObject;

@interface MOGroupID : NSManagedObjectID {}
@end

@interface _MOGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOGroupID* objectID;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorId;

//- (BOOL)validateCreatorId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id members;

//- (BOOL)validateMembers:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamId;

//- (BOOL)validateTeamId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@end

@interface _MOGroup (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCreatorId;
- (void)setPrimitiveCreatorId:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (id)primitiveMembers;
- (void)setPrimitiveMembers:(id)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveTeamId;
- (void)setPrimitiveTeamId:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

@end
