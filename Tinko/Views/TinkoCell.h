//
//  TinkoCell.h
//  Tinko
//
//  Created by Donghua Xue on 12/24/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TinkoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *creatorName;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
- (void)setCellData:(NSDictionary *)dic;
@end
