//
//  TinkoRootVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "TinkoRootVC.h"
#import "TinkoTableVC.h"
#import "NearbyTinkoTableVC.h"
#import "ManageTinkoTableVC.h"

@interface TinkoRootVC ()

@end

@implementation TinkoRootVC
{
    BOOL _isReload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isProgressiveIndicator = YES;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self moveToViewControllerAtIndex:1];
    [self.buttonBarView setBackgroundColor:[UIColor clearColor]];
    [self.buttonBarView.selectedBar setBackgroundColor:[UIColor orangeColor]];
    [self.buttonBarView removeFromSuperview];
    [self.navigationController.navigationBar addSubview:self.buttonBarView];
    
    self.changeCurrentIndexProgressiveBlock = ^void(XLButtonBarViewCell *oldCell, XLButtonBarViewCell *newCell, CGFloat progressPercentage, BOOL changeCurrentIndex, BOOL animated){
        if (changeCurrentIndex) {
            [oldCell.label setTextColor:[UIColor colorWithWhite:1 alpha:0.6]];
            [newCell.label setTextColor:[UIColor whiteColor]];
            
            if (animated) {
                [UIView animateWithDuration:0.1
                                 animations:^(){
                                     if(self.currentIndex == 1){
                                         newCell.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                     } else {
                                         newCell.transform = CGAffineTransformMakeScale(1.05, 1.05);
                                     }
                                     
                                     if(self.currentIndex == 0 || self.currentIndex == 2){
                                         oldCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                     } else{
                                         oldCell.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                     }
                                     
                                 }
                                 completion:nil];
            }
            else{
                if(self.currentIndex == 1){
                    newCell.transform = CGAffineTransformMakeScale(1.1, 1.1);
                } else {
                    newCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }
                
                if(self.currentIndex == 0 || self.currentIndex == 2){
                    oldCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } else{
                    oldCell.transform = CGAffineTransformMakeScale(0.8, 0.8);
                }
            }
        }
    };
}

#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    // create child view controllers that will be managed by XLPagerTabStripViewController
    NearbyTinkoTableVC * child_0 = [[NearbyTinkoTableVC alloc] initWithStyle:UITableViewStylePlain];
    TinkoTableVC * child_1 = [[TinkoTableVC alloc] initWithStyle:UITableViewStylePlain];
    ManageTinkoTableVC * child_2 = [[ManageTinkoTableVC alloc] initWithStyle:UITableViewStylePlain];
    
    if (!_isReload){
        
        return @[child_0, child_1, child_2];
    }
    
    NSMutableArray * childViewControllers = [NSMutableArray arrayWithObjects:child_0, child_1, child_2, nil];
    NSUInteger count = [childViewControllers count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [childViewControllers exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSUInteger nItems = 1 + (rand() % 8);
    return [childViewControllers subarrayWithRange:NSMakeRange(0, nItems)];
}

-(void)reloadPagerTabStripView
{
    _isReload = YES;
    self.isProgressiveIndicator = (rand() % 2 == 0);
    self.isElasticIndicatorLimit = (rand() % 2 == 0);
    [super reloadPagerTabStripView];
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
