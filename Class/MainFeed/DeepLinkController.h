//
//  DeepLinkController.h
//  StarClub
//
//  Created by SilverStar on 5/23/14.
//
//

@interface DeepLinkController : ParentTableViewController

-(id) initWithDatas:(NSString*) postType contentId:(NSString*)contentID withRevealBlock:(RevealBlock)revealBlock;

@end
