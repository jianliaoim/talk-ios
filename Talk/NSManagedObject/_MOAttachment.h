// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOAttachment.h instead.

#import <CoreData/CoreData.h>

extern const struct MOAttachmentAttributes {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *cellHeight;
	__unsafe_unretained NSString *data;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *text;
} MOAttachmentAttributes;

extern const struct MOAttachmentRelationships {
	__unsafe_unretained NSString *message;
} MOAttachmentRelationships;

@class MOMessage;

@class NSObject;

@interface MOAttachmentID : NSManagedObjectID {}
@end

@interface _MOAttachment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOAttachmentID* objectID;

@property (nonatomic, strong) NSString* category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* cellHeight;

@property (atomic) float cellHeightValue;
- (float)cellHeightValue;
- (void)setCellHeightValue:(float)value_;

//- (BOOL)validateCellHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MOMessage *message;

//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;

@end

@interface _MOAttachment (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCategory;
- (void)setPrimitiveCategory:(NSString*)value;

- (NSNumber*)primitiveCellHeight;
- (void)setPrimitiveCellHeight:(NSNumber*)value;

- (float)primitiveCellHeightValue;
- (void)setPrimitiveCellHeightValue:(float)value_;

- (id)primitiveData;
- (void)setPrimitiveData:(id)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (MOMessage*)primitiveMessage;
- (void)setPrimitiveMessage:(MOMessage*)value;

@end
