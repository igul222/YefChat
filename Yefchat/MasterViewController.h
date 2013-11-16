//
//  MasterViewController.h
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsPickerViewController.h"

@interface MasterViewController : UITableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FriendsPickerViewControllerDelegate, UIAlertViewDelegate> {
    UIImagePickerController *picker;
    
    NSData *data;
    BOOL isVideo;
}
@end
