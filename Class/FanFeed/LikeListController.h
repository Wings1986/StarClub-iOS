//
//  LikeListController.h
//  StarClub
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface LikeListController : ParentTableViewController

-(id) initWithFeed:(NSDictionary*) feed;
-(id) initWithFeedForDraft:(NSDictionary*) feed;

@end
