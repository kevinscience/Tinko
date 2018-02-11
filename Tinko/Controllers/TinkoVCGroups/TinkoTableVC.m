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
#import "EKBHeap.h"
#import "User.h"
#import "AppDelegate.h"
#import "CDFriendsMeet.h"
@import Firebase;

@interface TinkoTableVC ()
@property UIRefreshControl *refresher;
@property FIRFirestore *db;
@property NSString *facebookId;
@property (strong, nonatomic) LGPlusButtonsView *plusButtonsViewMain;
@property BOOL orderByPostTime; // true: order by postTime, false: order by startTime;
//@property id<FIRListenerRegistration> listener;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(weak, nonatomic)NSPersistentContainer *container;
@property(weak, nonatomic)NSManagedObjectContext *context;
@property NSMutableArray<id<FIRListenerRegistration>> *listenerArray;
@property NSInteger insets;
@property BOOL firstLoad;
@end

//TODO add a automatically refresher call
@implementation TinkoTableVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _container = appDelegate.persistentContainer;
    _context = _container.viewContext;
    [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    _listenerArray = [[NSMutableArray alloc] init];

    _refresher = [[UIRefreshControl alloc] init];
    _refresher.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [self.tableView addSubview:_refresher];
    [_refresher addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    _db = FIRFirestore.firestore;
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];

    _orderByPostTime = YES;
    _firstLoad = YES;
    _insets = 1;
    
    [self initializeFetchedResultsController];
    
    [self addMeetsListener];

//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



-(void)addMeetsListener{
//    [_container performBackgroundTask:^(NSManagedObjectContext * context) {
//        NSManagedObjectContext *moc = _context;
//        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
//
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FIRQuery *query;
        NSString *queryString;
        NSInteger limitNo = 17;
        FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
//        if(_orderByPostTime){
//            queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.postTime", _facebookId];
//            query = [[meetsRef queryOrderedByField:queryString] queryWhereField:@"status" isEqualTo:@NO];
//        } else {
//            NSDate *now = [NSDate date];
//            queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.startTime", _facebookId];
//            query = [[meetsRef queryWhereField:queryString isGreaterThan:now] queryOrderedByField:queryString];
//        }
//
//        query = [query queryLimitedTo:limitNo];
        queryString = [NSString stringWithFormat:@"selectedFriendsList.%@.status", _facebookId];
        query = [[meetsRef queryWhereField:queryString isEqualTo:@YES] queryWhereField:@"status" isEqualTo:@YES];
        
        id<FIRListenerRegistration> listener =
        [query addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot == nil) {
                NSLog(@"Error fetching documents: %@", error);
                return;
            }
            
            NSMutableArray *meetsIdArray = [[NSMutableArray alloc] init];
            NSInteger index = 0;
            NSInteger diffChangesCountTypeAdded = 0;
            for(FIRDocumentChange *diff in snapshot.documentChanges) {
                if (diff.type == FIRDocumentChangeTypeAdded) {
                    diffChangesCountTypeAdded++;
                }
            }
            if(diffChangesCountTypeAdded==0){
                [self concludeAddMeetsListener:meetsIdArray];
            }
            for (FIRDocumentChange *diff in snapshot.documentChanges) {
                //NSLog(@"TinkoTable: AddMeetsListener: diff.title=%@",diff.document.data[@"title"]);
                
                if (diff.type == FIRDocumentChangeTypeAdded) {
                    index++;
                    [meetsIdArray addObject:diff.document.documentID];
                    Meet *meet = [[Meet alloc] initWithDictionary:diff.document.data];
                    NSLog(@"TinkoTable: AddMeetsListener: meet.title: %@", meet.title);
                    NSString *creatorFacebookId = meet.creatorFacebookId;
                    
                    //[self getUserDataAndUpdateCoreData:creatorFacebookId withMeetId:diff.document.documentID withMeet:meet];
                    FIRDocumentReference *userRef = [[_db collectionWithPath:@"Users"] documentWithPath:creatorFacebookId];
                    [userRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable userSnapshot, NSError * _Nullable error) {
                        User *user;
                        if (userSnapshot != nil) {
                            //NSLog(@"Document data: %@", snapshot.data);
                            user = [[User alloc] initWithDictionary:userSnapshot.data];
                            //CDUser *cdUser = [CDUser createOrUpdateCDUserWithUser:user withContext:moc];
                            [_context performBlock:^{
                                [CDFriendsMeet createOrUpdateMeetWithMeet:meet withMeetId:diff.document.documentID withUser:user withContext:_context];
                                //                    NSError *error = nil;
                                //                    if (![_context save:&error]) {
                                //                        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                                //                        abort();
                                //                    }
                                NSLog(@"TinkoTable: AddMeetsListener: for loop index before = %ld, diffChangesCountTypeAdded = %ld", (long)index, (long)diffChangesCountTypeAdded);
                                if(index == diffChangesCountTypeAdded){
                                    NSLog(@"TinkoTable: AddMeetsListener: for loop index after = %ld", (long)index);
                                    [self concludeAddMeetsListener:meetsIdArray];
                                }
                                
                            }];
                            
                            
                        }
                    }];
                }
                if (diff.type == FIRDocumentChangeTypeModified) {
                    NSLog(@"Modified city: %@", diff.document.documentID);
                }
                if (diff.type == FIRDocumentChangeTypeRemoved) {
                    NSLog(@"Removed city: %@", diff.document.documentID);
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CDFriendsMeet"];
                    [request setPredicate:[NSPredicate predicateWithFormat:@"meetId == %@", diff.document.documentID]];
                    NSArray *array = [_context executeFetchRequest:request error:&error];
                    [_context deleteObject:array.firstObject];
                    if ([_context hasChanges] && ![_context save:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                        abort();
                    }
                }
            }
            
        }];
        [_listenerArray addObject:listener];
    });
    
}

