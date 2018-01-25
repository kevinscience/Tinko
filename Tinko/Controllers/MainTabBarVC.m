//
//  MainTabBarVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/21/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "MainTabBarVC.h"
#import "CreateTableVC.h"
#import "AppDelegate.h"
#import "NewFriendsRequest.h"
#import "User.h"
#import "CDUser.h"
@import Firebase;
@import CoreData;

@interface MainTabBarVC ()
@property UITabBarItem *tabBarItemMe;
@property(weak, nonatomic)NSPersistentContainer *container;
@property(weak, nonatomic)NSManagedObjectContext *context;
@property NSString *facebookId;
@property FIRFirestore *db;
@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    _db = FIRFirestore.firestore;
    [_db collectionWithPath:@"force-initialization"]; 
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _container = appDelegate.persistentContainer;
    _context = _container.viewContext;
    [_context setMergePolicy:NSOverwriteMergePolicy];
    
    _tabBarItemMe = [self.tabBar.items objectAtIndex:2];
    [_tabBarItemMe setImage:[self imageWithImage:[UIImage imageNamed:@"newfriends"] scaledToSize:CGSizeMake(30, 30)]];
    
    [self addFriendsListSnapshotListener];
    [self addNewFriendsRequestSnapshotListener];
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

-(void) addFriendsListSnapshotListener{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FIRCollectionReference *friendsListRef = [_db collectionWithPath:[NSString stringWithFormat:@"Users/%@/Friends_List", _facebookId]];
        [friendsListRef addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot == nil) {
                NSLog(@"Error fetching documents: %@", error);
                return;
            }
            for (FIRDocumentChange *diff in snapshot.documentChanges) {
                if (diff.type == FIRDocumentChangeTypeAdded) {
                    NSString *userFacebookId = diff.document.documentID;
                    NSLog(@"MainTabBarVC: addFriendsSnapshotListener: userFacebookId: %@", userFacebookId);
                    FIRDocumentReference *userDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:userFacebookId];
                    [userDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                        if (snapshot.exists) {
                            //NSLog(@"myDocRef Document data: %@", snapshot.data);
                            NSDictionary *dic = snapshot.data;
                            User *user = [[User alloc] initWithDictionary:dic];
                            [_context performBlock:^{
                                [CDUser createOrUpdateCDUserWithUser:user withContext:_context];
                            }];
                            
                        } else {
                            NSLog(@"Document does not exist");
                        }
                    }];
                }
                //                if (diff.type == FIRDocumentChangeTypeModified) {
                //                    NSLog(@"Modified city: %@", diff.document.data);
                //                }
                //                if (diff.type == FIRDocumentChangeTypeRemoved) {
                //                    NSLog(@"Removed city: %@", diff.document.data);
                //                }
            }
        }];
    });
    
}

-(void) addNewFriendsRequestSnapshotListener{
    // add snapshot listener for NewFriendsFolder
    [_container performBackgroundTask:^(NSManagedObjectContext * context) {
        NSManagedObjectContext *moc = context;
        [moc setMergePolicy:NSOverwriteMergePolicy];
        FIRCollectionReference *newFriendsRef = [[[_db collectionWithPath:@"Users"] documentWithPath:_facebookId] collectionWithPath:@"NewFriendsFolder"];
        [[newFriendsRef queryWhereField:@"read" isEqualTo:@NO] addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot == nil) {
                NSLog(@"Error fetching documents: %@", error);
                return;
            }
            
            for (FIRDocumentChange *diff in snapshot.documentChanges) {
                if (diff.type == FIRDocumentChangeTypeAdded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tabBarItemMe setBadgeValue:@""];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFriendsRequestNotification" object:self];
                    });
                    //NSLog(@"MainTabBarVC: NewFriendsRequest:%@", document.data);
                    NSDictionary *requestDic = diff.document.data;
                    NSString *requesterFacebookId = requestDic[@"requester"];
                    
                    FIRDocumentReference *userDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:requesterFacebookId];
                    [userDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                        if (snapshot.exists) {
                            //NSLog(@"Document data: %@", snapshot.data);
                            NSDictionary *userDic = snapshot.data;
                            [NewFriendsRequest createNewFriendsRequestWithRequestDic:requestDic withUserDic:userDic withContext:moc];
                            NSError *error = nil;
                            if ([moc hasChanges] && ![moc save:&error]) {
                                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                                abort();
                            }
                        } else {
                            NSLog(@"Document does not exist");
                        }
                    }];
                }
            }
        }];
    }];
}

//-(void) addNewFriendsRequestSnapshotListener{
//    // add snapshot listener for NewFriendsFolder
//    FIRCollectionReference *newFriendsRef = [[[_db collectionWithPath:@"Users"] documentWithPath:_facebookId] collectionWithPath:@"NewFriendsFolder"];
//    [[newFriendsRef queryWhereField:@"read" isEqualTo:@NO] addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
//        if (snapshot == nil) {
//            NSLog(@"Error fetching documents: %@", error);
//            return;
//        }
//
//        for (FIRDocumentChange *diff in snapshot.documentChanges) {
//            if (diff.type == FIRDocumentChangeTypeAdded) {
//                [_tabBarItemMe setBadgeValue:@""];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFriendsRequestNotification" object:self];
//
//                //NSLog(@"MainTabBarVC: NewFriendsRequest:%@", document.data);
//                NSDictionary *requestDic = diff.document.data;
//                NSString *requesterFacebookId = requestDic[@"requester"];
//
//                FIRDocumentReference *userDocRef = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:requesterFacebookId];
//                [userDocRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
//                    if (snapshot.exists) {
//                        //NSLog(@"Document data: %@", snapshot.data);
//                        NSDictionary *userDic = snapshot.data;
//                        [NewFriendsRequest createNewFriendsRequestWithRequestDic:requestDic withUserDic:userDic withContext:_context];
//                        NSError *error = nil;
//                        if ([_context hasChanges] && ![_context save:&error]) {
//                            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
//                            abort();
//                        }
//                    } else {
//                        NSLog(@"Document does not exist");
//                    }
//                }];
//            }
//        }
//    }];
//}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
