//
//  TempVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "TempVC.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "LoginVC.h"
@import Firebase;

@interface TempVC ()

@end

@implementation TempVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
        [loginButton setDelegate:self];
        //loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
        loginButton.center = self.view.center;
        [self.view addSubview:loginButton];
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"facebook logout button test");
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    LoginVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVCID"];
    [self presentViewController: secondView animated:YES completion: nil];
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
