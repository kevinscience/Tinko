//
//  InvitationRangeOptionTVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/22/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "InvitationRangeOptionTVC.h"

@implementation InvitationRangeOptionTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellData:(NSDictionary *)dic
{
    NSString *optionName = dic[@"optionName"];
    [self.optionLabel setText: optionName];
    
    BOOL option = [dic[@"option"] boolValue];
    [self.optionSwitch setOn:option];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
