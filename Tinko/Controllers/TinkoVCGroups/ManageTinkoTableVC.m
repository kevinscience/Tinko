//
//  ManageTinkoTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/24/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "ManageTinkoTableVC.h"
#import "TinkoCell.h"
#import "Meet.h"
#import "EKBHeap.h"
#import "TinkoDisplayRootVC.h"
#import "SharedMeet.h"
#import "CDMyMeet.h"
#import "AppDelegate.h"
@import Firebase;

@interface ManageTinkoTableVC ()
//@property NSMutableArray<Meet *> *meetsArray;
//@property NSMutableArray *meetsIdArray;
//@property NSMutableArray *meetsUserArray;
//@property NSMutableDictionary *meetsIdDictionary;
@property FIRFirestore *db;
@property NSString *facebookId;
@property(weak, nonatomic)NSPersistentContainer *container;
@property(weak, nonatomic)NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property BOOL firstLoad;
@end

@implementation ManageTinkoTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    _meetsArray = [[NSMutableArray alloc] init];
//    _meetsIdArray = [[NSMutableArray alloc] init];
//    _meetsUserArray = [[NSMutableArray alloc] init];
//    _meetsIdDictionary = [[NSMutableDictionary alloc] init];
    _db = FIRFirestore.firestore;
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _container = appDelegate.persistentContainer;
    _context = _container.viewContext;
    [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    _firstLoad = YES;
    [self initializeFetchedResultsController];
    [self addInvolvedMeetsSnapshotListener];
    
    
}

-(void)addInvolvedMeetsSnapshotListener{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *queryString = [NSString stringWithFormat:@"participatedUsersList.%@.status", _facebookId];
        FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
        FIRQuery *query = [meetsRef queryWhereField:queryString isEqualTo:@YES];
        [query addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
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
                [self concludeListenerWithMeetIdArray:meetsIdArray];
            }
            
            for (FIRDocumentChange *diff in snapshot.documentChanges) {
                if (diff.type == FIRDocumentChangeTypeAdded){
                    
                    index++;
                    [meetsIdArray addObject:diff.document.documentID];
                    
                    Meet *meet = [[Meet alloc] initWithDictionary:diff.document.data];
                    NSString *creatorFacebookId = meet.creatorFacebookId;
                    FIRDocumentReference *userRef = [[_db collectionWithPath:@"Users"] documentWithPath:creatorFacebookId];
                    [userRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
                        User *user;
                        if (snapshot != nil) {
                            //NSLog(@"Document data: %@", snapshot.data);
                            user = [[User alloc] initWithDictionary:snapshot.data];
                            [_context performBlock:^{
                                [CDMyMeet createOrUpdateMeetWithMeet:meet withMeetId:diff.document.documentID withUser:user withContext:_context];
                                NSError *error = nil;
                                if ([_context hasChanges] && ![_context save:&error]) {
                                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                                    abort();
                                }
                                if(index == diffChangesCountTypeAdded){
                                    [self concludeListenerWithMeetIdArray:meetsIdArray];
                                }
                                
                            }];
                            
                        } else {
                            NSLog(@"Document does not exist");
                            //user = [[User alloc] init];
                        }
                    }];
                }
                if (diff.type == FIRDocumentChangeTypeModified) {
                    //NSLog(@"Modified city: %@", diff.document.data);
                }
                if (diff.type == FIRDocumentChangeTypeRemoved) {
                    //                NSLog(@"Removed meet: %@", diff.document.data);
                    //                NSString *documentId = diff.document.documentID;
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CDMyMeet"];
                    [request setPredicate:[NSPredicate predicateWithFormat:@"meetId == %@", diff.document.documentID]];
                    NSArray *array = [_context executeFetchRequest:request error:&error];
                    [_context deleteObject:array.firstObject];
                    if ([_context hasChanges] && ![_context save:&error]) {
                        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                        abort();
                    }
                    
                }
            }
            
            
            //
        }];
    });
}

