// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOQuote.h instead.

#import <CoreData/CoreData.h>

extern const struct MOQuoteAttributes {
	__unsafe_unretained NSString *authorAvatarURL;
	__unsafe_unretained NSString *authorName;
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *openId;
	__unsafe_unretained NSString *redirectURL;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *thumbnailPicURL;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *userAvatarURL;
	__unsafe_unretained NSString *userName;
} MOQuoteAttributes;

@interface MOQuoteID : NSManagedObjectID {}
@end

@interface _MOQuote : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOQuoteID* objectID;

@property (nonatomic, strong) NSString* authorAvatarURL;

//- (BOOL)validateAuthorAvatarURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* authorName;

//- (BOOL)validateAuthorName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* openId;

//- (BOOL)validateOpenId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* redirectURL;

//- (BOOL)validateRedirectURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* thumbnailPicURL;

//- (BOOL)validateThumbnailPicURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* userAvatarURL;

//- (BOOL)validateUserAvatarURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* userName;

//- (BOOL)validateUserName:(id*)value_ error:(NSError**)error_;

@end

@interface _MOQuote (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthorAvatarURL;
- (void)setPrimitiveAuthorAvatarURL:(NSString*)value;

- (NSString*)primitiveAuthorName;
- (void)setPrimitiveAuthorName:(NSString*)value;

- (NSString*)primitiveCategory;
- (void)setPrimitiveCategory:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveOpenId;
- (void)setPrimitiveOpenId:(NSString*)value;

- (NSString*)primitiveRedirectURL;
- (void)setPrimitiveRedirectURL:(NSString*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (NSString*)primitiveThumbnailPicURL;
- (void)setPrimitiveThumbnailPicURL:(NSString*)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSString*)primitiveUserAvatarURL;
- (void)setPrimitiveUserAvatarURL:(NSString*)value;

- (NSString*)primitiveUserName;
- (void)setPrimitiveUserName:(NSString*)value;

@end
