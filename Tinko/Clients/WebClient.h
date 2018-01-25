//
//  WebClient.h
//  Tinko
//
//  Created by Donghua Xue on 1/7/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebClient : NSObject
-(void)participateOrLeaveMeetWithCode:(NSString*)code withMeetId:(NSString*)meetId withFacebookId:(NSString*)facebookId withCompletion:(void (^)(void))completion withError:(void (^)(NSString *error))errorBlock;

+(void)postMethodWithCode:(NSString*)code withData:(NSDictionary*)data withCompletion:(void (^)(void))completion withError:(void (^)(NSString *error))errorBlock;
@end
