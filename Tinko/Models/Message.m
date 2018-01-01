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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        //self.username = dictionary[@"username"];
        self.facebookId = dictionary[@"facebookId"];
        self.text = dictionary[@"text"];
        self.postTime = dictionary[@"postTime"];
        
        FIRDocumentReference *myDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:_facebookId];
        [myDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
            if (snapshot.exists) {
                //NSLog(@"Document data: %@", snapshot.data);
                NSDictionary *dic = snapshot.data;
                self.username = dic[@"username"];
                self.photoURL = dic[@"photoURL"];
                
            } else {
                NSLog(@"Document does not exist");
                self.username = @"NOT EXIST";
                self.photoURL = @"";
            }
        }];
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
