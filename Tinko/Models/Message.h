//
//  Message.h
//  Messenger
//
//  Created by Ignacio Romero Z. on 1/16/15.
//  Copyright (c) 2015 Slack Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface Message : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *postTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withUser:(User*)user;
- (instancetype)initWithFullDataDictionary:(NSDictionary *)dictionary;

@end
