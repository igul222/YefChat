//
//  FriendsPickerViewController.m
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import "FriendsPickerViewController.h"
#import "SnapchatClient.h"

@implementation FriendsPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.title = @"Send to...";
    deselectedRows = [[NSMutableArray alloc] init];
}

-(void)done {
    NSArray *friends = @[];
    
    for(int i=0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(!( (i < deselectedRows.count) && [deselectedRows objectAtIndex:i] ))
            friends = [friends arrayByAddingObject:cell.textLabel.text];
    }
    
    [self.delegate friendsPickerDidReturnWithFriends:friends];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SnapchatClient sharedClient].friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    cell.textLabel.text = [SnapchatClient sharedClient].friends[indexPath.row];
    cell.accessoryType = ((indexPath.row < deselectedRows.count) && [deselectedRows objectAtIndex:indexPath.row] ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark);

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if((indexPath.row < deselectedRows.count) && [deselectedRows objectAtIndex:indexPath.row]) {
        [deselectedRows removeObjectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        [deselectedRows insertObject:@(TRUE) atIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
