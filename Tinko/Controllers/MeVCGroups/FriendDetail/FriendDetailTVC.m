//
//  FriendDetailTVC.m
//  Tinko
//
//  Created by Donghua Xue on 1/20/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "FriendDetailTVC.h"
#import "CDUser.h"
#import "ProfileTableViewCell.h"
#import "AppDelegate.h"
#import "WebClient.h"
@import CoreData;

@interface FriendDetailTVC ()
@property BOOL isFriend;
@property(weak, nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UIButton *isFriendButton;
@property (nonatomic, strong) WebClient *client;
@end

@implementation FriendDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"showingUserFacebookId: %@", _showingUserFacebookId);
    _client = [[WebClient alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"facebookId == %@", _showingUserFacebookId]];
    NSError *error = nil;
    NSInteger count = [_context countForFetchRequest:fetchRequest error:&error];
    _isFriend = count != 0 ? YES : NO;
    NSLog(@"FriendDetailTVC: count: %ld", (long)count);
    
    //_isFriendButton.titleLabel.text = _isFriend ? @"Already Friends" : @"Add Friend";
    [_isFriendButton setTitle:_isFriend ? @"Already Friends" : @"Add Friend" forState:UIControlStateNormal];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)isFriendButtonPressed:(id)sender {
    //NSLog(@"FriendDetailTVC: isFriendButtonPressed");
    if(!_isFriend){
        NSLog(@"FriendDetailTVC: isFriendButtonPressed: addFriend");
         NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
        NSDictionary *requestDic = @{
                                     @"requester": facebookId,
                                     @"responsor": _showingUserFacebookId
                                     };
        [_client postMethodWithCode:@"sendAddFriendRequest" withData:requestDic withCompletion:^{
            
        } withError:^(NSString *error) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    }
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0){
        ProfileTableViewCell *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileTableViewCell" owner:self options:nil];
            cell = (ProfileTableViewCell *)[nib objectAtIndex:0];
        }
        if(_isCDUser){
            [cell setCellDataWithCDUser:_cdUser];
        } else {
            [cell setCellDataWithUser:_user];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    } else {
        UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            height = 80.0f;
        }
    }
    return height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
