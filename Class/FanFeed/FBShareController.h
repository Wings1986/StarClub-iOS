//
//  FBShareController.h
//  StarClub
//
//  Created by SilverStar on 5/23/14.
//
//

#import "BaseViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FBShareController : BaseViewController

+ (void) sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
+ (void)displayFBerrorMsg:(NSError *) error msgTitle:(NSString *) title;
@end
