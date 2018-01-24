//
//  NewFriendsRequest.m
//  Tinko
//
//  Created by Donghua Xue on 1/23/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "NewFriendsRequest.h"

@implementation NewFriendsRequest
@dynamic requester;
@dynamic requestTime;
@dynamic type;
@dynamic read;
@dynamic requestMessage;
@dynamic requesterPhotoURL;
@dynamic requesterUsername;

+(void)createNewFriendsRequestWithRequestDic:(NSDictionary*)requestDic withUserDic:(NSDictionary*)userDic withContext:(NSManagedObjectContext*)context{
    NewFriendsRequest *request = [NSEntityDescription insertNewObjectForEntityForName:@"NewFriendsRequest" inManagedObjectContext:context];
    request.requester = requestDic[@"requester"];
    request.requestTime = requestDic[@"requestTime"];
    NSNumber *typeNumber = requestDic[@"type"];
    request.type = [typeNumber integerValue];
    request.read = [[requestDic objectForKey:@"read"] boolValue];
    request.requestMessage = requestDic[@"requestMessage"];
    
    request.requesterPhotoURL = userDic[@"photoURL"];
    request.requesterUsername = userDic[@"username"];
}

+(void)updateNewFriendsRequestWithRequest:(NewFriendsRequest*)request WithRead:(BOOL)read withType:(NSInteger*)type withContext:(NSManagedObjectContext*)context{
    request.read = read;
    request.type = type;
    
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}
@end
