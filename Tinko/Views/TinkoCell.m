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

- (void)setCellData:(NSDictionary *)dic
{
    NSString *facebookId = dic[@"creator"];
    
    _title.text = dic[@"title"];
    NSDate *startTime = dic[@"startTime"];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, YYYY    hh:mm a"];
    self.time.text=[NSString stringWithFormat:@"%@",[formatter stringFromDate: startTime]];
    _placeName.text = dic[@"place"][@"name"];
    
    
    FIRDocumentReference *myDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:facebookId];
    [myDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot.exists) {
            //NSLog(@"Document data: %@", snapshot.data);
            NSDictionary *dic = snapshot.data;
            [self.creatorName setText: dic[@"username"]];
            [self.profileImage sd_setImageWithURL:[NSURL URLWithString:dic[@"photoURL"]]
                                 placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                          options:SDWebImageRefreshCached];
        } else {
            NSLog(@"Document does not exist");
            [self.creatorName setText:@"USERNAME"];
            
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
