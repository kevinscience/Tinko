//
//  FriendsListSelectTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/22/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "FriendsListSelectTableVC.h"
#import "InvitationRangeOptionTVC.h"
#import "FriendsListTableViewCell.h"
#import "CreateTableVC.h"
#import "User.h"
@import Firebase;

@interface FriendsListSelectTableVC ()
@property NSMutableArray *friendsListArray;
@end

@implementation FriendsListSelectTableVC

@synthesize delegate;
@synthesize selectedFriendsArray;
@synthesize allowPeopleNearby;
@synthesize allFriends;
@synthesize allowParticipantsInvite;


- (void)viewDidLoad {
    [super viewDidLoad];
    allowPeopleNearby = NO;
    allFriends = YES;
    allowParticipantsInvite = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _friendsListArray = [[NSMutableArray alloc] init];
    
    NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    [[FIRFirestore.firestore collectionWithPath:[NSString stringWithFormat:@"Users/%@/Friends_List", facebookId]]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting documents: %@", error);
         } else {
             //NSLog(@"DOCUMENTS: %@", snapshot.documents);
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 //NSLog(@"%@ => %@", document.documentID, document.data);
                 User *user = [[User alloc] initWithDictionary:document.data];
                 [_friendsListArray addObject:user];
             }
             //NSLog(@"friendsListArray: %@", _friendsListArray);
             NSRange range = NSMakeRange(1, 1);
             NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
             [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
         }
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return 3;
    } else{
        return _friendsListArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        NSDictionary *optionDic;
        
        InvitationRangeOptionTVC *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InvitationRangeOptionTVC" owner:self options:nil];
            cell = (InvitationRangeOptionTVC *)[nib objectAtIndex:0];
        }
        
        if(indexPath.row == 0){
            optionDic = @{
                          @"optionName" : @"All Friends",
                          @"option" : [NSNumber numberWithBool:YES]
                          };
            //detect all friends option changed
            [cell.optionSwitch addTarget:self action:@selector(allFriendsSwitchStateChanged:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDragInside];
        } else if (indexPath.row == 1) {
            optionDic = @{
                          @"optionName" : @"Allow People Nearby",
                          @"option" : [NSNumber numberWithBool:NO]
                          };
            [cell.optionSwitch addTarget:self action:@selector(allowPeopleNearbyStateChanged:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDragInside];
        } else {
            optionDic = @{
                          @"optionName" : @"Allow Participants Invite Friends",
                          @"option" : [NSNumber numberWithBool:NO]
                          };
            [cell.optionSwitch addTarget:self action:@selector(allowPeopleNearbyStateChanged:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDragInside];
        }
        
        [cell setCellData:optionDic];
        return cell;
    } else {
        FriendsListTableViewCell *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendsListTableViewCell" owner:self options:nil];
            cell = (FriendsListTableViewCell *)[nib objectAtIndex:0];
        }
        [cell setCellData:_friendsListArray[indexPath.row]];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        return cell;
    }
    
}

-(void)allFriendsSwitchStateChanged:(id)sender{
    BOOL state = [(UISwitch *)sender isOn];
    //NSLog(state ? @"switch state YES" : @"Switch state NO");
    allFriends = state;
    
    for(int i = 0; i<[_friendsListArray count]; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        FriendsListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if(state){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
}

-(void)allowPeopleNearbyStateChanged:(id)sender{
    BOOL state = [(UISwitch *)sender isOn];
    //NSLog(state ? @"switch state YES" : @"Switch state NO");
    allowPeopleNearby = state;
}

-(void)allowParticipantsInviteStateChanged:(id)sender{
    BOOL state = [(UISwitch *)sender isOn];
    //NSLog(state ? @"switch state YES" : @"Switch state NO");
    allowParticipantsInvite = state;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        FriendsListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        } else if(cell.accessoryType == UITableViewCellAccessoryNone){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
}

-(void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent){
        //NSLog(@"WillMoveToParentViewController");
        selectedFriendsArray = [[NSMutableArray alloc] init];
        for(int i = 0; i<[_friendsListArray count]; i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
            FriendsListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                User *user = _friendsListArray[indexPath.row];
                NSString *facebookId = user.facebookId;
                [selectedFriendsArray addObject: facebookId];
            }
        }
        [delegate friendsListSelectTableVCDidFinish:self];
        
    }
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
