//
//  Global.m
//  LocationWeather
//
//  Created by Yuan Luo on 4/24/13.
//  Copyright (c) 2013 Sun Zhe. All rights reserved.
//

#import "Global.h"

static Global* instance = nil;


@implementation Global

+(Global*) Instance
{
    if (instance == nil) {
        instance = [[Global alloc] init];
    }
    
    return instance;
}
-(void) initVal
{
    self.g_arrShopItem = [[NSMutableArray alloc] init];
}

+(int) getUserType
{
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * type = [userInfo objectForKey:@"admin_type"];
    if (type == nil || (NSString *)[NSNull null] == type || [type isEqualToString:@""] ) {
        return FAN;
    }
    else {
        return [type intValue];
    }
}


+ (BOOL) isIPhone5
{
    if ((![UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 548 )|| ([UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 568))
        return YES;
    
    return NO;
}

@end