-(void) concludeListenerWithMeetIdArray:(NSMutableArray*)meetsIdArray{
    if (_firstLoad){
        [_context performBlock:^{
            //NSLog(@"TinkoTable: addMeetsListener: meetsIdArray.count = %lu", (unsigned long)meetsIdArray.count);
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CDMyMeet"];
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

- (void)initializeFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDMyMeet"];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TinkoCell *cell = nil;
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TinkoCell" owner:self options:nil];
        cell = (TinkoCell *)[nib objectAtIndex:0];
    }
    
    CDMyMeet *cdMyMeet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setCellDataWithCDMeet:cdMyMeet];


    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TinkoDisplayRootVC *secondView = [storyboard instantiateViewControllerWithIdentifier:@"TinkoDisplayRootVCID"];
    secondView.hidesBottomBarWhenPushed = YES;
    SharedMeet *sharedMeet = [SharedMeet sharedMeet];
    CDMyMeet *cdMeet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //Meet *meet = _meetsArray[indexPath.row];
    //[sharedMeet setMeet:meet];
    [sharedMeet setMeetId:cdMeet.meetId];
    //NSLog(@"TinkoTable: %@", meet.title);
    [self.navigationController pushViewController: secondView animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 124.0f;
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"Manage";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"controllerwillchangeContent");
    [[self tableView] beginUpdates];
    
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    //NSLog(@"controllerdidchangesection");
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    //NSLog(@"controllerwilldidchangeObject");
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
    
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"controllerdidchangecontent");
    [[self tableView] endUpdates];
    
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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


//-(void)loadExistedMeetsFromFirestore{
//    NSString *queryString = [NSString stringWithFormat:@"participatedUsersList.%@.startTime", _facebookId];
//    FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
//    FIRQuery *query = [meetsRef queryOrderedByField:queryString];
//    [query getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
//        if (error != nil) {
//            NSLog(@"Error getting documents: %@", error);
//        } else {
//            NSLog(@"Count of new refresh documents: %lu", (unsigned long)snapshot.documents.count);
//            for (FIRDocumentSnapshot *document in snapshot.documents) {
//                //NSLog(@"%@ => %@", document.documentID, document.data);
//                Meet *meet = [[Meet alloc] initWithDictionary:document.data];
//                NSString *creatorFacebookId = meet.creatorFacebookId;
//                FIRDocumentReference *userRef = [[_db collectionWithPath:@"Users"] documentWithPath:creatorFacebookId];
//                [userRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
//                    User *user;
//                    if (snapshot != nil) {
//                        //NSLog(@"Document data: %@", snapshot.data);
//                        user = [[User alloc] initWithDictionary:snapshot.data];
//
//                    } else {
//                        NSLog(@"Document does not exist");
//                        user = [[User alloc] init];
//                    }
//                    [_meetsUserArray addObject:user];
//                    [_meetsArray addObject:meet];
//                    [_meetsIdArray addObject:document.documentID];
//                    [self.tableView reloadData];
//                }];
//            }
//            //NSLog(@"%@", _meetsIdDictionary);
//            [self addNewAddMeetsObserver];
//        }
//    }];
//
//}
//
//- (void) addNewAddMeetsObserver{
//    NSString *queryString = [NSString stringWithFormat:@"participatedUsersList.%@.startTime", _facebookId];
//    FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
//    FIRQuery *query = [meetsRef queryOrderedByField:queryString];
//    [query addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
//        if (snapshot == nil) {
//            NSLog(@"Error fetching documents: %@", error);
//            return;
//        }
//        for (FIRDocumentChange *diff in snapshot.documentChanges) {
//            if (diff.type == FIRDocumentChangeTypeAdded) {
//
//                NSString *documentId = diff.document.documentID;
//                if([_meetsIdArray indexOfObject:diff.document.documentID] == NSNotFound){
//                    Meet *meet = [[Meet alloc] initWithDictionary:diff.document.data];
//
//                    NSString *creatorFacebookId = meet.creatorFacebookId;
//                    FIRDocumentReference *userRef = [[_db collectionWithPath:@"Users"] documentWithPath:creatorFacebookId];
//                    [userRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
//                        User *user;
//                        if (snapshot != nil) {
//                            //NSLog(@"Document data: %@", snapshot.data);
//                            user = [[User alloc] initWithDictionary:snapshot.data];
//
//                        } else {
//                            NSLog(@"Document does not exist");
//                            user = [[User alloc] init];
//                        }
//                        [_meetsUserArray addObject:user];
//                        [_meetsArray addObject:meet];
//                        [_meetsIdArray addObject:documentId];
//
//                        //HEAP SORT
//                        NSDictionary *doc = heapSort(_meetsArray, _meetsIdArray, _meetsUserArray);
//                        //NSLog(@"%@", doc);
//                        _meetsArray = doc[@"meetsArray"];
//                        _meetsIdArray = doc[@"meetsIdArray"];
//                        _meetsUserArray = doc[@"meetsUserArray"];
//
//                        [self.tableView reloadData];
//                    }];
//                }
//
//            }
//            if (diff.type == FIRDocumentChangeTypeModified) {
//                //NSLog(@"Modified city: %@", diff.document.data);
//            }
//            if (diff.type == FIRDocumentChangeTypeRemoved) {
//                NSLog(@"Removed meet: %@", diff.document.data);
//                NSString *documentId = diff.document.documentID;
//                NSInteger index = [_meetsIdArray indexOfObject:documentId];
//                [_meetsArray removeObjectAtIndex:index];
//                [_meetsIdArray removeObjectAtIndex:index];
//                [_meetsUserArray removeObjectAtIndex:index];
//                [self.tableView reloadData];
//            }
//        }
//
//        //
//    }];
//}


@end
