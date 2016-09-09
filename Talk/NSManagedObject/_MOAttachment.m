// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOAttachment.m instead.

#import "_MOAttachment.h"

const struct MOAttachmentAttributes MOAttachmentAttributes = {
	.category = @"category",
	.cellHeight = @"cellHeight",
	.data = @"data",
	.id = @"id",
	.text = @"text",
};

const struct MOAttachmentRelationships MOAttachmentRelationships = {
	.message = @"message",
};

@implementation MOAttachmentID
@end

@implementation _MOAttachment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Attachment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:moc_];
}

- (MOAttachmentID*)objectID {
	return (MOAttachmentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"cellHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cellHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic category;

@dynamic cellHeight;

- (float)cellHeightValue {
	NSNumber *result = [self cellHeight];
	return [result floatValue];
}

- (void)setCellHeightValue:(float)value_ {
	[self setCellHeight:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveCellHeightValue {
	NSNumber *result = [self primitiveCellHeight];
	return [result floatValue];
}

- (void)setPrimitiveCellHeightValue:(float)value_ {
	[self setPrimitiveCellHeight:[NSNumber numberWithFloat:value_]];
}

@dynamic data;

@dynamic id;

@dynamic text;

@dynamic message;

@end

