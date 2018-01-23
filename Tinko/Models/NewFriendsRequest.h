//
//  NewFriendsRequest.h
//  Tinko
//
//  Created by Donghua Xue on 1/23/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NewFriendsRequest : NSManagedObject
@property (nonatomic, strong) NSString *requester;
@property (nonatomic, strong) NSNumber *requestTime;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic) BOOL read;

+(void)createNewFriendsRequestWithDic:(NSDictionary*)dic withContext:(NSManagedObjectContext*)context;


@end
