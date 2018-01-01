//
//  ThisUser.m
//  Tinko
//
//  Created by Donghua Xue on 12/31/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "ThisUser.h"

@implementation ThisUser
static User *_user = nil;
+ (id)thisUser {
    static ThisUser *thisUser = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thisUser = [[self alloc] init];
    });
    return thisUser;
}

- (id)init {
    if (self = [super init]) {
        _user = [[User alloc] init];
    }
    return self;
}

+(void)setThisUser:(User *)u {
    _user = u;
}

+(User *)getThisUser {
    return _user; // can return nil
}
@end