-(void)concludeAddMeetsListener:(NSMutableArray*)meetsIdArray{
    NSError *error = nil;
    
    [_context performBlock:^{
        NSError *error = nil;
        if (![_context save:&error]) {
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
    }];
    
    if(_firstLoad){
        [_context performBlock:^{
            NSLog(@"TinkoTable: addMeetsListener: meetsIdArray.count = %lu", (unsigned long)meetsIdArray.count);
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CDFriendsMeet"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"Not (meetId IN %@)", meetsIdArray]];
            
            NSError *error = nil;
            NSArray *array = [_context executeFetchRequest:request error:&error];
            for(NSManagedObject *managedObject in array){
                [_context deleteObject:managedObject];
            }
            //NSError *error = nil;
            if ([_context hasChanges] && ![_context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }];
    }
    _firstLoad = NO;
}



- (void) pullToRefresh {
    [self initializeFetchedResultsController];
    [self.tableView reloadData];
    [_refresher endRefreshing];
    //_lastMeetReached = NO;
    //[self fetchMeetsFromFirestore];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects] + _insets;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        return cell;

    } else {
        TinkoCell *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TinkoCell" owner:self options:nil];
            cell = (TinkoCell *)[nib objectAtIndex:0];
        }
        
        NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row - _insets inSection: indexPath.section];
        CDFriendsMeet *cdFriendsMeet = [self.fetchedResultsController objectAtIndexPath:customIndexPath];
        [cell setCellDataWithCDFriendsMeet:cdFriendsMeet];
        
        
        
        return cell;
    }
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TinkoDisplayRootVC *secondView = [storyboard instantiateViewControllerWithIdentifier:@"TinkoDisplayRootVCID"];
    secondView.hidesBottomBarWhenPushed = YES;
    SharedMeet *sharedMeet = [SharedMeet sharedMeet];
    NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row - _insets inSection: indexPath.section];
    CDFriendsMeet *cdMeet = [self.fetchedResultsController objectAtIndexPath:customIndexPath];
    //Meet *meet = _meetsArray[indexPath.row];
    //[sharedMeet setMeet:meet];
    [sharedMeet setMeetId:cdMeet.meetId];
    //NSLog(@"TinkoTable: %@", meet.title);
    [self.navigationController pushViewController: secondView animated:YES];
}


//
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDFriendsMeet"];
//    NSDate *now = [NSDate date];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"startTime >= %@", now]];
//    NSError *error = nil;
//    NSInteger count = [_context countForFetchRequest:request error:&error];
//    NSLog(@"willDisplayCell outside row: %ld, count: %lu, lastMeetReached:%@", (long)indexPath.row, (unsigned long)count, [NSNumber numberWithBool:_lastMeetReached]);
//    if(!_lastMeetReached && indexPath.row == count ){
//        NSLog(@"willDisplayCell inside row: %ld, count: %lu, meetsLoadingDone: %@", (long)indexPath.row, (unsigned long)count, [NSNumber numberWithBool:_meetsLoadingDone]);
//        [self loadMoreMeetFromFirestore];
//    }
//
////    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
////        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
////        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
////    }
//}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if(indexPath.row!=0){
        height = 124;
    }
    return height;
}

- (void)initializeFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDFriendsMeet"];
    NSDate *now = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime >= %@", now];
    NSString *sortKey = _orderByPostTime ? @"postTime" : @"startTime";
    BOOL sortAscending = _orderByPostTime ? NO : YES;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:sortAscending];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sort]];
    
    //NSManagedObjectContext *moc = …; //Retrieve the main queue NSManagedObjectContext
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}


