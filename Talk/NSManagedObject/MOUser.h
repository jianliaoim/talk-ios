#import "_MOUser.h"

@interface MOUser : _MOUser {}
// Custom logic goes here.

#pragma mark - Find All User

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;


#pragma mark - Find Team User

+ (NSArray *)findAllInCurrentTeamWithContainRobot:(BOOL)containRobot;
+ (NSArray *)findAllInCurrentTeamWithcontainQuit:(BOOL)containQuit;
+ (NSArray *)findAllQuitMembersInCurrentTeam;
+ (NSArray *)findAllInTeamWithTeamId:(NSString *)teamId containRobot:(BOOL)containRobot;
+ (NSArray *)findAllInTeamWithTeamId:(NSString *)teamId containRobot:(BOOL)containRobot containQuit:(BOOL)containQuit;
+ (NSArray *)findAllInTeamExceptSelfWithTeamId:(NSString *)teamId sortBy:(NSString *)sortTerm;

+ (NSArray *)findAdminUsersInCurrentTeam;

#pragma mark - Find Topic User

//fetch topic members without self and sort with "name"
+ (NSArray *)findTopicMembersExceptSelfAndSortByNameWithTopicId:(NSString *)topicId;
+ (NSArray *)findAllInTopicWithTopicId:(NSString *)topicId containRobot:(BOOL)containRobot;
+ (NSArray *)findAllInTopicWithTopicId:(NSString *)topicId containRobot:(BOOL)containRobot inContext:(NSManagedObjectContext *)context;

//#pragma mark - Find Story User
//
//+ (NSArray *)findStoryMembersWithUserIds:(NSArray *)userIds exceptId:(NSString *)userId;

#pragma mark - Find User by Ids

+ (NSArray *)findUsersWithIds:(NSArray *)Ids;
+ (NSArray *)findUsersWithIds:(NSArray *)Ids NotIncludeIds:(NSArray *)otherIds;

#pragma mark - Find First User

//Talk AI
+ (MOUser *)TalkAI;

+ (MOUser *)currentUser;
+ (MOUser *)findFirstWithId:(NSString *)userId;
+ (MOUser *)findFirstWithId:(NSString *)userId inContext:(NSManagedObjectContext *)context;
+ (MOUser *)findFirstWithId:(NSString *)userId teamId:(NSString *)teamId;
+ (MOUser *)findFirstWithId:(NSString *)userId teamId:(NSString *)teamId inContext:(NSManagedObjectContext *)context;
// find all user who have same basic info(such as name, avatar, mobile ...)
+ (NSArray *)findAllUserWithId:(NSString *)userId inContext:(NSManagedObjectContext *)context;

@end
