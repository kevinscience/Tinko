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

+(void)createNewFriendsRequestWithDic:(NSDictionary*)dic withContext:(NSManagedObjectContext*)context{
    NewFriendsRequest *request = [NSEntityDescription insertNewObjectForEntityForName:@"NewFriendsRequest" inManagedObjectContext:context];
    request.requester = dic[@"requester"];
    request.requestTime = dic[@"requestTime"];
    request.type = dic[@"type"];
    request.read = [[dic objectForKey:@"read"] boolValue];
    
}
@end
