//
//  FriendDetailTVC.h
//  Tinko
//
//  Created by Donghua Xue on 1/20/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDUser.h"
#import "User.h"

@interface FriendDetailTVC : UITableViewController
@property NSString *showingUserFacebookId;
@property CDUser *cdUser;
@property User *user;
@property BOOL isCDUser;
@end
