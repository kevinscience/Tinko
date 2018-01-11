//
//  MeVCViewController.m
//  Tinko
//
//  Created by Donghua Xue on 12/19/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "MeVC.h"
#import "ProfileTableViewCell.h"
#import "FriendsListTableViewCell.h"
#import "TempVC.h"
#import "User.h"
#import "ThisUser.h"
#import "ProfileUpdateTableVC.h"
@import Firebase;

@interface MeVC ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSMutableArray *friendsListArray;
@property User *theUser;
@end

@implementation MeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                NSFontAttributeName:[UIFont systemFontOfSize:19 weight:UIFontWeightSemibold]}];
    
   
    _table.delegate = self;
    _table.dataSource = self;
    
    _friendsListArray = [[NSMutableArray alloc] init];
    
    NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    
    FIRDocumentReference *myDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:facebookId];
    [myDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot.exists) {
            //NSLog(@"Document data: %@", snapshot.data);
            NSDictionary *dic = snapshot.data;
            _theUser = [[User alloc] initWithDictionary:dic];
            ThisUser *thisUser = [ThisUser thisUser];
            [thisUser setUser:_theUser];
        } else {
            NSLog(@"Document does not exist");
            _theUser = [[User alloc] init];
        }
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.table reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    
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
             NSLog(@"friendsListArray: %@", _friendsListArray);
             NSRange range = NSMakeRange(1, 1);
             NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
             [self.table reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
         }
     }];
    
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            ProfileTableViewCell *cell = nil;
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileTableViewCell" owner:self options:nil];
                cell = (ProfileTableViewCell *)[nib objectAtIndex:0];
            }
            [cell setCellDataWithUser:_theUser];
            return cell;
        } else{
            FriendsListTableViewCell *cell = nil;
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendsListTableViewCell" owner:self options:nil];
                cell = (FriendsListTableViewCell *)[nib objectAtIndex:0];
            }
            [cell setInvitationCellData];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        
    } else {
        FriendsListTableViewCell *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendsListTableViewCell" owner:self options:nil];
            cell = (FriendsListTableViewCell *)[nib objectAtIndex:0];
        }
        [cell setCellData:_friendsListArray[indexPath.row]];
        return cell;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        return 2;
    } else{
        return _friendsListArray.count;
        //return 5;
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        ProfileUpdateTableVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileUpdateTableVCID"];
        //MessageViewController *secondView = [MessageViewController new];
        secondView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController: secondView animated:YES];
    }
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.table.rowHeight;
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            height = 80.0f;
        }
    }
    return height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
