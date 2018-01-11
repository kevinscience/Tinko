//
//  TinkoDetailVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/29/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "TinkoDetailVC.h"
#import "SharedMeet.h"
#import "Meet.h"
#import "TinkoCell.h"
#import "WebClient.h"


@interface TinkoDetailVC ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property Meet *meet;
@property SharedMeet *sharedMeet;
@property (nonatomic, strong) WebClient *client;
@property NSString *facebookId;
@property BOOL participating;
@end

//Fetch New Meet Data in ViewDIdLoad and apply to table
@implementation TinkoDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _table.delegate = self;
    _table.dataSource = self;
    _client = [[WebClient alloc] init];
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _sharedMeet = [SharedMeet sharedMeet];
    _meet = [_sharedMeet meet];
    NSLog(@"TinkoDetail: %@", _meet.title);
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    NSArray *participatedUsersList = _meet.participatedUsersList;
    _participating = [participatedUsersList containsObject:_facebookId];
    // Do any additional setup after loading the view from its nib.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0){
        TinkoCell *cell = nil;
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TinkoCell" owner:self options:nil];
            cell = (TinkoCell *)[nib objectAtIndex:0];
        }
        [cell setCellData:_meet withUser:nil];
        
        
        
        return cell;
    } else {
        static NSString *simpleTableIdentifier = @"cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(participateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:_participating ? @"Participating" : @"Partcipate" forState:UIControlStateNormal];
        button.frame = CGRectMake(0.0, 0.0, 160.0, 40.0);
        [cell addSubview:button];
        return cell;
    }
    
}

-(void)participateButtonClicked:(UIButton*)sender{
    NSLog(@"participateButtonClicked");
    NSString *meetId = [_sharedMeet meetId];
    NSString *code = _participating ? @"leaveMeet" : @"participateMeet";
    [_client participateOrLeaveMeetWithCode:code withMeetId:meetId withFacebookId:_facebookId withCompletion:^{
        _participating = !_participating;
        [sender setTitle:_participating ? @"Participating" : @"Partcipate" forState:UIControlStateNormal];
    } withError:^(NSString *error) {
        [self presentAlertControllerWithError:error];
    }];
    
}

-(void)presentAlertControllerWithError:(NSString*)error{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 124.0f;
}


#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
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

//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    <#code#>
//}

//- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    <#code#>
//}
//
//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
