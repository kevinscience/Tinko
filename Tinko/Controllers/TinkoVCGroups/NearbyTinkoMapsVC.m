//
//  NearbyTinkoMapsVC.m
//  Tinko
//
//  Created by Donghua Xue on 1/4/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "NearbyTinkoMapsVC.h"
#import <GeoFire/GeoFire.h>
#import "Meet.h"
#import "SharedMeet.h"
#import "TinkoCell.h"
#import "TinkoRootVC.h"
#import "TinkoDisplayRootVC.h"
@import Firebase;
@import FirebaseDatabase;
@import MapKit;

@interface NearbyTinkoMapsVC ()
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) FIRDatabaseReference *dbRef;
@property (strong, nonatomic) GeoFire *geoRire;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *researchButton;
@property CGFloat drawerOriginalOriginY;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSMutableArray *meetsArray;
@property NSMutableArray *meetsIdArray;
@property NSMutableArray *meetsMarkerArray;
@property NSMutableArray *meetsUserArray;
@property NSMutableDictionary *selectedMeet;
@property GFCircleQuery *circleQuery;
@property GFRegionQuery *regionQuery;
//@property GMSMarker *selectedMarker;
@end

@implementation NearbyTinkoMapsVC {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _table.delegate = self;
    _table.dataSource = self;
    _meetsArray = [[NSMutableArray alloc] init];
    _meetsIdArray = [[NSMutableArray alloc] init];
    _meetsMarkerArray = [[NSMutableArray alloc] init];
    _meetsUserArray = [[NSMutableArray alloc] init];
    _selectedMeet = [[NSMutableDictionary alloc] init];
    //_selectedMarker = [[GMSMarker alloc] init];
    
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    [locationManager requestWhenInUseAuthorization];
    
    _coordinate.latitude=locationManager.location.coordinate.latitude;
    _coordinate.longitude=locationManager.location.coordinate.longitude;
    NSLog(@"viewdidload: Latitude: %f, Longitude: %f", _coordinate.latitude, _coordinate.longitude);

    _researchButton.hidden = YES;
    
    

//
    CGFloat bottomPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    } else {
        bottomPadding = 0;
    }
    CGFloat tabbarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat minimumTableViewHeight = 157 + tabbarHeight + 40;
    //NSLog(@"viewdidload: tabbarheight: %f, bottomPadding: %f", tabbarHeight, bottomPadding);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    _table.frame = CGRectMake(0, screenHeight-minimumTableViewHeight, self.view.frame.size.width, minimumTableViewHeight);
    _swipedOnTableView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOnTableViewActivity:)];
    _swipedOnTableView.delegate = self;
    [_table addGestureRecognizer:_swipedOnTableView];
    [_table setUserInteractionEnabled:YES];
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    TinkoRootVC *tinkoRootVC = self.parentViewController;
    [_swipedOnTableView requireGestureRecognizerToFail:tinkoRootVC.containerView.panGestureRecognizer];
    [self.table.panGestureRecognizer requireGestureRecognizerToFail:_swipedOnTableView];
    
}





-(void)setSelfLocationMapView{
    _coordinate.latitude=locationManager.location.coordinate.latitude;
    _coordinate.longitude=locationManager.location.coordinate.longitude;
    NSLog(@"SetselflocationMapview: Latitude: %f, Longitude: %f", _coordinate.latitude, _coordinate.longitude);
    
//    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:_coordinate];
//    [_mapView animateWithCameraUpdate:updatedCamera];
//    NSLog(@"NearbyTinkoMapsVC: inside setSelfLocationMapView");

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:(_coordinate.latitude == 0.0) ? -33.8683 : _coordinate.latitude
                                                            longitude:(_coordinate.longitude == 0.0) ? 151.2086 : _coordinate.longitude
                                                                 zoom:12];
    _mapView.camera = camera;
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    
    [self doGeoFireQuery];
}

