//
//  Meets.m
//  Tinko
//
//  Created by Donghua Xue on 12/25/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//
#import "Meet.h"

@implementation Meet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        //NSLog(@"Meet: dictionary: %@", dictionary);
        self.creatorFacebookId = dictionary[@"creator"];
        self.title = dictionary[@"title"];
        self.startTime = dictionary[@"startTime"];
        self.postTime = dictionary[@"postTime"];
        self.placeName = dictionary[@"place"][@"name"];
        self.placeAddress = dictionary[@"place"][@"address"];
        self.placeCoordinate = dictionary[@"place"][@"coordinate"];
        self.allowPeopleNearby = dictionary[@"allowPeopleNearby"];
        NSDictionary *dicForParticipatedUsersList = dictionary[@"participatedUsersList"];
        self.participatedUsersList = [dicForParticipatedUsersList allKeys];
        self.duration = dictionary[@"duration"];
        self.maxNo = dictionary[@"maxNo"];
        self.discription = dictionary[@"description"];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.creatorFacebookId = @"";
        self.title = @"";
        self.startTime = nil;
        self.placeName = @"";
    }
    
    return self;
}


@end

