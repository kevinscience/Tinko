//
//  NearbyTinkoTableVC.h
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface NearbyTinkoTableVC : UITableViewController <XLPagerTabStripChildItem, CLLocationManagerDelegate>

@end
