#import "MOUser.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "constants.h"

@interface MOUser ()

// Private interface goes here.

@end

@implementation MOUser

// Custom logic goes here.

#pragma mark - Find All User

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate {
    NSArray *userArray = [MOUser MR_findAllWithPredicate:predicate];
    return userArray;
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    NSArray *userArray = [MOUser MR_findAllWithPredicate:predicate inContext:context];
    return userArray;
}

#pragma mark - Find Team User

+ (NSArray *)findAllInCurrentTeamWithContainRobot:(BOOL)containRobot  {
    NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSArray *teamUserArray = [MOUser findAllInTeamWithTeamId:currentTeamId containRobot:containRobot];
    return teamUserArray;
}

+ (NSArray *)findAllInCurrentTeamWithcontainQuit:(BOOL)containQuit  {
    NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSArray *teamUserArray = [MOUser findAllInTeamWithTeamId:currentTeamId containRobot:YES containQuit:containQuit];
    return teamUserArray;
}

+ (NSArray *)findAllQuitMembersInCurrentTeam {
    NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"isQuit = YES AND teams.id = %@", currentTeamId];
    NSArray *teamUserArray = [MOUser findAllWithPredicate:userFilter];
    return teamUserArray;
}

+ (NSArray *)findAllInTeamWithTeamId:(NSString *)teamId containRobot:(BOOL)containRobot {
    NSPredicate *userFilter;
    if (containRobot) {
        userFilter = [NSPredicate predicateWithFormat:@"teams.id = %@", teamId];
    } else {
        userFilter = [NSPredicate predicateWithFormat:@"isRobot = NO AND teams.id = %@", teamId];
    }
    NSArray *teamUserArray = [MOUser findAllWithPredicate:userFilter];
    return teamUserArray;
}

+ (NSArray *)findAllInTeamWithTeamId:(NSString *)teamId containRobot:(BOOL)containRobot containQuit:(BOOL)containQuit {
    NSPredicate *userFilter;
    if (containRobot) {
        if (containQuit) {
            userFilter = [NSPredicate predicateWithFormat:@"teams.id = %@", teamId];
        } else {
            userFilter = [NSPredicate predicateWithFormat:@"isQuit = NO AND teams.id = %@", teamId];
        }
    } else {
        if (containQuit) {
            userFilter = [NSPredicate predicateWithFormat:@"isRobot = NO AND teams.id = %@", teamId];
        } else {
            userFilter = [NSPredicate predicateWithFormat:@"isRobot = NO AND isQuit = NO AND teams.id = %@", teamId];
        }
    }
    NSArray *teamUserArray = [MOUser findAllWithPredicate:userFilter];
    
    return teamUserArray;
}

+ (NSArray *)findAllInTeamExceptSelfWithTeamId:(NSString *)teamId sortBy:(NSString *)sortTerm {
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    NSPredicate *memberFilter = [NSPredicate predicateWithFormat:@"id != %@ AND teams.id = %@",currentUserId, teamId];
    NSArray *userArray = [MOUser MR_findAllSortedBy:sortTerm ascending:YES withPredicate:memberFilter];
    
    return userArray;
}

+ (NSArray *)findAdminUsersInCurrentTeam {
    NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSPredicate *adminPredicate = [NSPredicate predicateWithFormat:@"(teams.id = %@) AND ((role = 'owner') OR (role = 'admin'))", currentTeamId];
    NSArray *adminUsers= [self findAllWithPredicate:adminPredicate];
    
    return adminUsers;
}

#pragma mark - Find Topic User

//fetch topic members without self and sort with "name"
+ (NSArray *)findTopicMembersExceptSelfAndSortByNameWithTopicId:(NSString *)topicId {
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    NSPredicate *memberFilter = [NSPredicate predicateWithFormat:@"id != %@ AND ANY rooms.id = %@", currentUserID, topicId];
    NSArray *memberArray = [MOUser MR_findAllSortedBy:@"name" ascending:YES withPredicate:memberFilter];
    
    return memberArray;
}

+ (NSArray *)findAllInTopicWithTopicId:(NSString *)topicId containRobot:(BOOL)containRobot {
    NSArray *teamUserArray = [MOUser findAllInTopicWithTopicId:topicId containRobot:containRobot inContext:nil];
    
    return teamUserArray;
}

+ (NSArray *)findAllInTopicWithTopicId:(NSString *)topicId containRobot:(BOOL)containRobot inContext:(NSManagedObjectContext *)context {
    NSPredicate *userFilter;
    if (containRobot) {
        userFilter = [NSPredicate predicateWithFormat:@"ANY rooms.id = %@", topicId];
    } else {
        userFilter = [NSPredicate predicateWithFormat:@"isRobot = NO AND ANY rooms.id = %@", topicId];
    }
    NSArray *teamUserArray;
    if (context) {
        teamUserArray = [MOUser findAllWithPredicate:userFilter inContext:context];
    } else {
        teamUserArray = [MOUser findAllWithPredicate:userFilter];
    }
    
    return teamUserArray;
}

