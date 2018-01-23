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
@import Firebase;
@import CoreData;

@interface MainTabBarVC ()
@property UITabBarItem *tabBarItemMe;
@property(weak, nonatomic)NSPersistentContainer *container;
@property(weak, nonatomic)NSManagedObjectContext *context;
@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _container = appDelegate.persistentContainer;
    _context = _container.viewContext;
    [_context setMergePolicy:NSOverwriteMergePolicy];
    
    _tabBarItemMe = [self.tabBar.items objectAtIndex:2];
    [_tabBarItemMe setImage:[self imageWithImage:[UIImage imageNamed:@"newfriends"] scaledToSize:CGSizeMake(30, 30)]];
    
    
    
    // add snapshot listener for NewFriendsFolder
    NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    FIRCollectionReference *newFriendsRef = [[[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:facebookId] collectionWithPath:@"NewFriendsFolder"];
    [[newFriendsRef queryWhereField:@"read" isEqualTo:@NO] addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (snapshot == nil) {
            NSLog(@"Error fetching documents: %@", error);
            return;
        }
        
        NSInteger count = snapshot.count;
        NSLog(@"NewFriendsRequest: count = %ld", (long)count);
        if(count == 0){
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tabBarItemMe setBadgeValue:@""];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFriendsRequestNotification" object:self];
        });
        for (FIRDocumentSnapshot *document in snapshot.documents) {
            
            NSLog(@"MainTabBarVC: NewFriendsRequest:%@", document.data);
            [NewFriendsRequest createNewFriendsRequestWithDic:document.data withContext:_context];
            NSError *error = nil;
            if ([_context hasChanges] && ![_context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }
    }];
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
