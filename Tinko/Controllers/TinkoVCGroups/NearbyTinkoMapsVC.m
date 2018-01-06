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
#import "TinkoCell.h"
#import "TinkoRootVC.h"
@import Firebase;
@import FirebaseDatabase;
@import MapKit;

@interface NearbyTinkoMapsVC ()
@property (nonatomic) CLLocationCoordinate2D coordinate;
//@property GMSMapView *mapView;
@property (strong, nonatomic) FIRDatabaseReference *dbRef;
@property (strong, nonatomic) GeoFire *geoRire;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *researchButton;
//@property (weak, nonatomic) IBOutlet UIImageView *drawerImage;
//@property UIPanGestureRecognizer *swipedOnImage;

@property CGFloat drawerOriginalOriginY;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSMutableArray *meetsArray;
@property NSMutableArray *meetsIdArray;
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

    
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    [locationManager requestWhenInUseAuthorization];
    
    _coordinate.latitude=locationManager.location.coordinate.latitude;
    _coordinate.longitude=locationManager.location.coordinate.longitude;
    NSLog(@"viewdidload: Latitude: %f, Longitude: %f", _coordinate.latitude, _coordinate.longitude);

    _researchButton.hidden = YES;
    
    
    
//    _drawerImage.frame = CGRectMake(0, self.view.frame.size.height-283, self.view.frame.size.width, 33);
//    _swipedOnImage = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOnImageActivity:)];
//    [_drawerImage addGestureRecognizer:_swipedOnImage];
//    [_drawerImage setUserInteractionEnabled:YES];
//
    _table.frame = CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width, 250);
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
    
    GMSVisibleRegion visibleRegion = _mapView.projection.visibleRegion;
    [self doGeoFireQuery];
}


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

- (void) doGeoFireQuery{
    [_mapView clear];
    [_meetsArray removeAllObjects];
    [_meetsIdArray removeAllObjects];
    GMSVisibleRegion visibleRegion = _mapView.projection.visibleRegion;
    
    self.dbRef = [[FIRDatabase database] reference];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:[_dbRef child:@"Meets"]];

    //CLLocation *center = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
    //GFCircleQuery *circleQuery = [geoFire queryAtLocation:center withRadius:7];
    MKCoordinateRegion region = [self convertGMSVisibleRegionToMKCoordinateRegion:visibleRegion];
    GFRegionQuery *regionQuery = [geoFire queryWithRegion:region];
    FIRDatabaseHandle queryHandle = [regionQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        
        [_meetsIdArray addObject:key];
        
        FIRDocumentReference *docRef = [[FIRFirestore.firestore collectionWithPath:@"Meets"] documentWithPath:key];
        [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
            if (snapshot != nil) {
                //NSLog(@"Document data: %@", snapshot.data);
                Meet *meet = [[Meet alloc] initWithDictionary:snapshot.data];
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = loc;
                marker.title = meet.title;
                marker.snippet = meet.placeName;
                marker.map = _mapView;
                
                [_meetsArray insertObject:meet atIndex:0];
                [self.table reloadData];
                
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
//
//-(void)swipeOnImageActivity:(UIPanGestureRecognizer*)sender
//{
//    CGPoint translation = [sender translationInView:self.view];
//
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        _drawerOriginalOriginY = _drawerImage.frame.origin.y;
//    }
//
//    if (sender.state == UIGestureRecognizerStateChanged){
//        _drawerImage.frame = CGRectMake(0, _drawerOriginalOriginY + translation.y, self.view.frame.size.width, 33);
//
//        _table.frame = CGRectMake(0, _drawerOriginalOriginY+33+translation.y, self.view.frame.size.width, self.view.frame.size.height - _drawerOriginalOriginY-33-translation.y);
//    }
//
//}

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
        CGFloat velocityY = (0.2*[sender velocityInView:self.view].y);
        CGFloat finalY = _drawerOriginalOriginY + translation.y + velocityY;
        if(finalY>self.view.frame.size.height-207){
            finalY = self.view.frame.size.height-207;
        } else if (finalY < self.view.frame.size.height - 124*_meetsArray.count - 33 - 60){
            finalY = self.view.frame.size.height - 124*_meetsArray.count - 33 - 60;
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
        
        return cell;
    } else {
        TinkoCell *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TinkoCell" owner:self options:nil];
            cell = (TinkoCell *)[nib objectAtIndex:0];
        }
        if(_meetsArray.count > 0 && _meetsArray.count > indexPath.row-1){
            [cell setCellData:_meetsArray[indexPath.row-1]];
        }
        
        
        return cell;
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