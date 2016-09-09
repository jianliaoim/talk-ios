// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MOQuote.m instead.

#import "_MOQuote.h"

const struct MOQuoteAttributes MOQuoteAttributes = {
	.authorAvatarURL = @"authorAvatarURL",
	.authorName = @"authorName",
	.category = @"category",
	.createdAt = @"createdAt",
	.id = @"id",
	.openId = @"openId",
	.redirectURL = @"redirectURL",
	.text = @"text",
	.thumbnailPicURL = @"thumbnailPicURL",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.userAvatarURL = @"userAvatarURL",
	.userName = @"userName",
};

@implementation MOQuoteID
@end

@implementation _MOQuote

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Quote" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Quote";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Quote" inManagedObjectContext:moc_];
}

- (MOQuoteID*)objectID {
	return (MOQuoteID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic authorAvatarURL;

@dynamic authorName;

@dynamic category;

@dynamic createdAt;

@dynamic id;

@dynamic openId;

@dynamic redirectURL;

@dynamic text;

@dynamic thumbnailPicURL;

@dynamic title;

@dynamic updatedAt;

@dynamic userAvatarURL;

@dynamic userName;

@end

