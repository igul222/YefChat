//
//  FriendsPickerViewController.h
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendsPickerViewControllerDelegate <NSObject>
-(void)friendsPickerDidReturnWithFriends:(NSArray *)friends;
@end

@interface FriendsPickerViewController : UITableViewController {
    NSMutableArray *deselectedRows;
}
@property(weak) id delegate;
@end
