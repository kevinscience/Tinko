//
//  ThisUser.h
//  Tinko
//
//  Created by Donghua Xue on 12/31/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ThisUser : NSObject

@property (nonatomic, retain) User *user;

+(id)thisUser;
+(void)setThisUser:(User *)u;
+(User*)getThisUser;

@end
