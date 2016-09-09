// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOFile.h instead.

#import <CoreData/CoreData.h>

extern const struct MOFileAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *creatorID;
	__unsafe_unretained NSString *downloadURL;
	__unsafe_unretained NSString *duration;
	__unsafe_unretained NSString *fileCategory;
	__unsafe_unretained NSString *fileKey;
	__unsafe_unretained NSString *fileName;
	__unsafe_unretained NSString *fileSize;
	__unsafe_unretained NSString *fileType;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *imageHeight;
	__unsafe_unretained NSString *imageWidth;
	__unsafe_unretained NSString *isSpeech;
	__unsafe_unretained NSString *messageID;
	__unsafe_unretained NSString *roomID;
	__unsafe_unretained NSString *teamID;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *updatedAt;
} MOFileAttributes;

@interface MOFileID : NSManagedObjectID {}
@end

@interface _MOFile : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MOFileID* objectID;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* creatorID;

//- (BOOL)validateCreatorID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* downloadURL;

//- (BOOL)validateDownloadURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* duration;

@property (atomic) int64_t durationValue;
- (int64_t)durationValue;
- (void)setDurationValue:(int64_t)value_;

//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fileCategory;

//- (BOOL)validateFileCategory:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fileKey;

//- (BOOL)validateFileKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fileName;

//- (BOOL)validateFileName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* fileSize;

@property (atomic) int64_t fileSizeValue;
- (int64_t)fileSizeValue;
- (void)setFileSizeValue:(int64_t)value_;

//- (BOOL)validateFileSize:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fileType;

//- (BOOL)validateFileType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* imageHeight;

@property (atomic) int64_t imageHeightValue;
- (int64_t)imageHeightValue;
- (void)setImageHeightValue:(int64_t)value_;

//- (BOOL)validateImageHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* imageWidth;

@property (atomic) int64_t imageWidthValue;
- (int64_t)imageWidthValue;
- (void)setImageWidthValue:(int64_t)value_;

//- (BOOL)validateImageWidth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isSpeech;

@property (atomic) BOOL isSpeechValue;
- (BOOL)isSpeechValue;
- (void)setIsSpeechValue:(BOOL)value_;

//- (BOOL)validateIsSpeech:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* messageID;

//- (BOOL)validateMessageID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* roomID;

//- (BOOL)validateRoomID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* teamID;

//- (BOOL)validateTeamID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* thumbnailURL;

//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@end

@interface _MOFile (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCreatorID;
- (void)setPrimitiveCreatorID:(NSString*)value;

- (NSString*)primitiveDownloadURL;
- (void)setPrimitiveDownloadURL:(NSString*)value;

- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (int64_t)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(int64_t)value_;

- (NSString*)primitiveFileCategory;
- (void)setPrimitiveFileCategory:(NSString*)value;

- (NSString*)primitiveFileKey;
- (void)setPrimitiveFileKey:(NSString*)value;

- (NSString*)primitiveFileName;
- (void)setPrimitiveFileName:(NSString*)value;

- (NSNumber*)primitiveFileSize;
- (void)setPrimitiveFileSize:(NSNumber*)value;

- (int64_t)primitiveFileSizeValue;
- (void)setPrimitiveFileSizeValue:(int64_t)value_;

- (NSString*)primitiveFileType;
- (void)setPrimitiveFileType:(NSString*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveImageHeight;
- (void)setPrimitiveImageHeight:(NSNumber*)value;

- (int64_t)primitiveImageHeightValue;
- (void)setPrimitiveImageHeightValue:(int64_t)value_;

- (NSNumber*)primitiveImageWidth;
- (void)setPrimitiveImageWidth:(NSNumber*)value;

- (int64_t)primitiveImageWidthValue;
- (void)setPrimitiveImageWidthValue:(int64_t)value_;

- (NSNumber*)primitiveIsSpeech;
- (void)setPrimitiveIsSpeech:(NSNumber*)value;

- (BOOL)primitiveIsSpeechValue;
- (void)setPrimitiveIsSpeechValue:(BOOL)value_;

- (NSString*)primitiveMessageID;
- (void)setPrimitiveMessageID:(NSString*)value;

- (NSString*)primitiveRoomID;
- (void)setPrimitiveRoomID:(NSString*)value;

- (NSString*)primitiveTeamID;
- (void)setPrimitiveTeamID:(NSString*)value;

- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

@end
