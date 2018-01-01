//
//  User.m
//  Tinko
//
//  Created by Donghua Xue on 12/31/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.username = dictionary[@"username"];
        self.uid = dictionary[@"uid"];
        self.photoURL = dictionary[@"photoURL"];
        self.location = dictionary[@"location"];
        self.gender = dictionary[@"gender"];
        self.facebookId = dictionary[@"facebookId"];
        self.email = dictionary[@"email"];
    }
    
    return self;
}

@end
