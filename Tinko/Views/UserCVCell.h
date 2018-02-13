//
//  UserCVCell.h
//  Tinko
//
//  Created by Donghua Xue on 2/11/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserCVCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userUsernameLabel;

-(void) setCellDataWithUser:(User*)user;
@end
