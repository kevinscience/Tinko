//
//  TinkoDetailTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 2/6/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "TinkoDetailTableVC.h"
#import "SharedMeet.h"
#import "Meet.h"
#import "WebClient.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
@import Firebase;

@interface TinkoDetailTableVC ()
@property Meet *meet;
@property SharedMeet *sharedMeet;
@property NSString *facebookId;
@property BOOL participating;
@property User *creatorUser;
@property FIRFirestore *db;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *allowPeopleNearbyLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *participateButton;
@end

@implementation TinkoDetailTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _db = FIRFirestore.firestore;
    _sharedMeet = [SharedMeet sharedMeet];
    NSString *meetId = [_sharedMeet meetId];
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    
    FIRDocumentReference *meetRef = [[_db collectionWithPath:@"Meets"] documentWithPath:meetId];
    [meetRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (snapshot.exists) {
            //NSLog(@"Document data: %@", snapshot.data);
            NSDictionary *dic = snapshot.data;
            _meet = [[Meet alloc] initWithDictionary:dic];
            NSLog(@"TinkoDetail: %@", _meet.title);
            
            NSArray *participatedUsersList = _meet.participatedUsersList;
            _participating = [participatedUsersList containsObject:_facebookId];
            [_participateButton setTitle:_participating ? @"Participating" : @"Partcipate" forState:UIControlStateNormal];
            // Do any additional setup after loading the view from its nib.
            
            _titleLabel.text = _meet.title;
            NSDate *startTime = _meet.startTime;
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"MMM dd, YYYY    hh:mm a"];
            self.startTimeLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromDate: startTime]];
            _durationLabel.text = _meet.duration;
            _placeNameLabel.text = _meet.placeName;
            _placeAddressLabel.text = _meet.placeAddress;
            _maxNoLabel.text = [_meet.maxNo stringValue];
            _allowPeopleNearbyLabel.text = _meet.allowPeopleNearby ? @"YES" : @"NO";
            _descriptionLabel.text = _meet.discription;
            
            NSString *creatorFacebookId = _meet.creatorFacebookId;
            FIRDocumentReference *creatorDocRef = [[_db collectionWithPath:@"Users"] documentWithPath:creatorFacebookId];
            [creatorDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                if (snapshot.exists) {
                    //NSLog(@"Document data: %@", snapshot.data);
                    NSDictionary *dic = snapshot.data;
                    _creatorUser = [[User alloc] initWithDictionary:dic];
                    
                    _usernameLabel.text = _creatorUser.username;
                    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:_creatorUser.photoURL]
                        placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                        options:SDWebImageRefreshCached];
                } else {
                    NSLog(@"Document does not exist");
                    _creatorUser = [[User alloc] init];
                }
                [self.tableView reloadData];
            }];
            
        } else {
            NSLog(@"Document does not exist");
        }
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)participateButtonPressed:(id)sender {
    NSLog(@"participateButtonClicked");
    if(_participating){
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"TinkoDetailTable: participateButtonPressed: participating is NO");
    NSString *meetId = [_sharedMeet meetId];
    NSString *code = @"participateMeet";
    NSDictionary *dataDic = @{
                             @"userFacebookId" : _facebookId,
                             @"meetId" : meetId
                             };
    [WebClient postMethodWithCode:code withData:dataDic withCompletion:^{
        _participating = !_participating;
        [sender setTitle:@"Participating" forState:UIControlStateNormal];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } withError:^(NSString *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self presentAlertControllerWithError:error];
    }];
    
}

-(void)presentAlertControllerWithError:(NSString*)error{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
