//
//  FanDetailController.h
//  GHSidebarNav
//
//  Created by MAYA on 12/30/13.
//
//

#import <UIKit/UIKit.h>

@interface FanDetailController : ParentTableViewController

-(id) initWithUserID:(NSString *) userId;
-(id) initWithUserID:(NSString *) userId withRevealBlock:(RevealBlock)revealBlock;

@end
