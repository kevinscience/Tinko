//
//  TinkoCell.m
//  Tinko
//
//  Created by Donghua Xue on 12/24/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "TinkoCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@import Firebase;

@implementation TinkoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellData:(Meet *)meet withUser:(User *)user
{
    NSString *facebookId = meet.creatorFacebookId;
    
    _title.text = meet.title;
    NSDate *startTime = meet.startTime;
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, YYYY    hh:mm a"];
    self.time.text=[NSString stringWithFormat:@"%@",[formatter stringFromDate: startTime]];
    _placeName.text = meet.placeName;
    
    [self.creatorName setText:user.username];
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:user.photoURL]
                         placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                  options:SDWebImageRefreshCached];
}

- (void)setCellDataWithCDMeet:(CDMyMeet*)cdMeet{
    _title.text = cdMeet.title;
    NSDate *startTime = cdMeet.startTime;
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, YYYY    hh:mm a"];
    self.time.text=[NSString stringWithFormat:@"%@",[formatter stringFromDate: startTime]];
    _placeName.text = cdMeet.placeName;
    
    [self.creatorName setText:cdMeet.creatorUser.username];
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:cdMeet.creatorUser.photoURL]
                         placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                  options:SDWebImageRefreshCached];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
