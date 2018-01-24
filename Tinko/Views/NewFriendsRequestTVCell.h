//
//  NewFriendsRequestTVCell.h
//  Tinko
//
//  Created by Donghua Xue on 1/23/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFriendsRequest.h"

@interface NewFriendsRequestTVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLable;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

-(void) setCellDataWithNewFriendsRequest:(NewFriendsRequest*)request;
@end
