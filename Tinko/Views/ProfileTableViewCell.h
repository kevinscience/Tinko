//
//  ChatTableViewCell.h
//  iOSTest
//
//  Created by App Partner on 9/23/16.
//  Copyright © 2016 AppPartner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileTableViewCell : UITableViewCell

- (void)setCellDataWithUser:(User*)user;

@end
