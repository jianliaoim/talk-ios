// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOFile.m instead.

#import "_MOFile.h"

const struct MOFileAttributes MOFileAttributes = {
	.createdAt = @"createdAt",
	.creatorID = @"creatorID",
	.downloadURL = @"downloadURL",
	.duration = @"duration",
	.fileCategory = @"fileCategory",
	.fileKey = @"fileKey",
	.fileName = @"fileName",
	.fileSize = @"fileSize",
	.fileType = @"fileType",
	.id = @"id",
	.imageHeight = @"imageHeight",
	.imageWidth = @"imageWidth",
	.isSpeech = @"isSpeech",
	.messageID = @"messageID",
	.roomID = @"roomID",
	.teamID = @"teamID",
	.thumbnailURL = @"thumbnailURL",
	.updatedAt = @"updatedAt",
};

@implementation MOFileID
@end

@implementation _MOFile

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"File";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc_];
}

- (MOFileID*)objectID {
	return (MOFileID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fileSizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fileSize"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"imageHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"imageHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"imageWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"imageWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isSpeechValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isSpeech"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic createdAt;

@dynamic creatorID;

@dynamic downloadURL;

@dynamic duration;

- (int64_t)durationValue {
	NSNumber *result = [self duration];
	return [result longLongValue];
}

- (void)setDurationValue:(int64_t)value_ {
	[self setDuration:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result longLongValue];
}

- (void)setPrimitiveDurationValue:(int64_t)value_ {
	[self setPrimitiveDuration:[NSNumber numberWithLongLong:value_]];
}

@dynamic fileCategory;

@dynamic fileKey;

@dynamic fileName;

@dynamic fileSize;

- (int64_t)fileSizeValue {
	NSNumber *result = [self fileSize];
	return [result longLongValue];
}

- (void)setFileSizeValue:(int64_t)value_ {
	[self setFileSize:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveFileSizeValue {
	NSNumber *result = [self primitiveFileSize];
	return [result longLongValue];
}

- (void)setPrimitiveFileSizeValue:(int64_t)value_ {
	[self setPrimitiveFileSize:[NSNumber numberWithLongLong:value_]];
}

@dynamic fileType;

@dynamic id;

@dynamic imageHeight;

- (int64_t)imageHeightValue {
	NSNumber *result = [self imageHeight];
	return [result longLongValue];
}

- (void)setImageHeightValue:(int64_t)value_ {
	[self setImageHeight:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveImageHeightValue {
	NSNumber *result = [self primitiveImageHeight];
	return [result longLongValue];
}

- (void)setPrimitiveImageHeightValue:(int64_t)value_ {
	[self setPrimitiveImageHeight:[NSNumber numberWithLongLong:value_]];
}

@dynamic imageWidth;

- (int64_t)imageWidthValue {
	NSNumber *result = [self imageWidth];
	return [result longLongValue];
}

- (void)setImageWidthValue:(int64_t)value_ {
	[self setImageWidth:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveImageWidthValue {
	NSNumber *result = [self primitiveImageWidth];
	return [result longLongValue];
}

- (void)setPrimitiveImageWidthValue:(int64_t)value_ {
	[self setPrimitiveImageWidth:[NSNumber numberWithLongLong:value_]];
}

@dynamic isSpeech;

- (BOOL)isSpeechValue {
	NSNumber *result = [self isSpeech];
	return [result boolValue];
}

- (void)setIsSpeechValue:(BOOL)value_ {
	[self setIsSpeech:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsSpeechValue {
	NSNumber *result = [self primitiveIsSpeech];
	return [result boolValue];
}

- (void)setPrimitiveIsSpeechValue:(BOOL)value_ {
	[self setPrimitiveIsSpeech:[NSNumber numberWithBool:value_]];
}

@dynamic messageID;

@dynamic roomID;

@dynamic teamID;

@dynamic thumbnailURL;

@dynamic updatedAt;

@end

