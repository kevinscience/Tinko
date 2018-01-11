//
//  Message.m
//  Messenger
//
//  Created by Ignacio Romero Z. on 1/16/15.
//  Copyright (c) 2015 Slack Technologies, Inc. All rights reserved.
//

#import "Message.h"
@import Firebase;

@implementation Message

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withUser:(User*)user
{
    self = [super init];
    if (self)
    {
        //self.username = dictionary[@"username"];
        self.facebookId = dictionary[@"facebookId"];
        self.text = dictionary[@"text"];
        self.postTime = dictionary[@"postTime"];
        
        self.username = user.username;
        self.photoURL = user.photoURL;
    }
    
    return self;
}


- (instancetype)initWithFullDataDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        //self.username = dictionary[@"username"];
        self.facebookId = dictionary[@"facebookId"];
        self.text = dictionary[@"text"];
        self.postTime = dictionary[@"postTime"];
        self.username = dictionary[@"username"];
        self.photoURL = dictionary[@"photoURL"];
        
    }
    
    return self;
}


@end
