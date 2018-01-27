//
//  CDMeet.m
//  Tinko
//
//  Created by Donghua Xue on 1/26/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "CDMyMeet.h"

@implementation CDMyMeet
@dynamic meetId;
@dynamic creatorFacebookId;
@dynamic title;
@dynamic startTime;
@dynamic postTime;
@dynamic placeName;
@dynamic placeAddress;
@dynamic allowPeopleNearby;
@dynamic duration;
@dynamic maxNo;
@dynamic discription;
@dynamic creatorUser;

+(void)createOrUpdateMeetWithMeet:(Meet*)meet withMeetId:(NSString*)meetId withCDUser:(CDUser*)cdUser withContext:(NSManagedObjectContext*)context{
    CDMyMeet *cdMeet = [NSEntityDescription insertNewObjectForEntityForName:@"CDMyMeet" inManagedObjectContext:context];
    cdMeet.meetId = meetId;
    cdMeet.creatorFacebookId = meet.creatorFacebookId;
    cdMeet.title = meet.title;
    cdMeet.startTime = meet.startTime;
    cdMeet.postTime = meet.postTime;
    cdMeet.placeName = meet.placeName;
    cdMeet.placeAddress = meet.placeAddress;
    cdMeet.allowPeopleNearby = meet.allowPeopleNearby;
    cdMeet.duration = meet.duration;
    cdMeet.maxNo = meet.maxNo;
    cdMeet.discription = meet.discription;
    cdMeet.creatorUser = cdUser;
    
//    NSError *error = nil;
//    if ([context hasChanges] && ![context save:&error]) {
//        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
//        abort();
//    }
}
@end
