//
//  Friend.m
//  CoreDataTest
//
//  Created by Donghua Xue on 1/17/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "CDUser.h"

@implementation CDUser
@dynamic username;
@dynamic uid;
@dynamic email;
@dynamic facebookId;
@dynamic gender;
@dynamic location;
@dynamic photoURL;

+(void) createOrUpdateCDUserWithUser:(User*)user withContext:(NSManagedObjectContext*)context{
    CDUser *cdUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:context];
    cdUser.uid = user.uid;
    cdUser.username = user.username;
    cdUser.email = user.email;
    cdUser.facebookId = user.facebookId;
    cdUser.gender = user.gender;
    cdUser.location = user.location;
    cdUser.photoURL = user.photoURL;
}
@end
