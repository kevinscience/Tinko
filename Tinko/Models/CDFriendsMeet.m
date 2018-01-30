//
//  CDFriendsMeet.m
//  Tinko
//
//  Created by Donghua Xue on 1/27/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "CDFriendsMeet.h"

@implementation CDFriendsMeet

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
@dynamic creatorUsername;
@dynamic creatorPhotoURL;

+(void)createOrUpdateMeetWithMeet:(Meet*)meet withMeetId:(NSString*)meetId withUser:(User*)user withContext:(NSManagedObjectContext*)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDFriendsMeet"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"meetId == %@", meetId]];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if(count == 0){
        CDFriendsMeet *cdMeet = [NSEntityDescription insertNewObjectForEntityForName:@"CDFriendsMeet" inManagedObjectContext:context];
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
        cdMeet.creatorUsername = user.username;
        cdMeet.creatorPhotoURL = user.photoURL;
    } else {
        [fetchRequest setFetchLimit:1];
        NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
        CDFriendsMeet *cdMeet = array[0];
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
        cdMeet.creatorUsername = user.username;
        cdMeet.creatorPhotoURL = user.photoURL;
    }

    
    //    NSError *error = nil;
    //    if ([context hasChanges] && ![context save:&error]) {
    //        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    //        abort();
    //    }
}
@end
