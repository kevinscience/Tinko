//
//  InvitationRangeOptionTVC.h
//  Tinko
//
//  Created by Donghua Xue on 12/22/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitationRangeOptionTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *optionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *optionSwitch;
- (void)setCellData:(NSDictionary *)dic;
@end
