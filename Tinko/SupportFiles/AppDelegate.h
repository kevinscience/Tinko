//
//  AppDelegate.h
//  Tinko
//
//  Created by Donghua Xue on 12/19/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@import Firebase;
@import FirebaseMessaging;

@interface AppDelegate : UIResponder <UIApplicationDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

