//
//  ProfileUpdateTableVC.m
//  Tinko
//
//  Created by Donghua Xue on 12/23/17.
//  Copyright © 2017 KevinScience. All rights reserved.
//

#import "ProfileUpdateTableVC.h"
#import "ThisUser.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <GooglePlaces/GooglePlaces.h>
@import Firebase;

@interface ProfileUpdateTableVC ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPicker;
@property ThisUser *thisUser;
@property BOOL genderPickerVisible;
@property NSArray *genderPickerData;
@end

@implementation ProfileUpdateTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Profile";
    
    
    _thisUser = [ThisUser thisUser];
    User *user = _thisUser.user;
    [self.profilePhoto sd_setImageWithURL:[NSURL URLWithString:user.photoURL]
                  placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                           options:SDWebImageRefreshCached];
    _usernameLabel.text = user.username;
    _genderLabel.text = user.gender;
    _regionLabel.text = user.location;
    
    _genderPickerData = @[@"Male", @"Female", @"Unspecified"];
    self.genderPicker.dataSource = self;
    self.genderPicker.delegate = self;
    
    NSInteger defaultIndex;
    @try{
        defaultIndex = [_genderPickerData indexOfObject:user.gender];
    }
    @catch(NSException *exception){
        
    }
    @finally{
        defaultIndex = 0;
    }
    
    [self.genderPicker selectRow:defaultIndex inComponent:0 animated:NO];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    self.genderPickerVisible = NO;
    self.genderPicker.hidden = YES;
    self.genderPicker.translatesAutoresizingMaskIntoConstraints = NO;
}
- (void)showGenderPickerCell {
    self.genderPickerVisible = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.genderPicker.alpha = 0.0f;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.genderPicker.alpha = 1.0f;
                     } completion:^(BOOL finished){
                         self.genderPicker.hidden = NO;
                     }];
}

- (void)hideGenderPickerCell {
    self.genderPickerVisible = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.genderPicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.genderPicker.hidden = YES;
                     }];
}

-(void)ShowSelectedGender
{
    NSInteger row = [_genderPicker selectedRowInComponent:0];
    NSString *gender = [_genderPickerData objectAtIndex:row];
    User *user = _thisUser.user;
    FIRDocumentReference *userDoc = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:user.facebookId];
    [userDoc updateData:@{@"gender":gender} completion:^(NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Error updating document: %@", error);
        } else {
            NSLog(@"Document successfully updated");
            user.gender = gender;
            [_thisUser setUser:user];
        }
    }];
    _genderLabel.text = gender;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 2){
            if (self.genderPickerVisible){
                [self hideGenderPickerCell];
                [self ShowSelectedGender];
            } else {
                [self showGenderPickerCell];
            }
        } else if(indexPath.row == 4){
            GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
            acController.delegate = self;
            GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
            filter.type = kGMSPlacesAutocompleteTypeFilterRegion;
            acController.autocompleteFilter = filter;
            [self presentViewController:acController animated:YES completion:nil];
        }
        
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            height = 80.0f;
        }else if(indexPath.row == 3){
            height = self.genderPickerVisible ? 139.0f : 0.0f;
        }
        
    }
    return height;
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
    self.regionLabel.text = place.name;
    
    User *user = _thisUser.user;
    FIRDocumentReference *userDoc = [[FIRFirestore.firestore collectionWithPath:@"Users"] documentWithPath:user.facebookId];
    [userDoc updateData:@{@"location":place.name} completion:^(NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Error updating document: %@", error);
        } else {
            NSLog(@"Document successfully updated");
            user.location = place.name;
            [_thisUser setUser:user];
        }
    }];
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


// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _genderPickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _genderPickerData[row];
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
