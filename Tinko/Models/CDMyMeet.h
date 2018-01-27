//
//  CDMeet.h
//  Tinko
//
//  Created by Donghua Xue on 1/26/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CDUser.h"
#import "Meet.h"

@interface CDMyMeet : NSManagedObject
@property (nonatomic, strong) NSString *meetId;
@property (nonatomic, strong) NSString *creatorFacebookId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *postTime;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeAddress;
@property (nonatomic) BOOL allowPeopleNearby;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSNumber *maxNo;
@property (nonatomic, strong) NSString *discription;

@property (nonatomic, strong) CDUser *creatorUser;

+(void)createOrUpdateMeetWithMeet:(Meet*)meet withMeetId:(NSString*)meetId withCDUser:(CDUser*)cdUser withContext:(NSManagedObjectContext*)context;
@end
