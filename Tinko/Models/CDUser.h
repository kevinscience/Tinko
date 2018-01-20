//
//  Friend.h
//  CoreDataTest
//
//  Created by Donghua Xue on 1/17/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "User.h"

@interface CDUser : NSManagedObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *photoUrl;


+(void) createOrUpdateCDUserWithUser:(User*)user withContext:(NSManagedObjectContext*)context;
@end
