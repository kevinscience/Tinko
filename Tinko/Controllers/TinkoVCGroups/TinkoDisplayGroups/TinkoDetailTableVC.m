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
#import "UserCVCell.h"
#import "FriendDetailTVC.h"
@import Firebase;
@import GooglePlaces;

@interface TinkoDetailTableVC ()
@property Meet *meet;
@property SharedMeet *sharedMeet;
@property NSString *facebookId;
@property BOOL participating;
@property User *creatorUser;
@property FIRFirestore *db;
@property NSString *meetId;
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
@property (weak, nonatomic) IBOutlet UILabel *participantsLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *participantsCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *placePhotoImageView;
@property BOOL participantsListShow;
@property NSInteger itemsInCV;
@property NSArray *participatedUserFacebookIdList;
@property NSMutableArray *participatedUsersList;
@property BOOL allowParticipantsInvite;
@property BOOL isCreator;
@end

@implementation TinkoDetailTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _db = FIRFirestore.firestore;
    _sharedMeet = [SharedMeet sharedMeet];
    _meetId = [_sharedMeet meetId];
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    _participantsListShow = NO;
    _participatedUsersList = [[NSMutableArray alloc] init];
    
    [self addMeetListener];
    
    _participantsCollectionView.delegate = self;
    _participantsCollectionView.dataSource = self;
    
    UITapGestureRecognizer *imageClickRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClicked)];
    UITapGestureRecognizer *usernameClickRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usernameClicked)];
    [_profileImage setUserInteractionEnabled:YES];
    [_usernameLabel setUserInteractionEnabled:YES];
    [_profileImage addGestureRecognizer:imageClickRecognizer];
    [_usernameLabel addGestureRecognizer:usernameClickRecognizer];
    
}

-(void)addMeetListener{
    FIRDocumentReference *meetRef = [[_db collectionWithPath:@"Meets"] documentWithPath:_meetId];
    [meetRef addSnapshotListener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (snapshot.exists) {
            //NSLog(@"Document data: %@", snapshot.data);
            NSDictionary *dic = snapshot.data;
            _meet = [[Meet alloc] initWithDictionary:dic];
            NSLog(@"TinkoDetail: %@", _meet.title);
            [self setupMeetUI];
            
            NSString *creatorFacebookId = _meet.creatorFacebookId;
            FIRDocumentReference *creatorDocRef = [[_db collectionWithPath:@"Users"] documentWithPath:creatorFacebookId];
            [creatorDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                if (snapshot.exists) {
                    //NSLog(@"Document data: %@", snapshot.data);
                    NSDictionary *dic = snapshot.data;
                    _creatorUser = [[User alloc] initWithDictionary:dic];
                    [self setupCreatorUserUI];
                    
                } else {
                    NSLog(@"Document does not exist");
                    _creatorUser = [[User alloc] init];
                }
                [self.tableView reloadData];
                if(_participantsListShow){
                    [self getParticipantsDataFromFirestore];
                }
            }];
            
        } else {
            NSLog(@"Document does not exist");
        }
    }];
}

-(void)setupMeetUI{
    //[self loadFirstPhotoForPlace];
    _allowParticipantsInvite = _meet.allowParticipantsInvite;
    //NSLog(allowParticipantsInvite ? @"allowParticipantsInvite YES" : @"allowParticipantsInviteNO");
    _participatedUserFacebookIdList = _meet.participatedUsersList;
    _participating = [_participatedUserFacebookIdList containsObject:_facebookId];
    _isCreator = [_facebookId isEqualToString:_meet.creatorFacebookId];
    _itemsInCV = [_participatedUserFacebookIdList count];
    if(!_isCreator && _participating){
        _itemsInCV++;
    }
    if(!_isCreator && _allowParticipantsInvite && _participating){
        _itemsInCV++;
    }
    [_participateButton setTitle:_participating ? @"Participating" : @"Partcipate" forState:UIControlStateNormal];
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
    NSInteger amountOfParticipants = [_meet.participatedUsersList count];
    [_participantsLabel setText:[NSString stringWithFormat:@"%ld", (long)amountOfParticipants]];
}

-(void)setupCreatorUserUI{
    _usernameLabel.text = _creatorUser.username;
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:_creatorUser.photoURL]
                         placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                  options:SDWebImageRefreshCached];
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

-(void)usernameClicked{
    [self userClicked];
}
-(void)userClicked{
    NSLog(@"single Tap on creatorUser");
    FriendDetailTVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendDetailTVCID"];
    secondView.showingUserFacebookId = _creatorUser.facebookId;
    secondView.user = _creatorUser;
    secondView.isCDUser = NO;
    secondView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: secondView animated:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 3){
        if(_participantsListShow){
            [self hideParticipantsCVCell];
            
        } else{
            [self getParticipantsDataFromFirestore];
            [self showParticipantsCVCell];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if(indexPath.section == 0){
        //NSLog(@"TinkoDetailTable: heightForRow: indexpath.row = %ld", (long)indexPath.row);
        switch (indexPath.row) {
            case 0:
                height = 100.0f;
                break;
            case 1:
                height = 78;
                break;
            case 2:
                height = 78;
                break;
            case 3:
                break;
            case 4:
                if(_participantsListShow){
                    NSInteger rows = (NSInteger)ceil(_itemsInCV / 5.0);
                    height = rows * 75.0f + (rows+1)* 10.0f;
                } else {
                    height = 0.0f;
                }
                break;
            case 5:
                height = 78;
                break;
                
            default:
                break;
        }
    } else {
        height = 40.0f;
    }
    return height;
}

- (void)showParticipantsCVCell {
    self.participantsListShow = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.participantsCollectionView.alpha = 1.0f;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.participantsCollectionView.alpha = 1.0f;
                     } completion:^(BOOL finished){
                         self.participantsCollectionView.hidden = NO;
                     }];
}

