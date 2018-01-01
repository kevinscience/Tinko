//
//  TinkoDisplayRootVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/29/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "TinkoDisplayRootVC.h"
#import "TinkoDetailVC.h"
#import "TinkoDisccusionVC.h"
#import "TempVC.h"

@interface TinkoDisplayRootVC ()

@end

@implementation TinkoDisplayRootVC
{
    BOOL _isReload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isReload = NO;
    self.isProgressiveIndicator = YES;
    self.isElasticIndicatorLimit = YES;
    
    //SAVE MY LIFE
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    //[self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    
}


#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    // create child view controllers that will be managed by XLPagerTabStripViewController
    TinkoDetailVC * child_1 = [self.storyboard instantiateViewControllerWithIdentifier:@"TinkoDetailVCID"];
    //TinkoDisccusionVC * child_2 = [self.storyboard instantiateViewControllerWithIdentifier:@"TinkoDiscussionVCID"];
    TinkoDisccusionVC *child_2 = [TinkoDisccusionVC new];
    //MessageViewController *child_2 = [MessageViewController new];
    //TempVC * child_2 = [self.storyboard instantiateViewControllerWithIdentifier:@"TempVCID"];
    
    if (!_isReload){
        return @[child_1, child_2];
    }
    
    NSMutableArray * childViewControllers = [NSMutableArray arrayWithObjects:child_1, child_2, nil];
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

- (IBAction)reloadTapped:(id)sender {
    _isReload = YES;
    [self reloadPagerTabStripView];
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
