// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MODraft.m instead.

#import "_MODraft.h"

const struct MODraftAttributes MODraftAttributes = {
	.content = @"content",
	.id = @"id",
	.updatedAt = @"updatedAt",
};

const struct MODraftRelationships MODraftRelationships = {
	.notification = @"notification",
};

@implementation MODraftID
@end

@implementation _MODraft

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Draft" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Draft";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Draft" inManagedObjectContext:moc_];
}

- (MODraftID*)objectID {
	return (MODraftID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic content;

@dynamic id;

@dynamic updatedAt;

@dynamic notification;

@end

