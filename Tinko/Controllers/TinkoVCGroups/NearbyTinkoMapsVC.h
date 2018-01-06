//
//  NearbyTinkoMapsVC.h
//  Tinko
//
//  Created by Donghua Xue on 1/4/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface NearbyTinkoMapsVC : UIViewController <XLPagerTabStripChildItem, CLLocationManagerDelegate, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property UIPanGestureRecognizer *swipedOnTableView;
@end