- (void)hideParticipantsCVCell {
    self.participantsListShow = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.participantsCollectionView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.participantsCollectionView.hidden = YES;
                     }];
    
}

-(void)getParticipantsDataFromFirestore{
    // NEED MORE CONTROL CONDITION
    if(_participatedUserFacebookIdList.count == _participatedUsersList.count){
        return;
    }
    [_participatedUsersList removeAllObjects];
    for(NSString *userFacebookId in _participatedUserFacebookIdList){
        FIRDocumentReference *userRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:userFacebookId];
        [userRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
            if (snapshot.exists) {
                //NSLog(@"Document data: %@", snapshot.data);
                NSDictionary *dic = snapshot.data;
                User *user = [[User alloc] initWithDictionary:dic];
                [_participatedUsersList addObject:user];
    
                [_participantsCollectionView reloadData];
            } else {
                NSLog(@"Document does not exist");
            }
        }];
    }
}


- (CGFloat)getLabelHeight:(UILabel*)label
{
    double labelWidth = self.view.frame.size.width-32.0;
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, 50)];
    myLabel.font = [UIFont systemFontOfSize:17];
    myLabel.text = _meet.description;
    myLabel.numberOfLines = 0;
    
    CGSize constraint = CGSizeMake(myLabel.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [myLabel.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:myLabel.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

//
//- (void)loadFirstPhotoForPlace{
//    NSLog(@"TinkoDetailTable: loadFirstPhotoForPlace: placeId: %@", _meet.placeId);
//    [[GMSPlacesClient sharedClient]
//     lookUpPhotosForPlaceID:_meet.placeId
//     callback:^(GMSPlacePhotoMetadataList *_Nullable photos,
//                NSError *_Nullable error) {
//         if (error) {
//             // TODO: handle the error.
//             NSLog(@"Error: %@", [error description]);
//         } else {
//             NSLog(@"TinkoDetailTable: loadFirstPhotoForPlace: photos.count = %lu", photos.results.count);
//             if (photos.results.count > 0) {
//                 GMSPlacePhotoMetadata *firstPhoto = photos.results.firstObject;
//                 [self loadImageForMetadata:firstPhoto];
//             }
//         }
//     }];
//}
//
//- (void)loadImageForMetadata:(GMSPlacePhotoMetadata *)photoMetadata {
//    [[GMSPlacesClient sharedClient]
//     loadPlacePhoto:photoMetadata
//     constrainedToSize:self.placePhotoImageView.bounds.size
//     scale:self.placePhotoImageView.window.screen.scale
//     callback:^(UIImage *_Nullable photo, NSError *_Nullable error) {
//         if (error) {
//             // TODO: handle the error.
//             NSLog(@"Error: %@", [error description]);
//         } else {
//             self.placePhotoImageView.image = photo;
//             //self.attributionTextView.attributedText = photoMetadata.attributions;
//         }
//     }];
//}


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


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(!_isCreator && _participating && _allowParticipantsInvite && indexPath.row == _itemsInCV-2){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"plusCell" forIndexPath:indexPath];
        return cell;
    }
    
    if(!_isCreator && _participating && indexPath.row == _itemsInCV - 1){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"deleteCell" forIndexPath:indexPath];
        return cell;
    }
    
    
    UserCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    User *user;
    @try{
        user = _participatedUsersList[indexPath.row];
    }
    @catch(NSException *e){
        user = [[User alloc] init];
    }
    @finally{
        
    }
    [cell setCellDataWithUser: user];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //NSLog(@"TinkoDetailTable: numberOfItems: %lu", (unsigned long)[_participatedUsersList count]);
//    _itemsInCV = [_participatedUsersList count] + 1;
//    if(_allowParticipantsInvite){
//        _itemsInCV++;
//    }
    return _itemsInCV;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(!_isCreator && _participating && _allowParticipantsInvite && indexPath.row == _itemsInCV-2){
        return;
    }
    if(!_isCreator && _participating && indexPath.row == _itemsInCV - 1){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Leave" message:@"Are you sure to leave?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSString *meetId = [_sharedMeet meetId];
            NSString *code = @"leaveMeet";
            NSDictionary *dataDic = @{
                                      @"userFacebookId" : _facebookId,
                                      @"meetId" : meetId
                                      };
            [WebClient postMethodWithCode:code withData:dataDic withCompletion:^{
                _participating = !_participating;
                //[sender setTitle:@"Participating" forState:UIControlStateNormal];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationController popViewControllerAnimated:YES];
            } withError:^(NSString *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self presentAlertControllerWithError:error];
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Other action
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    FriendDetailTVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendDetailTVCID"];
    User *user = _participatedUsersList[indexPath.row];
    secondView.showingUserFacebookId = user.facebookId;
    secondView.user = user;
    secondView.isCDUser = NO;
    secondView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: secondView animated:YES];
    
    
}

#pragma mark - UICollectionViewDelegateFlowLayout



- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
   sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = screenWidth / 5.0; //Replace the divisor with the column count requirement. Make sure to have it in float.
//    CGFloat screenHeight = screenRect.size.height;
//    float cellHeight = screenHeight/3.0;


    CGSize size = CGSizeMake(50.0f, 75.0f);


    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat top = 10.0f;
    CGFloat bottom = 5.0f;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat edgeInsets = (screenWidth-50.0f*5.0) / (5.0 + 1.0);
    return UIEdgeInsetsMake(top, edgeInsets, bottom, edgeInsets);
}


//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    <#code#>
//}

//- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 3;
//}

//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
