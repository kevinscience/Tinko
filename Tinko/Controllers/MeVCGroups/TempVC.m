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
#import "WebClient.h"
#import "NSDictionary.h"
#import <Crashlytics/Crashlytics.h>
@import Firebase;

@interface TempVC ()

@end

@implementation TempVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
        FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
        [loginButton setDelegate:self];
        //loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
        loginButton.center = self.view.center;
        [self.view addSubview:loginButton];
    
    UILabel * label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.text = @"XLPagerTabStrip";
    [self.view addSubview:label];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-50.0]];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, 50, 100, 30);
    [button setTitle:@"Crash" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(crashButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    button.center = CGPointMake(40, 150);
    [self.view addSubview:button];
}

- (IBAction)crashButtonTapped:(id)sender {
    [[Crashlytics sharedInstance] crash];
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
- (IBAction)testButtonPressed:(id)sender {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email,friends,location,gender" forKey:@"fields"];
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error != nil){
            NSLog(@"FBSDKGraphRequest Error: %@", error);
            return;
        }
        NSLog(@"result: %@", result);
        NSDictionary *resultDic = [[NSDictionary alloc] initWithDictionary:result];
        //NSString *resultJson = [resultDic bv_jsonStringWithPrettyPrint:NO];
        //NSLog(@"resultJson: %@", resultJson);
        WebClient *webClient = [[WebClient alloc] init];
        [webClient postMethodWithCode:@"initializeNewUser" withData:result withCompletion:^{

        } withError:^(NSString *error) {

        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"Discussion";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
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
