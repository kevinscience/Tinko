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
@import Firebase;

@interface ManageTinkoTableVC ()
@property NSMutableArray<Meet *> *meetsArray;
@property NSMutableArray *meetsIdArray;
@property NSMutableDictionary *meetsIdDictionary;
@property FIRFirestore *db;
@property NSString *facebookId;
@end

@implementation ManageTinkoTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _meetsArray = [[NSMutableArray alloc] init];
    _meetsIdArray = [[NSMutableArray alloc] init];
    _meetsIdDictionary = [[NSMutableDictionary alloc] init];
    _db = FIRFirestore.firestore;
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    [self loadExistedMeetsFromFirestore];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)loadExistedMeetsFromFirestore{
    NSString *queryString = [NSString stringWithFormat:@"participatedUsersList.%@.startTime", _facebookId];
    FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
    FIRQuery *query = [meetsRef queryOrderedByField:queryString];
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
                [_meetsIdDictionary setObject:@YES forKey:document.documentID];
            }
            [self.tableView reloadData];
            //NSLog(@"%@", _meetsIdDictionary);
            [self addNewAddMeetsObserver];
        }
    }];
    
}

- (void) addNewAddMeetsObserver{
    NSString *queryString = [NSString stringWithFormat:@"participatedUsersList.%@.startTime", _facebookId];
    FIRCollectionReference *meetsRef = [_db collectionWithPath:@"Meets"];
    FIRQuery *query = [meetsRef queryOrderedByField:queryString];
    [query addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
            NSLog(@"Error fetching documents: %@", error);
            return;
        }
        for (FIRDocumentChange *diff in snapshot.documentChanges) {
            if (diff.type == FIRDocumentChangeTypeAdded) {
                
                NSString *documentId = diff.document.documentID;
                if([_meetsIdDictionary objectForKey:documentId] == nil){
                    Meet *meet = [[Meet alloc] initWithDictionary:diff.document.data];
                    NSLog(@"New meet: %@", diff.document.data);
                    [_meetsArray addObject:meet];
                    [_meetsIdArray addObject:documentId];
                    [_meetsIdDictionary setObject:@YES forKey:documentId];
                    
                    //HEAP SORT
                    NSDictionary *doc = heapSort(_meetsArray, _meetsIdArray);
                    //NSLog(@"%@", doc);
                    _meetsArray = doc[@"meetsArray"];
                    _meetsIdArray = doc[@"meetsIdArray"];
                    [self.tableView reloadData];
                }
                
            }
            if (diff.type == FIRDocumentChangeTypeModified) {
                //NSLog(@"Modified city: %@", diff.document.data);
            }
            if (diff.type == FIRDocumentChangeTypeRemoved) {
                NSLog(@"Removed meet: %@", diff.document.data);
            }
        }
        
        //
    }];
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

@end
