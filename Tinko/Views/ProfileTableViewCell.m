
#import "ProfileTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "User.h"
#import "ThisUser.h"
@import Firebase;

@interface ProfileTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (weak, nonatomic) IBOutlet UIImageView *image;


@end

@implementation ProfileTableViewCell


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setCellData
{
    NSString *facebookId = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookId"];
    FIRDocumentReference *myDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:facebookId];
    [myDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot.exists) {
            //NSLog(@"Document data: %@", snapshot.data);
            NSDictionary *dic = snapshot.data;
            User *user = [[User alloc] initWithDictionary:dic];
            ThisUser *thisUser = [ThisUser thisUser];
            [thisUser setUser:user];
            NSString *facebookId = user.facebookId;
            [self.header setText: user.username];
            [self.body setText: facebookId];
            [self.image sd_setImageWithURL:[NSURL URLWithString:user.photoURL]
                              placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                       options:SDWebImageRefreshCached];
        } else {
            NSLog(@"Document does not exist");
            [self.header setText:@"USERNAME"];
            [self.body setText:@"ERROR"];
        }
    }];
    
    [self.body setTextColor:[UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0]];
//    [self.image sd_setImageWithURL:[NSURL URLWithString:(message.avatarURL).absoluteString]
//                 placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
//                          options:SDWebImageRefreshCached];
//    self.image.layer.cornerRadius = self.image.frame.size.width/2;
//    self.image.clipsToBounds = YES;
}

@end
