//
//  SharedMeet.m
//  Tinko
//
//  Created by Donghua Xue on 12/30/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "SharedMeet.h"

@implementation SharedMeet
static Meet *_meet = nil;
static NSString *_meetId = nil;
+ (id)sharedMeet {
    static SharedMeet *sharedMeet = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMeet = [[self alloc] init];
    });
    return sharedMeet;
}

- (id)init {
    if (self = [super init]) {
        _meet = [[Meet alloc] init];
        _meetId = @"";
    }
    return self;
}

+(void)setSharedMeet:(Meet *)m withMeetId:(NSString *)mId {
    _meet = m;
    _meetId = mId;
}

+(Meet*)clickedMeet {
    return _meet; // can return nil
}
@end
