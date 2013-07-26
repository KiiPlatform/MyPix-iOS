//
//
// Copyright 2013 Kii Corporation
// http://kii.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

#import "ViewController.h"

#import <KiiSDK/Kii.h>

#define FILE_BUCKET_NAME    @"mypix"

@interface ViewController () {
    NSMutableArray *_cells;
    BOOL _loaded;
}

@end

@implementation ViewController

- (void) showLogin
{
    KTLoginViewController *vc = [[KTLoginViewController alloc] init];
    [self.navigationController presentViewController:vc animated:TRUE completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{    
    // get the image
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // shrink it down to be quicker to load..
    // we don't need them big for this use case anyway
    UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(280, 280)];
    
    // show the progress indicator
    [KTLoader showLoader:@"Uploading My Image"
                animated:TRUE
           withIndicator:KTLoaderIndicatorProgress];
    
    // start the upload
    KiiFileBucket *bucket = [[KiiUser currentUser] fileBucketWithName:FILE_BUCKET_NAME];
    KiiFile *file = [bucket fileWithData:UIImageJPEGRepresentation(newImage, 1.0f)];
    [file saveFileWithProgressBlock:^(KiiFile *file, double progress) {
        
        // update the progress indicator
        if(progress < 1.0f) {
            
            [KTLoader setProgress:progress];
        }
        
        // if our progress is 1, we're doing final processing
        else {
            
            [KTLoader showLoader:@"Finishing..."];
        }
        
    }

                 andCompletionBlock:^(KiiFile *file, NSError *error) {
                     
                     if(error == nil) {
                         
                         // hide the progress indicator
                         [KTLoader showLoader:@"Image Uploaded!"
                                     animated:TRUE
                                withIndicator:KTLoaderIndicatorSuccess
                              andHideInterval:KTLoaderDurationAuto];
                         
                     } else {
                         
                         // hide the progress indicator
                         [KTLoader showLoader:@"Error Uploading!"
                                     animated:TRUE
                                withIndicator:KTLoaderIndicatorError
                              andHideInterval:KTLoaderDurationAuto];
                     }
                     
                     // reload the table
                     [self refreshQuery];

                 }];
    
    // dismiss the view
    [picker dismissViewControllerAnimated:TRUE completion:nil];
}

- (void) addImageWithSource:(UIImagePickerControllerSourceType)source
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.sourceType = source;
    
    [self.navigationController presentViewController:picker animated:TRUE completion:nil];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL hasLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if(buttonIndex == 0 && hasCamera) {
        
        // show the camera
        [self addImageWithSource:UIImagePickerControllerSourceTypeCamera];
        
    } else if( (buttonIndex == 0 && hasLibrary) || (buttonIndex == 1 && hasCamera) ) {

        // show the library
        [self addImageWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
}

- (void) addImage:(id)sender
{
    // show a UIActionSheet with options
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet setTitle:@"Choose a source"];
    [sheet setDelegate:self];
    
    int ndx = 0;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet addButtonWithTitle:@"Camera"];
        ++ndx;
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [sheet addButtonWithTitle:@"Photo Library"];
        ++ndx;
    }
    
    if(ndx > 0) {
        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setCancelButtonIndex:ndx];
        [sheet showInView:self.view];
    }
    
    // we don't have any picture sources, tell the user
    else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                     message:@"Unable to find any picture sources on your device"
                                                    delegate:nil
                                           cancelButtonTitle:@"Done"
                                           otherButtonTitles:nil];
        [av show];
    }
}

- (void) logOut:(id)sender
{
    // log the user out
    [KiiUser logOut];
    
    // show the login view, since we don't allow
    // users to see the main view without being logged in
    [self showLogin];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _cells = [[NSMutableArray alloc] init];

    // add our buttons
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addImage:)];
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(logOut:)];
    
    [self.navigationItem setTitle:@"MyPix"];
    [self.navigationItem setLeftBarButtonItem:add];
    [self.navigationItem setRightBarButtonItem:logout];
}

- (UITableViewCell*) tableView:(UITableView *)tableView
              cellForKiiObject:(id)kiiObject
                   atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    __block KiiFile *file = (KiiFile*)kiiObject;

    // see if this cell exists already
    for(UITableViewCell *searchCell in _cells) {
        if(searchCell.tag == file.hash) {
            cell = searchCell;
            break;
        }
    }
    
    if(cell == nil) {
        
        NSString *reuseID = [NSString stringWithFormat:@"Cell_%d", file.hash];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseID];
        cell.tag = file.hash;
        
        KTImageView *imageView = [[KTImageView alloc] initWithFrame:CGRectMake(20, 20, 280, 280) andKiiFile:file];
        imageView.backgroundColor = [UIColor darkGrayColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = TRUE;
        [cell.contentView addSubview:imageView];
        [imageView show];
        
        [_cells addObject:cell];
    }

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320.f;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if we don't have an authenticated user
    if(![KiiUser loggedIn]) {
        
        // show a login
        [self showLogin];
        
    } else if(!_loaded) {
        
        // load our table
        self.bucket = [[KiiUser currentUser] fileBucketWithName:FILE_BUCKET_NAME];
        
        KiiQuery *query = [KiiQuery queryWithClause:nil];
        [query sortByDesc:@"_created"];
        self.query = query;
        
        self.pageSize = 10;
    
        [self refreshQuery];
        
        _loaded = TRUE;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
