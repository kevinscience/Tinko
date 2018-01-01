//
//  TinkoTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "TinkoTableVC.h"
#import "TinkoCell.h"
#import "Meet.h"
#import "TinkoDisplayRootVC.h"
#import "SharedMeet.h"
#import "TinkoDisccusionVC.h"
@import Firebase;

@interface TinkoTableVC ()
@property NSMutableArray *meetsArray;
@property NSMutableArray *meetsIdArray;
@property UIRefreshControl *refresher;
@property FIRFirestore *db;
@property NSString *facebookId;
@property BOOL lastMeetReached;
@property FIRDocumentSnapshot *lastSnapshot;
@end

//TODO add a automatically refresher call
@implementation TinkoTableVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    
    _meetsArray = [[NSMutableArray alloc] init];
    _meetsIdArray = [[NSMutableArray alloc] init];
    _refresher = [[UIRefreshControl alloc] init];
    _refresher.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [self.tableView addSubview:_refresher];
    [_refresher addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    _db = FIRFirestore.firestore;
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    _lastMeetReached = NO;
    [self fetchMeetsFromFirestore];
    
    

    //TODO SORT ALGORITHM OR RETHINK DATA STRUCTURE
//    [query addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
//         if (snapshot == nil) {
//             NSLog(@"Error fetching documents: %@", error);
//             return;
//         }
//         for (FIRDocumentChange *diff in snapshot.documentChanges) {
//             if (diff.type == FIRDocumentChangeTypeAdded) {
//                 NSLog(@"New meet: %@", diff.document.data);
//
//                 Meet *meet = [[Meet alloc] initWithDictionary:diff.document.data];
//                 [_meetsArray addObject:meet];
//                 [_meetsIdArray addObject:diff.document.documentID];
//             }
//             if (diff.type == FIRDocumentChangeTypeModified) {
//                 NSLog(@"Modified meet: %@", diff.document.data);
//             }
//             if (diff.type == FIRDocumentChangeTypeRemoved) {
//                 NSLog(@"Removed meet: %@", diff.document.data);
//             }
//         }
//        [self.tableView reloadData];
//     }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) fetchMeetsFromFirestore{
    NSString *queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.postTime", _facebookId];
    FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
    FIRQuery *query = [[meetsRef queryOrderedByField:queryString] queryLimitedTo:10];
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (error != nil) {
            NSLog(@"Error getting documents: %@", error);
        } else {
            NSLog(@"Count of new refresh documents: %lu", (unsigned long)snapshot.documents.count);
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                //NSLog(@"%@ => %@", document.documentID, document.data);
                Meet *meet = [[Meet alloc] initWithDictionary:document.data];
                
                [_meetsArray addObject:meet];
                [_meetsIdArray addObject:document.documentID];
            }
            
            _lastSnapshot = snapshot.documents.lastObject;
            
            
            [_refresher endRefreshing];
            [self.tableView reloadData];
        }
    }];
}

- (void) loadMoreMeetFromFirestore{
    @try{
        NSString *queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.postTime", _facebookId];
        FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
        FIRQuery *query = [[[meetsRef queryOrderedByField:queryString] queryLimitedTo:7] queryStartingAfterDocument:_lastSnapshot];
        [query getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
            if (error != nil) {
                NSLog(@"Error getting documents: %@", error);
            } else {
                for (FIRDocumentSnapshot *document in snapshot.documents) {
                    //NSLog(@"%@ => %@", document.documentID, document.data);
                    Meet *meet = [[Meet alloc] initWithDictionary:document.data];
                    [_meetsArray addObject:meet];
                    [_meetsIdArray addObject:document.documentID];
                }
                
                //NSLog(@"lastDoc: %@", _lastSnapshot.data);
                if([_lastSnapshot.documentID isEqualToString:snapshot.documents.lastObject.documentID]) {
                    NSLog(@"loadMore: lastMeetReached YES");
                    _lastMeetReached = YES;
                } else {
                    NSLog(@"loadMore: lastMeetReached NO");
                    _lastSnapshot = snapshot.documents.lastObject;
                    if(_meetsArray != nil){
                        [self.tableView reloadData];
                    }
                }
                
            }
        }];
    }
    @catch(NSException *exception){
        
    }
    @finally{
        
    }
    
}

- (void) pullToRefresh {
    [_meetsArray removeAllObjects];
    [_meetsIdArray removeAllObjects];
    _lastMeetReached = NO;
    [self fetchMeetsFromFirestore];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _meetsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TinkoCell *cell = nil;
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TinkoCell" owner:self options:nil];
        cell = (TinkoCell *)[nib objectAtIndex:0];
    }
    if(_meetsArray.count > 0 && _meetsArray.count > indexPath.row){
        [cell setCellData:_meetsArray[indexPath.row]];
    }
    
    
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TinkoDisplayRootVC *secondView = [storyboard instantiateViewControllerWithIdentifier:@"TinkoDisplayRootVCID"];
    //TinkoDisccusionVC *secondView = [TinkoDisccusionVC new];
    secondView.hidesBottomBarWhenPushed = YES;
    SharedMeet *sharedMeet = [SharedMeet sharedMeet];
    Meet *meet = _meetsArray[indexPath.row];
    [sharedMeet setMeet:meet];
    [sharedMeet setMeetId:_meetsIdArray[indexPath.row]];
    NSLog(@"TinkoTable: %@", meet.title);
     [self.navigationController pushViewController: secondView animated:YES];
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"willDisplayCell outside row: %ld, count: %lu", (long)indexPath.row, (unsigned long)_meetsArray.count);
    if(!_lastMeetReached && indexPath.row == _meetsArray.count -1){
        //NSLog(@"willDisplayCell inside row: %ld, count: %lu", (long)indexPath.row, (unsigned long)_meetsArray.count);
        [self loadMoreMeetFromFirestore];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    return 124.0f;
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"  Tinko  ";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
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
