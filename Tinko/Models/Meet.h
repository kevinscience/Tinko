//
//  Meets.h
//  Tinko
//
//  Created by Donghua Xue on 12/25/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//
#import <Foundation/Foundation.h>
@import Firebase;

@interface Meet : NSObject

@property (nonatomic, strong) NSString *creatorFacebookId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *postTime;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeAddress;
@property (nonatomic, strong) FIRGeoPoint *placeCoordinate;
@property (nonatomic) BOOL allowPeopleNearby;
@property (nonatomic, strong) NSArray *participatedUsersList;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSNumber *maxNo;
@property (nonatomic, strong) NSString *discription;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)init;
@end
