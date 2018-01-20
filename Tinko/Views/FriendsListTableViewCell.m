//
//  FriendsListTableViewCell.m
//  Tinko
//
//  Created by Donghua Xue on 12/20/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "FriendsListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@import Firebase;

@interface FriendsListTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property NSString *facebookId;
@end


@implementation FriendsListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellData:(User *)user
{
    _facebookId = user.facebookId;
    [self.header setText: user.username];
    [self.image sd_setImageWithURL:[NSURL URLWithString:user.photoURL]
                  placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                           options:SDWebImageRefreshCached];
    
}

- (void)setCellDataWithFriend:(CDUser *)cdUser{
    [self.header setText: cdUser.username];
    [self.image sd_setImageWithURL:[NSURL URLWithString:cdUser.photoUrl]
                  placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                           options:SDWebImageRefreshCached];
}



-(void)setInvitationCellData{
    [self.header setText:@"Invite Friends"];
    [self.image setImage:[UIImage imageNamed:@"inviteIcon"]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
