//
//  User.h
//  Tinko
//
//  Created by Donghua Xue on 12/31/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *email;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
