//
//  TinkoTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "TinkoTableVC.h"
#import "TinkoCell.h"
@import Firebase;

@interface TinkoTableVC ()
@property NSMutableArray *meetsArray;
@property NSMutableArray *meetsIdArray;

@end

@implementation TinkoTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _meetsArray = [[NSMutableArray alloc] init];
    _meetsIdArray = [[NSMutableArray alloc] init];
    
    NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    
    NSString *queryString = [NSString stringWithFormat:@"selectedFriendsList.%@", facebookId];
    FIRCollectionReference *meetsRef = [FIRFirestore.firestore collectionWithPath:@"Meets"];
    //FIRQuery *query = [meetsRef queryWhereField:queryString isGreaterThan:0];
    FIRQuery *query = [meetsRef queryOrderedByField:queryString];
   // FIRQuery *query = [meetsRef queryWhereField:@"allowPeopleNearby" isEqualTo:[NSNumber numberWithBool:YES]];
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting documents: %@", error);
         } else {
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 NSLog(@"%@ => %@", document.documentID, document.data);
                 [_meetsArray addObject:document.data];
                 [_meetsIdArray addObject:document.documentID];
                 [self.tableView reloadData];
             }
         }
     }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [cell setCellData:_meetsArray[indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    return 124.0f;
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @" Tinko ";
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