#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"controllerwillchangeContent");
    [[self tableView] beginUpdates];

}
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    //NSLog(@"controllerdidchangesection");
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeMove:
//        case NSFetchedResultsChangeUpdate:
//            break;
//    }
//}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    //NSLog(@"controllerwilldidchangeObject");
    NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row+_insets inSection:indexPath.section];
    NSIndexPath *customNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row+_insets inSection:newIndexPath.section];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[self tableView] insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }

}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"controllerdidchangecontent");
    [[self tableView] endUpdates];

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

//-(void) addFloatButton{
//    _plusButtonsViewMain = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:1
//                                                         firstButtonIsPlusButton:YES
//                                                                   showAfterInit:YES
//                                                                   actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
//                            {
//                                NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
////                                for(id<FIRListenerRegistration> listener in _listenerArray){
////                                    [listener remove];
////                                }
////                                [_listenerArray removeAllObjects];
////                                _orderByPostTime = !_orderByPostTime;
////                                _lastMeetReached = NO;
////                                _meetsLoadingDone = NO;
////                                [self initializeFetchedResultsController];
////                                [self addMeetsListener];
//                            }];
//
//    //_plusButtonsViewMain.observedScrollView = self.scrollView;
//    //_plusButtonsViewMain.coverColor = [UIColor colorWithWhite:1.f alpha:0.7];
//    _plusButtonsViewMain.observedScrollView = self.tableView;
//    _plusButtonsViewMain.position = LGPlusButtonsViewPositionBottomRight;
//    CGFloat tabbarHeight = self.tabBarController.tabBar.frame.size.height;
//    _plusButtonsViewMain.offset = CGPointMake(0.f, -10.0f - tabbarHeight);
//    _plusButtonsViewMain.plusButtonAnimationType = LGPlusButtonAnimationTypeRotate;
//
//    [_plusButtonsViewMain setButtonsTitles:@[@"+"] forState:UIControlStateNormal];
//    [_plusButtonsViewMain setDescriptionsTexts:@[@""]];
//    [_plusButtonsViewMain setButtonsImages:@[[NSNull new]]
//                                  forState:UIControlStateNormal
//                            forOrientation:LGPlusButtonsViewOrientationAll];
//
//    [_plusButtonsViewMain setButtonsAdjustsImageWhenHighlighted:NO];
//    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f] forState:UIControlStateNormal];
//    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted];
//    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted|UIControlStateSelected];
//    [_plusButtonsViewMain setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationAll];
//    [_plusButtonsViewMain setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
//    [_plusButtonsViewMain setButtonsTitleFont:[UIFont boldSystemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationAll];
//    [_plusButtonsViewMain setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
//    [_plusButtonsViewMain setButtonsLayerShadowOpacity:0.5];
//    [_plusButtonsViewMain setButtonsLayerShadowRadius:3.f];
//    [_plusButtonsViewMain setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
//    [_plusButtonsViewMain setButtonAtIndex:0 size:CGSizeMake(56.f, 56.f)
//                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
//    [_plusButtonsViewMain setButtonAtIndex:0 layerCornerRadius:56.f/2.f
//                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
//    [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:40.f]
//                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
//    [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -3.f) forOrientation:LGPlusButtonsViewOrientationAll];
//    //    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.f blue:0.5 alpha:1.f] forState:UIControlStateNormal];
//    //    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.2 blue:0.6 alpha:1.f] forState:UIControlStateHighlighted];
//    //    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.5 blue:0.f alpha:1.f] forState:UIControlStateNormal];
//    //    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.6 blue:0.2 alpha:1.f] forState:UIControlStateHighlighted];
//    //    [_plusButtonsViewMain setButtonAtIndex:3 backgroundColor:[UIColor colorWithRed:0.f green:0.7 blue:0.f alpha:1.f] forState:UIControlStateNormal];
//    //    [_plusButtonsViewMain setButtonAtIndex:3 backgroundColor:[UIColor colorWithRed:0.f green:0.8 blue:0.f alpha:1.f] forState:UIControlStateHighlighted];
//
//    //    [_plusButtonsViewMain setDescriptionsBackgroundColor:[UIColor whiteColor]];
//    //    [_plusButtonsViewMain setDescriptionsTextColor:[UIColor blackColor]];
//    //    [_plusButtonsViewMain setDescriptionsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
//    //    [_plusButtonsViewMain setDescriptionsLayerShadowOpacity:0.25];
//    //    [_plusButtonsViewMain setDescriptionsLayerShadowRadius:1.f];
//    //    [_plusButtonsViewMain setDescriptionsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
//    //    [_plusButtonsViewMain setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
//    //    [_plusButtonsViewMain setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];
//
//    //    for (NSUInteger i=1; i<=3; i++)
//    //        [_plusButtonsViewMain setButtonAtIndex:i offset:CGPointMake(-6.f, 0.f)
//    //                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
//
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -2.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
//        [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:32.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
//    }
//
//    [self.view addSubview:_plusButtonsViewMain];
//}

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
