//
//  TinkoTableVC.h
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
@import CoreData;

@interface TinkoTableVC : UITableViewController <XLPagerTabStripChildItem,NSFetchedResultsControllerDelegate>
@end
