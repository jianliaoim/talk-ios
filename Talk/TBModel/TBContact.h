//
//  TBContact.h
//  Talk
//
//  Created by 史丹青 on 6/26/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface TBContact : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *pinyin;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *originPhone;
@property (copy, nonatomic) UIImage *avator;
@property (assign, nonatomic) BOOL hasAvator;
@property (assign, nonatomic) BOOL isInTeam;
@property (assign, nonatomic) BOOL isInvited;
+ (NSArray *)fetchTeamContactsWithTeamId:(NSString *)teamId ABAddressBookRef:(ABAddressBookRef)addressbook;
@end
