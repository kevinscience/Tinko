//
//  NewFriendsRequestTVCell.m
//  Tinko
//
//  Created by Donghua Xue on 1/23/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "NewFriendsRequestTVCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation NewFriendsRequestTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void) setCellDataWithNewFriendsRequest:(NewFriendsRequest*)request{
    NSInteger *type = request.type;
    switch ((int)type) {
        case -1:
            [_acceptButton setHidden:YES];
            [_typeLable setText:@"Facebook"];
            break;
        case 0:
            [_typeLable setHidden:YES];
            break;
        case 1:
            [_acceptButton setHidden:YES];
            [_typeLable setText:@"Accepted"];
        default:
            break;
    }
    [self.usernameLabel setText:request.requesterUsername];
    [self.requestMessageLabel setText: request.requestMessage];
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:request.requesterPhotoURL]
                         placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                  options:SDWebImageRefreshCached];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
