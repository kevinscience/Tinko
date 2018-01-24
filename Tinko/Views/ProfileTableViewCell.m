
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

- (void)setCellDataWithUser:(User*)user
{
    [self.header setText: user.username];
    [self.body setText: user.facebookId];
    [self.image sd_setImageWithURL:[NSURL URLWithString:user.photoURL]
                  placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                           options:SDWebImageRefreshCached];
    [self.body setTextColor:[UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0]];
//    [self.image sd_setImageWithURL:[NSURL URLWithString:(message.avatarURL).absoluteString]
//                 placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
//                          options:SDWebImageRefreshCached];
//    self.image.layer.cornerRadius = self.image.frame.size.width/2;
//    self.image.clipsToBounds = YES;
}

- (void)setCellDataWithCDUser:(CDUser*)cdUser
{
    [self.header setText: cdUser.username];
    [self.body setText: cdUser.facebookId];
    [self.image sd_setImageWithURL:[NSURL URLWithString:cdUser.photoURL]
                  placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                           options:SDWebImageRefreshCached];
    [self.body setTextColor:[UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0]];
}


@end
