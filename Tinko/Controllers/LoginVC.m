//
//  ViewController.m
//  Tinko
//
//  Created by Donghua Xue on 12/19/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "LoginVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MainTabBarVC.h"
#import "WebClient.h"
@import Firebase;

@interface LoginVC()
@property FIRFirestore *db;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    //loginButton.loginBehavior = FBSDKLoginBehaviorNative;
    loginButton.loginBehavior = FBSDKLoginBehaviorWeb;
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_location"];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    loginButton.delegate = self;
    self.db = FIRFirestore.firestore;
}

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    if (error == nil) {
        if(result.isCancelled){
            return;
        }
        [loginButton setHidden:YES];
        FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          
                                          NSLog(@"Firebase signInWithCredential error, %@", error.description);
                                          return;
                                      }
                                      FIRCollectionReference *usersRef = [self.db collectionWithPath:@"Users"];
                                      [[usersRef queryWhereField:@"uid" isEqualTo:user.uid]
                                       getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
                                           if (error != nil) {
                                               NSLog(@"Error getting documents: %@", error);
                                           } else {
                                               NSInteger *count = snapshot.documents.count;
                                               NSLog(@"uid query: %lu", (unsigned long)count);
                                               if(count!=0){
                                                   FIRDocumentSnapshot *document = snapshot.documents[0];
                                                   NSDictionary *dic = document.data;
                                                   NSString *facebookId = dic[@"facebookId"];
                                                   [[NSUserDefaults standardUserDefaults] setObject:facebookId forKey:@"facebookId"];
                                                   MainTabBarVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarVCID"];
                                                   [self presentViewController: secondView animated:YES completion: nil];
                                               } else {
                                                   [self callInitializeNewUserApi:user];
                                               }
                                               
                                           }
                                       }];

                                  }];
    } else {
        NSLog(error.localizedDescription);
    }
}

-(void) callInitializeNewUserApi:(FIRUser*)user{
    
// User successfully signed in. Get user data from the FIRUser object
//NSLog(@"Firebase signInWithCredential success, %@, %@, %@, %@", user.displayName,user.email,user.photoURL, user.uid);
//------------------------------------------------------------------------------------------------------------------------------
//GET FACEBOOK GRAPH API INFO
NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
[parameters setValue:@"id,name,email,friends,location,gender" forKey:@"fields"];
[[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
   startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                id result, NSError *error) {
       if(error != nil){
           NSLog(@"FBSDKGraphRequest Error: %@", error);
           return;
       }
       NSString *facebookId = result[@"id"];

       NSString *gender = result[@"gender"];
       NSString *location = result[@"location"][@"name"];
       NSArray *friendsList = result[@"friends"][@"data"];
       if(gender == nil){
           gender = @"";
       }
       if(location == nil){
           location = @"";
       }
       // add user's facebookId to userdefaults
       [[NSUserDefaults standardUserDefaults] setObject:facebookId forKey:@"facebookId"];
       //NSLog(@"My facebookId is %@, gender is %@, location is %@", facebookId, gender, location);
       NSLog(@"friendsList: %@", friendsList);
       //NSURL *photoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",result[@"id"]]];
       //NSLog(@"photoURL: %@", photoUrl);
       //NSLog(@"connection: %@", connection);
       //NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
       //NSLog(@"result: %@", result);
       //NSLog(@"error: %@", error);
       NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] initWithDictionary:result];
       [resultDic setObject:user.uid forKey:@"uid"];
       NSLog(@"resultDic: %@", resultDic);

       //WebClient *webClient = [[WebClient alloc] init];
       [WebClient postMethodWithCode:@"initializeNewUser" withData:resultDic withCompletion:^{
           //Start new viewController
           MainTabBarVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarVCID"];
           [self presentViewController: secondView animated:YES completion: nil];

       } withError:^(NSString *error) {
           UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
           [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               NSError *signOutError;
               BOOL status = [[FIRAuth auth] signOut:&signOutError];
               if (!status) {
                   NSLog(@"Error signing out: %@", signOutError);
                   return;
               }
               FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
               [loginManager logOut];
               [FBSDKAccessToken setCurrentAccessToken:nil];
           }]];
           [self presentViewController:alertController animated:YES completion:nil];
       }];
   }];
}


- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"facebook logout button test");
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
