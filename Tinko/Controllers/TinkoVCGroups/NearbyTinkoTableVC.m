//
//  NearbyTinkoTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "NearbyTinkoTableVC.h"
#import <GeoFire/GeoFire.h>
#import "Meet.h"
#import "TinkoCell.h"
#import "TinkoDisplayRootVC.h"
#import "SharedMeet.h"
@import Firebase;
@import FirebaseDatabase;


@interface NearbyTinkoTableVC ()
@property (strong, nonatomic) FIRDatabaseReference *dbRef;
@property (strong, nonatomic) GeoFire *geoRire;
@property NSMutableArray *meetsArray;
@property NSMutableArray *meetsIdArray;
@end

@implementation NearbyTinkoTableVC {
    CLLocationManager *locationManager;
}
//TODO If user deny the location perimission
//TODO First time use lat and lon = 0
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _meetsArray = [[NSMutableArray alloc] init];
    _meetsIdArray = [[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    [locationManager requestWhenInUseAuthorization];
    //[self updateNearbyTinko];
//    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        [locationManager requestWhenInUseAuthorization];
//        NSLog(@"The app has user location permission");
//    } else {
//        NSLog(@"User deny location Permission");
//        [locationManager requestWhenInUseAuthorization];
//    }
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)updateNearbyTinko{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude=locationManager.location.coordinate.latitude;
    coordinate.longitude=locationManager.location.coordinate.longitude;
    NSLog(@"Latitude: %f, Longitude: %f", coordinate.latitude, coordinate.longitude);
    
    
    self.dbRef = [[FIRDatabase database] reference];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:[_dbRef child:@"Meets"]];
    
    CLLocation *center = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
    GFCircleQuery *circleQuery = [geoFire queryAtLocation:center withRadius:7];
    
    FIRDatabaseHandle queryHandle = [circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        //NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        
        [_meetsIdArray addObject:key];
        FIRDocumentReference *docRef =
        [[FIRFirestore.firestore collectionWithPath:@"Meets"] documentWithPath:key];
        [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
            if (snapshot != nil) {
                //NSLog(@"Document data: %@", snapshot.data);
                Meet *meet = [[Meet alloc] initWithDictionary:snapshot.data];
                [_meetsArray insertObject:meet atIndex:0];
                [self.tableView reloadData];
            } else {
                NSLog(@"Document does not exist: %@", key);
            }
        }];
        
    }];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status==kCLAuthorizationStatusNotDetermined){
        [locationManager requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self updateNearbyTinko];
    } else if (status == kCLAuthorizationStatusAuthorizedAlways){
        [self updateNearbyTinko];
    }else if (status == kCLAuthorizationStatusRestricted){
        [locationManager requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusDenied){
        [locationManager requestWhenInUseAuthorization];
    }
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 124.0f;
}


#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"Nearby";
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
