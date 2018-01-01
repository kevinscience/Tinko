//
//  SharedMeet.h
//  Tinko
//
//  Created by Donghua Xue on 12/30/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Meet.h"

@interface SharedMeet : NSObject

@property (nonatomic, retain) Meet *meet;
@property (nonatomic, strong) NSString *meetId;

+(id)sharedMeet;
+(void)setSharedMeet:(Meet *)m withMeetId:(NSString *)mId;
+(Meet*)clickedMeet;

@end
