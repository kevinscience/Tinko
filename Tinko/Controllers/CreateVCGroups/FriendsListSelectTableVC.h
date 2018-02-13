//
//  FriendsListSelectTableVC.h
//  Tinko
//
//  Created by Donghua Xue on 12/22/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendsListSelectTableVCDelegate;

@interface FriendsListSelectTableVC : UITableViewController
@property (nonatomic, assign) id<FriendsListSelectTableVCDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* selectedFriendsArray;
@property (nonatomic) BOOL allowPeopleNearby;
@property (nonatomic) BOOL allFriends;
@property (nonatomic) BOOL allowParticipantsInvite;
@end

@protocol FriendsListSelectTableVCDelegate
- (void)friendsListSelectTableVCDidFinish:(FriendsListSelectTableVC*)friendListSelectTableVC;
@end
