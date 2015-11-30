//
//  RootViewController.h
//  StarClub
//

#import "BaseViewController.h"

typedef void (^RevealBlock)();

@interface RootViewController : BaseViewController
{
    	RevealBlock _revealBlock;
    
    int    m_bEnableBanner;
    NSString *m_channel_BrightcoveId;
    NSString *m_channelUrl;
}

- (void)revealSidebar;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;

//- (void) onBack;
//- (void) onPush:(UIViewController*) pController;


@end
