//
//  PublishFeedController.h
//  StarClub
//
//  Created by SilverStar on 7/15/14.
//
//

#import "BasePostViewController.h"


@protocol PublishFeedDelegate

- (void) setPublished;

@end


@interface PublishFeedController : BasePostViewController

@property(nonatomic, strong) id<PublishFeedDelegate> delegate;

- (id) initWithFeed:(NSDictionary*) feed;
- (id) initWithShare:(NSDictionary*) feed;

@end
