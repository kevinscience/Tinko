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
#import "LGPlusButtonsView.h"
@import Firebase;

@interface TinkoTableVC ()
@property NSMutableArray *meetsArray;
@property NSMutableArray *meetsIdArray;
@property UIRefreshControl *refresher;
@property FIRFirestore *db;
@property NSString *facebookId;
@property BOOL lastMeetReached;
@property FIRDocumentSnapshot *lastSnapshot;
@property (strong, nonatomic) LGPlusButtonsView *plusButtonsViewMain;
@property BOOL orderByPostTime; // true: order by postTime, false: order by startTime;
@end

//TODO add a automatically refresher call
@implementation TinkoTableVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
  
    
    _meetsArray = [[NSMutableArray alloc] init];
    _meetsIdArray = [[NSMutableArray alloc] init];
    _refresher = [[UIRefreshControl alloc] init];
    _refresher.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [self.tableView addSubview:_refresher];
    [_refresher addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    _db = FIRFirestore.firestore;
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    _lastMeetReached = NO;
    _orderByPostTime = YES;
    //[self fetchMeetsFromFirestore];
    
    

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
    [_meetsArray removeAllObjects];
    [_meetsIdArray removeAllObjects];
    
    NSString *queryString;
    if(_orderByPostTime){
        queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.postTime", _facebookId];
    } else {
        queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.startTime", _facebookId];
    }
    
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
        NSString *queryString;
        if(_orderByPostTime){
            queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.postTime", _facebookId];
        } else {
            queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.startTime", _facebookId];
        }
        
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchMeetsFromFirestore];
    
    _plusButtonsViewMain = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:1
                                                         firstButtonIsPlusButton:YES
                                                                   showAfterInit:YES
                                                                   actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                            {
                                NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);

                                if(_orderByPostTime){
                                    _orderByPostTime = NO;
                                    
                                } else {
                                    _orderByPostTime = YES;
                                }
                                [self fetchMeetsFromFirestore];
                            }];

    //_plusButtonsViewMain.observedScrollView = self.scrollView;
    //_plusButtonsViewMain.coverColor = [UIColor colorWithWhite:1.f alpha:0.7];
    _plusButtonsViewMain.position = LGPlusButtonsViewPositionBottomRight;
    _plusButtonsViewMain.offset = CGPointMake(0.f, -50.f);
    _plusButtonsViewMain.plusButtonAnimationType = LGPlusButtonAnimationTypeRotate;

    [_plusButtonsViewMain setButtonsTitles:@[@"+"] forState:UIControlStateNormal];
    [_plusButtonsViewMain setDescriptionsTexts:@[@""]];
    [_plusButtonsViewMain setButtonsImages:@[[NSNull new]]
                                  forState:UIControlStateNormal
                            forOrientation:LGPlusButtonsViewOrientationAll];

    [_plusButtonsViewMain setButtonsAdjustsImageWhenHighlighted:NO];
    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted];
    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted|UIControlStateSelected];
    [_plusButtonsViewMain setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setButtonsTitleFont:[UIFont boldSystemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [_plusButtonsViewMain setButtonsLayerShadowOpacity:0.5];
    [_plusButtonsViewMain setButtonsLayerShadowRadius:3.f];
    [_plusButtonsViewMain setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
    [_plusButtonsViewMain setButtonAtIndex:0 size:CGSizeMake(56.f, 56.f)
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 layerCornerRadius:56.f/2.f
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:40.f]
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -3.f) forOrientation:LGPlusButtonsViewOrientationAll];
    //    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.f blue:0.5 alpha:1.f] forState:UIControlStateNormal];
    //    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.2 blue:0.6 alpha:1.f] forState:UIControlStateHighlighted];
    //    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.5 blue:0.f alpha:1.f] forState:UIControlStateNormal];
    //    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.6 blue:0.2 alpha:1.f] forState:UIControlStateHighlighted];
    //    [_plusButtonsViewMain setButtonAtIndex:3 backgroundColor:[UIColor colorWithRed:0.f green:0.7 blue:0.f alpha:1.f] forState:UIControlStateNormal];
    //    [_plusButtonsViewMain setButtonAtIndex:3 backgroundColor:[UIColor colorWithRed:0.f green:0.8 blue:0.f alpha:1.f] forState:UIControlStateHighlighted];

    //    [_plusButtonsViewMain setDescriptionsBackgroundColor:[UIColor whiteColor]];
    //    [_plusButtonsViewMain setDescriptionsTextColor:[UIColor blackColor]];
    //    [_plusButtonsViewMain setDescriptionsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    //    [_plusButtonsViewMain setDescriptionsLayerShadowOpacity:0.25];
    //    [_plusButtonsViewMain setDescriptionsLayerShadowRadius:1.f];
    //    [_plusButtonsViewMain setDescriptionsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
    //    [_plusButtonsViewMain setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
    //    [_plusButtonsViewMain setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];

    //    for (NSUInteger i=1; i<=3; i++)
    //        [_plusButtonsViewMain setButtonAtIndex:i offset:CGPointMake(-6.f, 0.f)
    //                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -2.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:32.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
    }

    [self.view addSubview:_plusButtonsViewMain];
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
