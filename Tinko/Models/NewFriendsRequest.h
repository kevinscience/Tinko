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
@property (nonatomic) NSInteger *type;
@property (nonatomic) BOOL read;
@property (nonatomic, strong) NSString *requestMessage;
@property (nonatomic, strong) NSString *requesterPhotoURL;
@property (nonatomic, strong) NSString *requesterUsername;

+(void)createNewFriendsRequestWithRequestDic:(NSDictionary*)requestDic withUserDic:(NSDictionary*)userDic withContext:(NSManagedObjectContext*)context;

+(void)updateNewFriendsRequestWithRequest:(NewFriendsRequest*)request WithRead:(BOOL)read withType:(NSInteger*)type withContext:(NSManagedObjectContext*)context;
@end