#pragma mark -- google maps delegate

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    //self.mapView = mapView;
    double lat = mapView.camera.target.latitude;
    double lon = mapView.camera.target.longitude;
    double epsilon = 0.0001;
    if(fabs(_coordinate.latitude - lat) <= epsilon && fabs(_coordinate.longitude - lon) <= epsilon){
//        _researchButton.hidden = YES;
//        NSLog(@"lat lon are same");
    } else {
        _researchButton.hidden = NO;
        //NSLog(@"lat lon are not same");
    }
    
    //NSLog(@"didchange lat: %f, lon: %f", lat, lon);
//    float zoomLevel = mapView.camera.zoom;
//    NSLog(@"float: %f", zoomLevel);
    
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    NSString *key = marker.userData;
    
    NSInteger index = [_meetsIdArray indexOfObject:key];
    NSLog(@"marker userdata: %@, index: %ld", key, (long)index);
//    GMSMarker *markerIndex = [_meetsMarkerArray objectAtIndex:index];
//    _mapView.selectedMarker = markerIndex;
    
    //[_meetsMarkerArray exchangeObjectAtIndex:0 withObjectAtIndex:index];
    [_meetsIdArray exchangeObjectAtIndex:0 withObjectAtIndex:index];
    [_meetsArray exchangeObjectAtIndex:0 withObjectAtIndex:index];
    [self.table reloadData];
    return NO;
}

- (void) doGeoFireQuery{
    [_mapView clear];
    [_meetsArray removeAllObjects];
    [_meetsIdArray removeAllObjects];
    
    _circleQuery.removeAllObservers;
    _regionQuery.removeAllObservers;
    
    
    self.dbRef = [[FIRDatabase database] reference];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:[_dbRef child:@"Meets"]];
    
    

    double lat = _mapView.camera.target.latitude;
    double lon = _mapView.camera.target.longitude;
    CLLocation *center = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
     //Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
    _circleQuery = [geoFire queryAtLocation:center withRadius:11];
    float zoomlevel = _mapView.camera.zoom;
   
    GMSVisibleRegion visibleRegion = _mapView.projection.visibleRegion;
    MKCoordinateRegion region = [self convertGMSVisibleRegionToMKCoordinateRegion:visibleRegion];
    _regionQuery = [geoFire queryWithRegion:region];
    
    FIRDatabaseHandle queryHandle = [zoomlevel>11.07?_regionQuery:_circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
       // NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        
        
        
        FIRDocumentReference *docRef = [[FIRFirestore.firestore collectionWithPath:@"Meets"] documentWithPath:key];
        [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
            if (snapshot != nil) {
                //NSLog(@"Document data: %@", snapshot.data);
                Meet *meet = [[Meet alloc] initWithDictionary:snapshot.data];
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = loc;
                marker.title = meet.title;
                marker.snippet = meet.placeName;
                marker.userData = key;
                marker.map = _mapView;
                
                NSString *creatorFacebookId = meet.creatorFacebookId;
                FIRDocumentReference *userRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:creatorFacebookId];
                [userRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
                    User *user;
                    if (snapshot != nil) {
                        //NSLog(@"Document data: %@", snapshot.data);
                        user = [[User alloc] initWithDictionary:snapshot.data];
                        
                    } else {
                        NSLog(@"Document does not exist");
                        user = [[User alloc] init];
                    }
                    
                    
                    if(_meetsIdArray.count == 0){
                        _mapView.selectedMarker = marker;
                        //marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
                        [_meetsIdArray addObject:key];
                        [_meetsArray addObject:meet];
                        [_meetsUserArray addObject:user];
                        //[_meetsMarkerArray addObject:marker];
                    } else {
                        [_meetsIdArray insertObject:key atIndex:1];
                        [_meetsArray insertObject:meet atIndex:1];
                        [_meetsUserArray insertObject:user atIndex:1];
                        //[_meetsMarkerArray insertObject:marker atIndex:1];
                    }
                    
                    [self.table reloadData];
                    
                    
                }];
                
            } else {
                NSLog(@"Document does not exist: %@", key);
            }
        }];

    }];
}

- (IBAction)researchButtonPressed:(id)sender {
    NSLog(@"research button pressed");
    _researchButton.hidden = YES;
    [self doGeoFireQuery];
}


