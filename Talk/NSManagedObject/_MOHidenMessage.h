// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOHidenMessage.h instead.

#import <CoreData/CoreData.h>

extern const struct MOHidenMessageAttributes {
	__unsafe_unretained NSString *messageID;
	__unsafe_unretained NSString *targetID;
	__unsafe_unretained NSString *teamID;
} MOHidenMessageAttributes;

@interface MOHidenMessageID : NSManagedObjectID {}
@end

@interface _MOHidenMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOHidenMessageID* objectID;

@property (nonatomic, strong) NSString* messageID;

//- (BOOL)validateMessageID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* targetID;

//- (BOOL)validateTargetID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamID;

//- (BOOL)validateTeamID:(id*)value_ error:(NSError**)error_;

@end

@interface _MOHidenMessage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveMessageID;
- (void)setPrimitiveMessageID:(NSString*)value;

- (NSString*)primitiveTargetID;
- (void)setPrimitiveTargetID:(NSString*)value;

- (NSString*)primitiveTeamID;
- (void)setPrimitiveTeamID:(NSString*)value;

@end