//#pragma mark - Find Story User
//
//+ (NSArray *)findStoryMembersWithUserIds:(NSArray *)userIds exceptId:(NSString *)userId {
//    NSMutableArray *memberIds = [NSMutableArray arrayWithArray:userIds];
//    if ([memberIds containsObject:userId]) {
//        [memberIds removeObject:userId];
//    }
//    [memberIds enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj = [self uniqueUserIdWithUserId:obj teamId:nil];
//        [memberIds replaceObjectAtIndex:idx withObject:obj];
//    }];
//    NSArray *userArray = [MOUser MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(userID IN %@)", memberIds]];
//    
//    return userArray;
//}

#pragma mark - Find Users by Ids

+ (NSArray *)findUsersWithIds:(NSArray *)Ids {
    NSMutableArray *memberIds = [NSMutableArray arrayWithArray:Ids];
    [memberIds enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj = [self uniqueUserIdWithUserId:obj teamId:nil];
        [memberIds replaceObjectAtIndex:idx withObject:obj];
    }];
    NSArray *userArray = [MOUser MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(userID IN %@)", memberIds]];
    return userArray;
}

+ (NSArray *)findUsersWithIds:(NSArray *)Ids NotIncludeIds:(NSArray *)otherIds {
    NSMutableArray *memberIds = [NSMutableArray arrayWithArray:Ids];
    for (NSString *memberId in Ids) {
        if ([otherIds containsObject:memberId]) {
            [memberIds removeObject:memberId];
        }
    }
    [memberIds enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj = [self uniqueUserIdWithUserId:obj teamId:nil];
        [memberIds replaceObjectAtIndex:idx withObject:obj];
    }];
    NSArray *userArray = [MOUser MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(userID IN %@)", memberIds]];
    return userArray;
}

#pragma mark - Find First USer

+ (MOUser *)TalkAI {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    MOUser *talkAI = [MOUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(isRobot = YES) AND (service = %@) AND (teams.id = %@)", @"talkai",currentTeamID]];
    return talkAI;
}

+ (MOUser *)currentUser {
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    MOUser *currentUser = [MOUser findFirstWithId:currentUserID];
    return currentUser;
}

+ (MOUser *)findFirstWithId:(NSString *)userId {
    NSString *uniqueUserID = [self uniqueUserIdWithUserId:userId teamId:nil];
    MOUser *user = [MOUser MR_findFirstByAttribute:@"userID" withValue:uniqueUserID];
    return user;
}

+ (MOUser *)findFirstWithId:(NSString *)userId inContext:(NSManagedObjectContext *)context {
    NSString *uniqueUserID = [self uniqueUserIdWithUserId:userId teamId:nil];
    MOUser *user = [MOUser MR_findFirstByAttribute:@"userID" withValue:uniqueUserID inContext:context];
    return user;
}

+ (MOUser *)findFirstWithId:(NSString *)userId teamId:(NSString *)teamId {
    NSString *uniqueUserID = [self uniqueUserIdWithUserId:userId teamId:teamId];
    NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"userID = %@ AND teams.id = %@",uniqueUserID, teamId];
    MOUser *user = [MOUser MR_findFirstWithPredicate:userFilter];
    return user;
}

+ (MOUser *)findFirstWithId:(NSString *)userId teamId:(NSString *)teamId inContext:(NSManagedObjectContext *)context {
    NSString *uniqueUserID = [self uniqueUserIdWithUserId:userId teamId:teamId];
    NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"userID = %@ AND teams.id = %@",uniqueUserID, teamId];
    MOUser *user = [MOUser MR_findFirstWithPredicate:userFilter inContext:context];
    return user;
}

// find all user who have same basic info(such as name, avatar, mobile ...)
+ (NSArray *)findAllUserWithId:(NSString *)userId inContext:(NSManagedObjectContext *)context {
    NSArray *userArray = [MOUser MR_findByAttribute:@"id" withValue:userId inContext:context];
    return userArray;
}

#pragma mark - Private Methods

+ (NSString *)uniqueUserIdWithUserId:(NSString *)userId  teamId:(NSString *)teamId {
    NSString *currentTeamID;
    if (teamId) {
        currentTeamID = teamId;
    } else {
        currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    }
    if (currentTeamID && userId) {
        NSString *uniqueUserID = [currentTeamID stringByAppendingString:userId];
        return uniqueUserID;
    } else {
        return userId;
    }
}

@end
