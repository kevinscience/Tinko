//
//  UserCVCell.m
//  Tinko
//
//  Created by Donghua Xue on 2/11/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "UserCVCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UserCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setCellDataWithUser:(User*)user{
    [self.userUsernameLabel setText:user.username];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:user.photoURL]
                         placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                  options:SDWebImageRefreshCached];
}

@end
