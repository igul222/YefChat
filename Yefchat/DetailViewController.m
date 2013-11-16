//
//  DetailViewController.m
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import "DetailViewController.h"
#import "Snap.h"
#import "SnapchatClient.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        [[SnapchatClient sharedClient] getMediaForSnap:self.detailItem callback:^(NSData *snap) {
            // we have data
            UIImage *image = [UIImage imageWithData:snap];
            UIImageView *iview = [[UIImageView alloc] initWithFrame:self.view.bounds];
            iview.image = image;
            [self.view addSubview:iview];
        }];
//        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
