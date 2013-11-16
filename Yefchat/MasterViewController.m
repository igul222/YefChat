//
//  MasterViewController.m
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SnapchatClient.h"
#import "Snap.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SVProgressHUD.h"

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

-(void)refresh {
    [SVProgressHUD showWithStatus:@"Refreshing"];
    [[SnapchatClient sharedClient] startRefreshWithCallback:^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:@"Refreshed!"];
    }];
}

-(void)add {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo or Video...", @"Choose from Library...", @"Vine...", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==0) {
        // Capture
        picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else if(buttonIndex==1) {
        picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else if(buttonIndex==2) {
        // Vine
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    isVideo = ![info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"];
    if(isVideo) {
        data = [NSData dataWithContentsOfFile:info[UIImagePickerControllerMediaURL]];
    } else {
        data = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.5);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        FriendsPickerViewController *friendsPicker = [[FriendsPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        friendsPicker.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:friendsPicker];
        [self presentViewController:nav animated:YES completion:nil];
    }];
}

-(void)friendsPickerDidReturnWithFriends:(NSArray *)friends {
    [SVProgressHUD showWithStatus:@"Sending"];
    [[SnapchatClient sharedClient] sendData:data toRecipients:friends isVideo:isVideo callback:^{
        [SVProgressHUD showSuccessWithStatus:@"Sent!"];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SnapchatClient sharedClient].snaps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Snap *snap = [SnapchatClient sharedClient].snaps[indexPath.row];

    cell.textLabel.text = snap.sender;
    cell.detailTextLabel.text = [snap.timestamp description];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Snap *snap = [SnapchatClient sharedClient].snaps[indexPath.row];
        [[segue destinationViewController] setDetailItem:snap];
    }
}

@end
