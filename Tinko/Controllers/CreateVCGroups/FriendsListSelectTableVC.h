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
@end

@protocol FriendsListSelectTableVCDelegate
- (void)friendsListSelectTableVCDidFinish:(FriendsListSelectTableVC*)friendListSelectTableVC;
@end
