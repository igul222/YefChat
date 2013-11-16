//
//  SnapchatClient.m
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import "SnapchatClient.h"
#import "Snap.h"

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
        _friends = @[@"igul222", @"yefim", @"spoonpics", @"yefchat"];
    }
    return self;
}

-(NSString*) sha256:(NSString *)clear{
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];

    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, keyData.length, digest);
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

    for (int i = 0; PATTERN.length; i++) {
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

    double ts = ([[[NSDate alloc] init] timeIntervalSince1970] * 1000);

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:username forKey:@"username"];
    [data setObject:password forKey:@"password"];
    [data setObject:[NSNumber numberWithDouble:ts] forKey:@"timestamp"];
    [data setObject:[self hashFirst:STATIC_TOKEN second:[NSString stringWithFormat:@"%f", ts]] forKey:@"req_token"];
    [data setObject:@"6.0.0" forKey:@"version"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[URL stringByAppendingString:@"/login"] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"JSON: %@", responseObject);

          _authToken = @"";

          callback();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);
    }];
}

-(void)startRefreshWithCallback:(void (^)(void))callback {
    Snap *snap = [[Snap alloc] init];
    snap.sender = @"John Appleseed";
    snap.timestamp = [[NSDate alloc] init];

    double ts = ([[[NSDate alloc] init] timeIntervalSince1970] * 1000);

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithDouble:ts] forKey:@"timestamp"];
    [data setObject:[self hashFirst:_authToken second:[NSString stringWithFormat:@"%f", ts]] forKey:@"req_token"];
    [data setObject:@"6.0.0" forKey@"version"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[URL stringByAppendingString:@"/all_updates"] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"JSON: %@", responseObject);

          NSArray *snapJsons = responseObject[@"updates_response"][@"snaps"];
          for (int i = 0; i < snapJsons.length; i++) {
              NSDictionary *snapJson = snapJsons[i];

              Snap *snap = [[Snap alloc] init];
              snap.sender = snapJson[@"rp"];
              // snap.timestamp = 
              snap.mediaId = snapJson[@"c_id"];

              // add to dict

          }

          callback();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);
    }];

    _snaps = [_snaps arrayByAddingObject:snap];
}

-(void)sendData:(NSData *)data toRecipients:(NSArray *)recipients isVideo:(BOOL)video callback:(void (^)(void))callback {
    callback();
}

@end
