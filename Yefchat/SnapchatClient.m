//
//  SnapchatClient.m
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import "SnapchatClient.h"
#import "Snap.h"

@implementation SnapchatClient

+ (SnapchatClient *)sharedClient {
    static SnapchatClient *gInstance = NULL;

    @synchronized(self)
    {
        if (gInstance == NULL)
            gInstance = [[self alloc] init];
    }
    
    return(gInstance);
}

-(id)init {
    self = [super init];
    if(self) {
        _snaps = @[];
        _friends = @[@"igul222", @"yefim", @"spoonpics", @"yefchat"];
    }
    return self;
}

-(void)startLoginWithUsername:(NSString *)username password:(NSString *)password callback:(void (^)(void))callback {
    callback();
}

-(void)startRefreshWithCallback:(void (^)(void))callback {
    Snap *snap = [[Snap alloc] init];
    snap.sender = @"John Appleseed";
    snap.timestamp = [[NSDate alloc] init];
    _snaps = [_snaps arrayByAddingObject:snap];
    
    callback();
}

-(void)sendData:(NSData *)data toRecipients:(NSArray *)recipients isVideo:(BOOL)video callback:(void (^)(void))callback {
    callback();
}

@end
