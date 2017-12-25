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

- (void)setCellData:(NSDictionary *)dic
{
    _facebookId = dic[@"facebookId"];
    [self.header setText: dic[@"username"]];
    [self.image sd_setImageWithURL:[NSURL URLWithString:dic[@"photoURL"]]
                  placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                           options:SDWebImageRefreshCached];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
