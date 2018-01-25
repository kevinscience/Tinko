//
//  NewFriendsRequestFolder.m
//  Tinko
//
//  Created by Donghua Xue on 1/23/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "NewFriendsRequestFolder.h"
#import "AppDelegate.h"
#import "NewFriendsRequestTVCell.h"
#import "NewFriendsRequest.h"
#import "WebClient.h"
@import Firebase;

@interface NewFriendsRequestFolder ()
@property(weak, nonatomic)NSManagedObjectContext *context;
@property(weak, nonatomic)NSPersistentContainer *container;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property FIRFirestore *db;
@end

@implementation NewFriendsRequestFolder

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _db = FIRFirestore.firestore;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _container = appDelegate.persistentContainer;
    _context = _container.viewContext;
    [self initializeFetchedResultsController];
    [self setRequestRead];
}

- (void)initializeFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewFriendsRequest"];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"requestTime" ascending:YES];
    
    [request setSortDescriptors:@[sort]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
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
    NewFriendsRequestTVCell *cell = nil;
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewFriendsRequestTVCell" owner:self options:nil];
        cell = (NewFriendsRequestTVCell *)[nib objectAtIndex:0];
    }
    
    NewFriendsRequest *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setCellDataWithNewFriendsRequest:request];
    
    cell.acceptButton.tag = indexPath.row;
    [cell.acceptButton addTarget:self action:@selector(acceptButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 66;
}


- (void) setRequestRead{
    [_container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"NewFriendsRequest"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"read = %@", @NO]];
        NSError *error = nil;
        NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
        NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
        for (NewFriendsRequest *request in array){
            FIRDocumentReference *requestRef = [[[[_db collectionWithPath:@"Users"] documentWithPath:facebookId]
                                                 collectionWithPath:@"NewFriendsFolder"] documentWithPath:request.requester];
            [requestRef updateData:@{
                                     @"read": @YES
                                     } completion:^(NSError * _Nullable error) {
                                         if (error != nil) {
                                             NSLog(@"Error updating document: %@", error);
                                         } else {
                                             NSLog(@"Document successfully updated");
                                             [NewFriendsRequest updateNewFriendsRequestWithRequest:request WithRead:YES withType:request.type withContext:context];
                                         }
                                     }];
        }
    }];
}

-(void)acceptButtonClicked:(UIButton*)sender
{
    NSInteger row = sender.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    NewFriendsRequest *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"NewFriendsRequestFolder: acceptButtonClicked: requester = %@", request.requester);
    NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    NSDictionary *postDic = @{
                              @"requester":request.requester,
                              @"responsor":facebookId
                              };
    [WebClient postMethodWithCode:@"initializeTwoWayFriendship" withData:postDic withCompletion:^{
        [NewFriendsRequest updateNewFriendsRequestWithRequest:request WithRead:YES withType:[@1 integerValue] withContext:_context];
    } withError:^(NSString *error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerwillchangeContent");
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"controllerdidchangesection");
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex-1] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex-1] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"controllerwilldidchangeObject");
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerdidchangecontent");
    [self.tableView endUpdates];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
