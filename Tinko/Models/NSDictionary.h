//
//  NSDictionary.h
//  Tinko
//
//  Created by Donghua Xue on 1/8/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end
