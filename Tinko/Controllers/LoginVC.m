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
@import Firebase;

@interface LoginVC()
@property FIRFirestore *db;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
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
        FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          
                                          NSLog(@"Firebase signInWithCredential error, %@", error.description);
                                          return;
                                      }
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
                                           NSLog(@"result: %@", result);
                                           NSLog(@"error: %@", error);
                                           
                                           //-------------------------------------------------------------------------------------------------------------------------
                                           // update to CLOUD FIRESTORE if there is no record
                                           FIRDocumentReference *myDocRef = [[self.db collectionWithPath:@"Users"] documentWithPath:facebookId];
                                           [myDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                                               if (snapshot.exists) {
                                                   NSLog(@"Document data: %@", snapshot.data);
                                               } else {
                                                   NSLog(@"Document does not exist");
                                                   NSDictionary *myDocData = @{
                                                                               @"facebookId": facebookId,
                                                                               @"username": user.displayName,
                                                                               @"email": user.email,
                                                                               @"uid":user.uid,
                                                                               @"photoURL":[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",facebookId],
                                                                               @"gender": gender,
                                                                               @"location":location
                                                                               };
                                                   [[[self.db collectionWithPath:@"Users"] documentWithPath:facebookId] setData:myDocData completion:^(NSError * _Nullable error) {
                                                                                                                                    if (error != nil) {
                                                                                                                                        NSLog(@"Error adding document: %@", error);
                                                                                                                                    } else {
                                                                                                                                        NSLog(@"Document added with FacebookID: %@", facebookId);
                                                                                                                                    }
                                                                                                                                }];
                                                   //--------------------------------------------------------------------------------------------------------------------------------------
                                                   for(NSDictionary *friendDic in friendsList){
                                                       NSString *friendFacebookId = friendDic[@"id"];
                                                       FIRDocumentReference *friendDocRef = [[self.db collectionWithPath:@"Users"] documentWithPath:friendFacebookId];
                                                       [friendDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                                                           if (snapshot.exists) {
                                                               NSLog(@"friendDic exisits %@, snapshot: %@", friendFacebookId, snapshot.data);
                                                               //---------------------------------------------------------------------------------------------------------------------------
                                                               //ADD his profile to my friends_list
                                                               NSDictionary *friendDocData = snapshot.data;
                                                               [[[myDocRef collectionWithPath:@"Friends_List"] documentWithPath:[friendDic[@"id"] stringValue]] setData:friendDocData completion:^(NSError * _Nullable error) {
                                                                                                                                                                            if (error != nil) {
                                                                                                                                                                                NSLog(@"add his profile to my friends_list Error adding document: %@", error);
                                                                                                                                                                            } else {
                                                                                                                                                                                NSLog(@"add his profile to my friends_list success Friend's facebookId: %@", friendDic[@"id"]);
                                                                                                                                                                            }
                                                                                                                                                                        }];
                                                               //-----------------------------------------------------------------------------------------------------------------------------
                                                               //Add my profile to his friends_list
                                                               [[[friendDocRef collectionWithPath:@"Friends_List"] documentWithPath:facebookId] setData:myDocData completion:^(NSError * _Nullable error) {
                                                                                                                                                                        if (error != nil) {
                                                                                                                                                                            NSLog(@"add my profile to his friends_list Error adding document: %@", error);
                                                                                                                                                                        } else {
                                                                                                                                                                            NSLog(@"add my profile to his friends_list Friend's FacebookID: %@", friendDic[@"id"]);
                                                                                                                                                                        }
                                                                                                                                                                    }];
                                                               
                                                               
                                                           } else {
                                                               NSLog(@"friendDoc does not exist");
                                                           }
                                                       }];
                                                       
                                                       
                                                       
                                                   }
                                               }
                                           }];
                                           
                                       }];
                                      //------------------------------------------------------------------------------------------------------------------------------
                                      
                                      
                                      
                                      //-------------------------------------------------------------------------------------------------------------------------------
                                      //Start new viewController
                                      MainTabBarVC *secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarVCID"];
                                      [self presentViewController: secondView animated:YES completion: nil];
                                      //-------------------------------------------------------------------------------------------------------------------------------
                                  }];
    } else {
        NSLog(error.localizedDescription);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
