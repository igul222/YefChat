//
//  SnapchatClient.m
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import "SnapchatClient.h"
#import "Snap.h"
#include <CommonCrypto/CommonDigest.h>
#include "AFHTTPRequestOperationManager.h"

#define SECRET @"iEk21fuwZApXlz93750dmW22pw389dPwOk"
#define PATTERN @"0001110111101110001111010101111011010001001110011000110001000110"
#define STATIC_TOKEN @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9"
#define URL @"https://feelinsonice--hrd-appspot-com-sfa0vorks4ru.runscope.net/bq"
// #define URL @"https://feelinsonice-hrd.appspot.com/bq"

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
        // _friends = @[@"igul222", @"yefim", @"spoonpics", @"yefchat"];
        _friends = @[];
    }
    return self;
}

-(NSString*) sha256:(NSString *)clear{
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];

    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (unsigned int)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

-(NSString *)hashFirst:(NSString *)first second:(NSString *)second {
    first = [SECRET stringByAppendingString:first];
    second = [second stringByAppendingString:SECRET];

    NSString *hash1 = [self sha256:first];
    NSString *hash2 = [self sha256:second];

    NSMutableString *result = [[NSMutableString alloc] init];

    for (int i = 0; i < PATTERN.length; i++) {
        unichar c = [PATTERN characterAtIndex:i];
        if (c == '0') {
          [result appendString:[hash1 substringWithRange:NSMakeRange(i, 1)]];
        } else {
          [result appendString:[hash2 substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return result;
}

-(void)startLoginWithUsername:(NSString *)username password:(NSString *)password callback:(void (^)(void))callback {
    _username = username;

    long ts = (long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000);

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data[@"username"] = username;
    data[@"password"] = password;
    data[@"timestamp"] = @(ts);
    data[@"req_token"] = [self hashFirst:STATIC_TOKEN second:[NSString stringWithFormat:@"%li", ts]];
    data[@"version"] = @"6.0.0";

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[URL stringByAppendingString:@"/login"] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        _authToken = responseObject[@"auth_token"];
        
        NSArray *newSnaps = @[];
        NSArray *snapJsons = responseObject[@"snaps"];
        for (int i = 0; i < snapJsons.count; i++) {
            NSDictionary *snapJson = snapJsons[i];
            if([snapJson objectForKey:@"sn"]) {
                Snap *snap = [[Snap alloc] init];
                snap.sender = snapJson[@"sn"];
                snap.timestamp = [NSDate dateWithTimeIntervalSince1970:[snapJson[@"ts"] doubleValue]/1000];
                snap.mediaID = snapJson[@"id"];
                newSnaps = [newSnaps arrayByAddingObject:snap];
            }
        }
        
        NSArray *newFriends = @[];
        NSArray *friendJsons = responseObject[@"friends"];
        for (int i = 0; i < friendJsons.count; i++) {
            NSDictionary *friendJson = friendJsons[i];
            NSString *friend = friendJson[@"name"];
            newFriends = [newFriends arrayByAddingObject:friend];
        }
        
        _friends = newFriends;
        _snaps = newSnaps;
        
        callback();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
}

-(void)startRefreshWithCallback:(void (^)(void))callback {
    
    if(!_authToken) {
        NSLog(@"NO AUTH TOKEN FUCK");
        callback();
        return;
    }
    
    long ts = (long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000);

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data[@"timestamp"] = @(ts);
    data[@"req_token"] = [self hashFirst:_authToken second:[NSString stringWithFormat:@"%li", ts]];
    data[@"version"] = @"6.0.0";
    data[@"username"] = _username;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[URL stringByAppendingString:@"/all_updates"] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"JSON: %@", responseObject);

          NSArray *newSnaps = @[];
        
          NSArray *snapJsons = responseObject[@"updates_response"][@"snaps"];
          for (int i = 0; i < snapJsons.count; i++) {
              
              NSDictionary *snapJson = snapJsons[i];

              if([snapJson objectForKey:@"sn"]) {
                  Snap *snap = [[Snap alloc] init];
                  snap.sender = snapJson[@"sn"];
                  snap.timestamp = [NSDate dateWithTimeIntervalSince1970:[snapJson[@"ts"] doubleValue]/1000];
                  snap.mediaID = snapJson[@"id"];
                  newSnaps = [newSnaps arrayByAddingObject:snap];
              }
          }
          _snaps = newSnaps;
          callback();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);
    }];
}


-(void)getMediaForSnap:(Snap *)snap callback:(void (^)(NSData *snap))callback {
    
    long ts = (long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000);
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data[@"id"] = snap.mediaID;
    data[@"timestamp"] = @(ts);
    data[@"username"] = _username;
    data[@"req_token"] = [self hashFirst:_authToken second:[NSString stringWithFormat:@"%li", ts]];
    data[@"version"] = @"6.0.0";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[URL stringByAppendingString:@"/upload"] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        callback([NSData data]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}


-(void)sendData:(NSData *)data toRecipients:(NSArray *)recipients isVideo:(BOOL)video callback:(void (^)(void))callback {
    callback();
    int type = video ? 1 : 0;
    
    long ts = (long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000);
    NSString *req_token = [self hashFirst:_authToken second:[NSString stringWithFormat:@"%li", ts]];
    NSString *media_id = [[_username uppercaseString] stringByAppendingFormat:@"%li", ts/1000];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"timestamp"] = @(ts);
    params[@"req_token"] = req_token;
    params[@"username"] = _username;
    params[@"media_id"] = media_id;
    params[@"type"] = @(type);
    params[@"version"] = @"6.0.0";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[URL stringByAppendingString:@"/upload"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        long sts = (long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000);
        
        NSMutableDictionary *sData = [[NSMutableDictionary alloc] init];
        sData[@"media_id"] = media_id;
        sData[@"recipient"] = [recipients componentsJoinedByString:@","];
        sData[@"time"] = @(5);
        sData[@"timestamp"] = @(sts);
        sData[@"username"] = _username;
        sData[@"req_token"] = [self hashFirst:_authToken second:[NSString stringWithFormat:@"%li", sts]];
        sData[@"version"] = @"6.0.0";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[URL stringByAppendingString:@"/send"] parameters:sData success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