-(MKCoordinateRegion)convertGMSVisibleRegionToMKCoordinateRegion:(GMSVisibleRegion)visibleRegion{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
    CLLocationDegrees latitudeDelta = bounds.northEast.latitude - bounds.southWest.latitude;
    CLLocationDegrees longitudeDelta = bounds.northEast.longitude - bounds.southWest.longitude;
    CLLocationCoordinate2D centre = CLLocationCoordinate2DMake(
                                                                (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
                                                                (bounds.southWest.longitude + bounds.northEast.longitude) / 2);
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    MKCoordinateRegion region = MKCoordinateRegionMake(centre, span);
    return region;
}


#pragma mark - location manager

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status==kCLAuthorizationStatusNotDetermined){
        [locationManager requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self setSelfLocationMapView];
    } else if (status == kCLAuthorizationStatusAuthorizedAlways){
        [self setSelfLocationMapView];
    }else if (status == kCLAuthorizationStatusRestricted){
        [locationManager requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusDenied){
        [locationManager requestWhenInUseAuthorization];
    }
}


#pragma mark - gesture recognizer


-(void)swipeOnTableViewActivity:(UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _drawerOriginalOriginY = _table.frame.origin.y;
    }
    
    if (sender.state == UIGestureRecognizerStateChanged){
        
        _table.frame = CGRectMake(0, _drawerOriginalOriginY+translation.y, self.view.frame.size.width, self.view.frame.size.height - _drawerOriginalOriginY-translation.y);
    }
    
    if (sender.state == UIGestureRecognizerStateEnded){
        CGFloat bottomPadding;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            bottomPadding = window.safeAreaInsets.bottom;
        } else {
            bottomPadding = 0;
        }
        CGFloat tabbarHeight = self.tabBarController.tabBar.frame.size.height;
        CGFloat minimumTableViewHeight = 157 + tabbarHeight;
        //NSLog(@"gesturerecognizer: tabbarheight: %f, bottomPadding: %f", tabbarHeight, bottomPadding);
        CGFloat velocityY = (0.2*[sender velocityInView:self.view].y);
        CGFloat finalY = _drawerOriginalOriginY + translation.y + velocityY;
        if(finalY>self.view.frame.size.height- minimumTableViewHeight){
            finalY = self.view.frame.size.height-minimumTableViewHeight;
        } else if (finalY < self.view.frame.size.height - 124*_meetsArray.count - 33 - tabbarHeight - 40){
            finalY = self.view.frame.size.height - 124*_meetsArray.count - 33 - tabbarHeight - 40;
        }
        CGFloat animationDuration = (ABS(velocityY)*0.0002)+0.2;
        NSLog(@"the duration is: %f", animationDuration);
        [UIView animateWithDuration:animationDuration animations:^{
            _table.frame = CGRectMake(0, finalY, self.view.frame.size.width, self.view.frame.size.height - finalY);
        }];
    }
    
}



-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _meetsArray.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0){
        static NSString *simpleTableIdentifier = @"cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        TinkoCell *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TinkoCell" owner:self options:nil];
            cell = (TinkoCell *)[nib objectAtIndex:0];
        }
        if(_meetsArray.count > 0 && _meetsArray.count > indexPath.row-1){
            [cell setCellData:_meetsArray[indexPath.row-1] withUser:_meetsUserArray[indexPath.row-1]];
        }
        
        
        return cell;
    }
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
         [self.table deselectRowAtIndexPath:indexPath animated:NO];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TinkoDisplayRootVC *secondView = [storyboard instantiateViewControllerWithIdentifier:@"TinkoDisplayRootVCID"];
        //TinkoDisccusionVC *secondView = [TinkoDisccusionVC new];
        secondView.hidesBottomBarWhenPushed = YES;
        SharedMeet *sharedMeet = [SharedMeet sharedMeet];
        Meet *meet = _meetsArray[indexPath.row-1];
        [sharedMeet setMeet:meet];
        [sharedMeet setMeetId:_meetsIdArray[indexPath.row-1]];
        NSLog(@"TinkoTable: %@", meet.title);
        [self.navigationController pushViewController: secondView animated:YES];
         [self.table deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        return 33.0f;
    } else {
       return 124.0f;
    }
    
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
