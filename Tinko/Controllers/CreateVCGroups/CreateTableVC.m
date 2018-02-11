//
//  CreateTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/21/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "CreateTableVC.h"
#import <GooglePlaces/GooglePlaces.h>
@import Firebase;

@interface CreateTableVC () <GMSAutocompleteViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateTimePicker;
@property BOOL datePickerVisible;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxParticipantsTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property NSDate *pickerDate;
@property GMSPlace *place;
@property NSMutableArray *selectedFriendsArray;
@property BOOL allowPeopleNearby;
@property BOOL allFriends;
@property NSString *facebookId;
@end

@implementation CreateTableVC

//TODO invitationRange nil completion
//TODO Keyboard and make view up

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showCurrentDate];
    [self.dateTimePicker setMinimumDate:[NSDate date]];
    _facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:56/255.0 green:135/255.0 blue:186/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                       NSFontAttributeName:[UIFont systemFontOfSize:19 weight:UIFontWeightSemibold]}];
    _selectedFriendsArray = [[NSMutableArray alloc] init];
}

- (IBAction)postAction:(id)sender {
    NSString *title = _titleTextField.text;
    NSString *duration = _durationTextField.text;
    if([duration length] == 0){
        duration = @"1 hour";
    }
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *maxNo = [f numberFromString:_maxParticipantsTextField.text];
    if([_maxParticipantsTextField.text length] == 0){
        maxNo = [NSNumber numberWithInt:10];
    }
    NSString *description = _descriptionTextField.text;
    
    FIRGeoPoint *coordinate = [[FIRGeoPoint alloc] initWithLatitude:_place.coordinate.latitude longitude:_place.coordinate.longitude];
    if(_pickerDate == nil){
        _pickerDate = [NSDate date];
    }
    double now = [[NSDate date] timeIntervalSince1970];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"dd"];
//    NSString *stringFromDateNow = [formatter stringFromDate:n];
//    NSInteger negativeIntegerDateNow = -[stringFromDateNow integerValue];
    NSMutableDictionary *selectedFriendsDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *time = @{
                           @"startTime" : _pickerDate,
                           @"postTime" : [NSNumber numberWithDouble:-now],
                           @"status" : @YES
                           };
    
    [_selectedFriendsArray addObject:_facebookId];
    for (NSString *friendFacebookId in _selectedFriendsArray){
        [selectedFriendsDictionary setObject:time forKey:friendFacebookId];
    }
    NSDictionary *participatedUsersList = @{_facebookId:time};
    NSDictionary *meet = @{
                           @"title" : title,
                           @"creator" : _facebookId,
                           @"startTime" : _pickerDate,
                           @"postTime" : [NSDate date],
                           @"duration" : duration,
                           @"place" : @{
                                       @"name" : _place.name,
                                       @"address" : _place.formattedAddress,
                                       @"coordinate" : coordinate
                                       },
                           @"allowPeopleNearby" : [NSNumber numberWithBool:_allowPeopleNearby],
                           @"allFriends" : [NSNumber numberWithBool:_allFriends],
                           @"selectedFriendsList" : selectedFriendsDictionary,
                           @"maxNo" : maxNo,
                           @"description" : description,
                           @"status" : @YES,
                           @"participatedUsersList" : participatedUsersList
                           };
    NSLog(@"meet: %@", meet);
    __block FIRDocumentReference *ref =
    [[FIRFirestore.firestore collectionWithPath:@"Meets"] addDocumentWithData:meet completion:^(NSError * _Nullable error) {
                                                                      if (error != nil) {
                                                                          NSLog(@"Error adding document: %@", error);
                                                                      } else {
                                                                          NSLog(@"Document added with ID: %@", ref.documentID);
                                                                      }
                                                                  }];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    self.datePickerVisible = NO;
    self.dateTimePicker.hidden = YES;
    self.dateTimePicker.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)showStatusPickerCell {
    self.datePickerVisible = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.dateTimePicker.alpha = 0.0f;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.dateTimePicker.alpha = 1.0f;
                     } completion:^(BOOL finished){
                         self.dateTimePicker.hidden = NO;
                     }];
}

- (void)hideStatusPickerCell {
    self.datePickerVisible = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.dateTimePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.dateTimePicker.hidden = YES;
                     }];
}


-(void)ShowSelectedDate
{   NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, YYYY    hh:mm a"];
    self.timeLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromDate:_dateTimePicker.date]];
    _pickerDate = _dateTimePicker.date;
}

-(void)showCurrentDate{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, YYYY    hh:mm a"];
    self.timeLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.section == 0 && indexPath.row == 2){
        height = self.datePickerVisible ? 216.0f : 0.0f;
    } else if (indexPath.section == 2 && indexPath.row == 0){
        height = 160.0f;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (self.datePickerVisible){
            [self hideStatusPickerCell];
            [self ShowSelectedDate];
        } else {
            [self showStatusPickerCell];
        }
    } else if (indexPath.section == 0 && indexPath.row == 4){
        GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
        acController.delegate = self;
        [self presentViewController:acController animated:YES completion:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)friendsListSelectTableVCDidFinish:(FriendsListSelectTableVC *)friendListSelectTableVC{
    _selectedFriendsArray = friendListSelectTableVC.selectedFriendsArray;
    _allowPeopleNearby = friendListSelectTableVC.allowPeopleNearby;
    _allFriends = friendListSelectTableVC.allFriends;
    //NSLog(@"delegate method: %@",selectedFriendsArray);
    //NSLog(allowPeopleNearby ? @"allowPeopleNearby YES" : @"allowPeopleNearby NO");
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendsListSelectTableVCIdentifier"]) {
        UIViewController *newController = segue.destinationViewController;
        FriendsListSelectTableVC *vc = (FriendsListSelectTableVC *) newController;
        vc.delegate = self;
    }
}

//-----------------------------------------------------------------------------------------------------
// GOOGLE Place AutoComplete
// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place coordinate, latitude: %d, longtitude: %d",place.coordinate.latitude, place.coordinate.longitude);
    self.placeNameLabel.text = place.name;
    self.place = place;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
