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
#import "AppDelegate.h"
#import "CDUser.h"
#import "FriendDetailTVC.h"
#import "NewFriendsRequest.h"
@import Firebase;

@interface MeVC ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSMutableArray *friendsListArray;
@property User *theUser;
@property(weak, nonatomic)NSPersistentContainer *container;
@property(weak, nonatomic)NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property NSString *facebookId;
@end

@implementation MeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                NSFontAttributeName:[UIFont systemFontOfSize:19 weight:UIFontWeightSemibold]}];
    
   
    _table.delegate = self;
    _table.dataSource = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _container = appDelegate.persistentContainer;
    _context = _container.viewContext;
    [_context setMergePolicy:NSOverwriteMergePolicy];
    [self initializeFetchedResultsController];
    
    _friendsListArray = [[NSMutableArray alloc] init];
    
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    
    FIRDocumentReference *myDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:_facebookId];
    [myDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot.exists) {
            //NSLog(@"Document data: %@", snapshot.data);
            NSDictionary *dic = snapshot.data;
            _theUser = [[User alloc] initWithDictionary:dic];
            ThisUser *thisUser = [ThisUser thisUser];
            [thisUser setUser:_theUser];
            //Save to Core Data
            [CDUser createOrUpdateCDUserWithUser:_theUser withContext:_context];
            NSError *error = nil;
            if ([_context hasChanges] && ![_context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        } else {
            NSLog(@"Document does not exist");
            _theUser = [[User alloc] init];
        }
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.table reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    
    [[FIRFirestore.firestore collectionWithPath:[NSString stringWithFormat:@"Users/%@/Friends_List", _facebookId]]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting documents: %@", error);
         } else {
             //NSLog(@"DOCUMENTS: %@", snapshot.documents);
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 //NSLog(@"%@ => %@", document.documentID, document.data);
                 NSString *userFacebookId = document.documentID;
                 //NSLog(@"userFacebookId: %@", userFacebookId);
                 FIRDocumentReference *userDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:userFacebookId];
                 [userDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                     if (snapshot.exists) {
                         //NSLog(@"myDocRef Document data: %@", snapshot.data);
                         NSDictionary *dic = snapshot.data;
                         User *user = [[User alloc] initWithDictionary:dic];
                         [CDUser createOrUpdateCDUserWithUser:user withContext:_context];
                         NSError *error = nil;
                         if ([_context hasChanges] && ![_context save:&error]) {
                             NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                             abort();
                         }
                     } else {
                         NSLog(@"Document does not exist");
                     }
                     [self initializeFetchedResultsController];
                     NSRange range = NSMakeRange(1, 1);
                     NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                     [self.table reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
                     
                 }];
             }
             
         }
     }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewFriendsRequest:) name:@"NewFriendsRequestNotification" object:nil];
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
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"facebookId == %@", _facebookId]];
            NSError *error = nil;
            NSArray *array = [_context executeFetchRequest:fetchRequest error:&error];
            CDUser *cdUser = [array firstObject];
            [cell setCellDataWithCDUser:cdUser];
            //[cell setCellDataWithUser:_theUser];
            return cell;
        } else if (indexPath.row == 1){
            FriendsListTableViewCell *cell = nil;
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendsListTableViewCell" owner:self options:nil];
                cell = (FriendsListTableViewCell *)[nib objectAtIndex:0];
            }
            [cell setCustomCellDataWithTitle:@"Invite Friends" withImageName:@"inviteIcon"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }  else if (indexPath.row == 2){
            FriendsListTableViewCell *cell = nil;
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendsListTableViewCell" owner:self options:nil];
                cell = (FriendsListTableViewCell *)[nib objectAtIndex:0];
            }
            [cell setCustomCellDataWithTitle:@"History Tinko" withImageName:@"history"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }  else{
            FriendsListTableViewCell *cell = nil;
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendsListTableViewCell" owner:self options:nil];
                cell = (FriendsListTableViewCell *)[nib objectAtIndex:0];
            }
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"NewFriendsRequest"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"read == %@", [NSNumber numberWithBool:NO]]];
            NSError *error = nil;
            NSInteger count = [_context countForFetchRequest:fetchRequest error:&error];
            
            NSString *imageName = count == 0 ? @"newfriends" : @"newFriendsWithDot";
            [cell setCustomCellDataWithTitle:@"New Friends" withImageName:imageName];
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
        
        NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        CDUser *cdUser = [self.fetchedResultsController objectAtIndexPath:customIndexPath];
        [cell setCellDataWithFriend:cdUser];
        return cell;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if(section==0){
        return 4;
    } else{
        id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][0];
        return [sectionInfo numberOfObjects];    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            ProfileUpdateTableVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileUpdateTableVCID"];
            //MessageViewController *secondView = [MessageViewController new];
            secondView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController: secondView animated:YES];
        } else if(indexPath.row == 1){
            
        } else if(indexPath.row == 2){
            
        } else if(indexPath.row == 3){
            UITabBarItem *tabBarItemMe = [self.tabBarController.tabBar.items objectAtIndex:2];
            [tabBarItemMe setBadgeValue:nil];
            FriendsListTableViewCell *cell = [_table cellForRowAtIndexPath:indexPath];
            [cell.image setImage:[UIImage imageNamed:@"newfriends"]];
        }
        
    } else if( indexPath.section == 1){
        NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        CDUser *cdUser = [self.fetchedResultsController objectAtIndexPath:customIndexPath];
        
        FriendDetailTVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendDetailTVCID"];
        secondView.showingUserFacebookId = cdUser.facebookId;
        secondView.cdUser = cdUser;
        secondView.isCDUser = YES;
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


- (void)initializeFetchedResultsController
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"NOT (facebookId == %@)", _facebookId]];
    NSSortDescriptor *usernameSort = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES];
    
    [request setSortDescriptors:@[usernameSort]];
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil]];
    //self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

-(void)receiveNewFriendsRequest:(NSNotification *) notification{
    NSLog(@"MeVC: receoveMewFriendsRequest");
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    FriendsListTableViewCell *cell = [_table cellForRowAtIndexPath:indexPath];
    [cell.image setImage:[UIImage imageNamed:@"newFriendsWithDot"]];
}

//#pragma mark - NSFetchedResultsControllerDelegate
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    NSLog(@"controllerwillchangeContent");
//    [self.table beginUpdates];
//}
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    NSLog(@"controllerdidchangesection");
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.table insertSections:[NSIndexSet indexSetWithIndex:sectionIndex-1] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.table deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex-1] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeMove:
//        case NSFetchedResultsChangeUpdate:
//            break;
//    }
//}
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
//    NSIndexPath *customNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section-1];
//    NSLog(@"controllerwilldidchangeObject");
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.table insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.table deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeUpdate:
//            [self.table reloadRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeMove:
//            [self.table deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self.table insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    NSLog(@"controllerdidchangecontent");
//    [self.table endUpdates];
//}



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
