//
//  MainTabBarVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/21/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "MainTabBarVC.h"
#import "CreateTableVC.h"

@interface MainTabBarVC ()

@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}

-(bool) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    //NSLog(@"%lu", (unsigned long)tabBarController.selectedIndex);
    if(viewController == [tabBarController.viewControllers objectAtIndex:1]){
        //self.selectedIndex = prevTab; //only change in this method
        //NSLog(@"Pressed add!");
        CreateTableVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTableVCID"];
        UINavigationController *objNav = [[UINavigationController alloc] initWithRootViewController:secondView];
        [self presentViewController: objNav animated:YES completion: nil];
        
        return NO;
    }else{
        return YES;
    }
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
