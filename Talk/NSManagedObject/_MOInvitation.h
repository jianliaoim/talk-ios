// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOInvitation.h instead.

#import <CoreData/CoreData.h>

extern const struct MOInvitationAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *mobile;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *teamId;
} MOInvitationAttributes;

@interface MOInvitationID : NSManagedObjectID {}
@end

@interface _MOInvitation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOInvitationID* objectID;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mobile;

//- (BOOL)validateMobile:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamId;

//- (BOOL)validateTeamId:(id*)value_ error:(NSError**)error_;

@end

@interface _MOInvitation (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSString*)primitiveMobile;
- (void)setPrimitiveMobile:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveTeamId;
- (void)setPrimitiveTeamId:(NSString*)value;

@end
