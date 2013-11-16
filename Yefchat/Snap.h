//
//  Snap.h
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Snap : NSObject
@property NSString *sender;
@property NSDate *timestamp;
@property BOOL isVideo;
@property NSData *data;
@property NSString *mediaID;

@end
