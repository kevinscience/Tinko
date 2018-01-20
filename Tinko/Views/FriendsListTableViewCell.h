//
//  FriendsListTableViewCell.h
//  Tinko
//
//  Created by Donghua Xue on 12/20/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "CDUser.h"

@interface FriendsListTableViewCell : UITableViewCell
- (void)setCellData:(User *)user;
- (void)setCellDataWithFriend:(CDUser *)cdUser;
-(void)setInvitationCellData;
@end
