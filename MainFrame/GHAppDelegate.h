//
//  GHAppDelegate.h

/*  Interface     */
#import "GHMenuCell.h"
#import "MainMenuCell.h"
#import "GHMenuViewController.h"
#import "GHRevealViewController.h"
#import "GHSidebarSearchViewController.h"
#import "GHSidebarSearchViewControllerDelegate.h"


@interface GHAppDelegate : UIResponder <UIApplicationDelegate>
{
}


@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHSidebarSearchViewController *searchController;
@property (nonatomic, strong) GHMenuViewController *menuController;



@property (nonatomic, assign) BOOL fullScreenVideoIsPlaying;
@property (nonatomic, strong)     MyPlayerView * m_playView;
@property (nonatomic, assign) BOOL BCOVVideoIsPlaying;

- (void) changeHeaderName:(NSString*) name;

- (void) signOut;
-(void) logoutFB;

-(void) gotoLogInFrame;
-(void) gotoMainFrame;


- (void) didSelectedIndexView;
- (void) didSelectedSettingView;
- (void) openMediaPlayer;

-(void) orientationMediaPlayer:(BOOL) bLandscape;



@end
