//
//  GHAppDelegate.m
//

#import "GHAppDelegate.h"



/*  Controllers   */
#import "AllAccessController.h"
#import "PhotosController.h"
#import "VideosController.h"
#import "PollsContestsController.h"
#import "ShopController.h"

#import "ProfileController.h"
#import "CommunityController.h"
#import "InboxController.h"
#import "RankingController.h"
#import "SettingController.h"
#import "HelpController.h"

#import "LoginController.h"
#import "MyPlayerView.h"

#import "BaseNavController.h"
#import "FanDetailController.h"

#import "DeepLinkController.h"

#import <FacebookSDK/FacebookSDK.h>
#import "StarTracker.h"
#import "FBShareController.h"


static NSString *const kGaPropertyId = @"UA-46624794-3";

#pragma mark Private Interface
@interface GHAppDelegate () <GHSidebarSearchViewControllerDelegate>
{
    NSArray         * arrAllUsers;
    NSMutableArray  * arrSearchedUsers;
    
    NSMutableDictionary * m_info;
    
    
    NSString * m_strSearch;
}


@property (nonatomic, strong) BaseNavController * navController;
@property (nonatomic, strong) UIViewController * viewController;

@end

#pragma mark Implementation
@implementation GHAppDelegate

#pragma mark Properties
@synthesize window = _window;

#pragma mark UIApplicationDelegate



- (void)applicationWillTerminate:(UIApplication *)application
{
    
    [FBSession.activeSession close];
    
    [StarTracker StarRunStatus : DID_TERMINATE : @"Run Status" : @"Terminated" : @"State Change"];
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

 //   [FBSession.activeSession handleDidBecomeActive];
    
    [StarTracker StarRunStatus : IS_ACTIVE : @"Run Status" : @"Active" : @"State Change"];
    
    if(self.window.rootViewController){
        UIViewController *presentedViewController ;
        if ([self.window.rootViewController isKindOfClass:([UINavigationController class])])
        {
            presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        }
        else
        {
            presentedViewController = self.window.rootViewController;
        }
        
        if ([presentedViewController isKindOfClass:[LoginController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginViewController" object:nil userInfo:nil];
        }
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [StarTracker StarRunStatus : IS_BACKGROUND : @"Run Status" : @"Background" : @"State Change"];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:STATUS_BAR_STYLE];

    [[UINavigationBar appearance] setBarTintColor:UINAVIGATION_BAR_COLOR_BARTINT];
    [[UINavigationBar appearance] setTintColor:UINAVIGATION_BAR_COLOR_TINT];
    self.navController.navigationBar.barTintColor = NAVIGATION_BAR_COLOR_BARTINT;
    self.navController.navigationBar.tintColor = NAVIGATION_BAR_COLOR_TINT;
    self.navController.navigationBar.translucent = NAVIGATION_BAR_TRANSLUCENT;
    

   // StarClub Tracker Init
    
    [StarTracker StarRunStatus : DID_LAUNCH : @"App Status" : @"StarStats Init" : @"State Change"];
 
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                        [FBShareController sessionStateChanged:session state:state error:error];
                                      }];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    
    [GLOBAL initVal];
    
    
    if (![self isSignIn]) {
        [self gotoLogInFrame];
    }
    else {
        [self gotoMainFrame];
    }
    

    
    [self.window makeKeyAndVisible];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    return YES;
}

-(BOOL) isSignIn
{
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    
    if (userInfo == nil) {
        return NO;
    }
    [StarTracker StarRunStatus : DID_SIGNIN : @"Run Status" : @"Sign-In" : @"State Change"];
        
    return YES;
    
}
-(void) signOut
{
    
    [StarTracker StarRunStatus : DID_SIGNOUT : @"Run Status" : @"Sign Out" : @"State Change"];

    NSLog(@"sign out");

    
  //  if ([FBSession.activeSession isOpen]) {
//
//        [FBSession.activeSession closeAndClearTokenInformation];
 //       [FBSession.activeSession close];
 //       [FBSession setActiveSession:nil];
 //   }
    
 //   [self logoutFB];
    
 //       [[FBSession activeSession] close];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void) logoutFB
{
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession setActiveSession:nil];
    
    FBSession *session=[FBSession activeSession];
    [session closeAndClearTokenInformation];
    [session close];

    
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:@"http://login.facebook.com"]];
    for (NSHTTPCookie* cookie in facebookCookies)
    {
        [cookies deleteCookie:cookie];
    }
    
    for (NSHTTPCookie *_cookie in cookies.cookies)
    {
        NSRange domainRange = [[_cookie domain] rangeOfString:@"facebook"];
        if(domainRange.length > 0){
            [cookies deleteCookie:_cookie];
        }
    }
}
-(void) gotoLogInFrame
{
    self.viewController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
    self.navController = [[BaseNavController alloc] initWithRootViewController:self.viewController];
    self.navController.navigationBarHidden = YES;
    self.window.rootViewController = self.navController;
}

-(void) gotoMainFrame
{
    
    UIColor *bgColor = MAIN_FRAME_COLOR_BACKGROUND;

	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
	
//	RevealBlock revealBlock = ^(){
//		[self.revealController toggleSidebar:!self.revealController.sidebarShowing
//									duration:kGHRevealSidebarDefaultAnimationDuration];
//	};
	
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * userName = [userInfo objectForKey:@"name"];
    
    NSArray *headers = [NSArray arrayWithObjects:@"",
                        [userName uppercaseString],
                        nil];
    
    NSArray *headers_image = nil;
    headers_image = @[
                               @"menu_logo",
                               @"menu_avatar"
                               ];
    
    
	NSArray *controllers = nil;
	NSArray *cellInfos = nil;
    

    BOOL bIsDraft  = [[userInfo objectForKey:@"is_draft"] boolValue];

    if ([Global getUserType] == FAN) {
/*
        controllers = @[
                        @[
                            [[UINavigationController alloc] initWithRootViewController:[[AllAccessController alloc] initWithTitle:MENU_MAIN_FEED withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[PhotosController alloc] initWithTitle:@"Photos" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[VideosController alloc] initWithTitle:@"Videos" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[TourDatesController alloc] initWithTitle:MENU_TOUR withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[EiLiveController alloc] initWithTitle:@"ei Live" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[PollsContestsController alloc] initWithTitle:MENU_QUIZ withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Shop" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]],
                            ],
                        @[
                            [[UINavigationController alloc] initWithRootViewController:[[ProfileController alloc] initWithTitle:userName withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[CommunityController alloc] initWithTitle:MENU_COMMUNITY withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[InboxController alloc] initWithTitle:@"Inbox" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[RankingController alloc] initWithTitle:@"Ranking" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[SettingController alloc] initWithTitle:@"Settings" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Help" withRevealBlock:revealBlock]]
                            ]
                        ];
*/
        if (!bIsDraft) {
            cellInfos = @[
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MAIN_FEED, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_COMMUNITY, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Photos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Videos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_TOUR, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_QUIZ, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Shop", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MUSIC, @"")},
                              ],
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Inbox", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Ranking", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Settings", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Help", @"")},
                              ]
                          ];
        }
        else {
            cellInfos = @[
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MAIN_FEED, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_DRAFT, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_COMMUNITY, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Photos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Videos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_TOUR, @"")},
                              //                          @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"ei Live", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_QUIZ, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Shop", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MUSIC, @"")},
                              ],
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Inbox", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Ranking", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Settings", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Help", @"")},
                              ]
                          ];

        }
            }
    else {
/*
        // Admin
        controllers = @[
                        @[
                            [[UINavigationController alloc] initWithRootViewController:[[AllAccessController alloc] initWithTitle:MENU_MAIN_FEED withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[PhotosController alloc] initWithTitle:@"Photos" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[VideosController alloc] initWithTitle:@"Videos" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[TourDatesController alloc] initWithTitle:MENU_TOUR withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[EiLiveController alloc] initWithTitle:@"ei Live" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[PollsContestsController alloc] initWithTitle:MENU_QUIZ withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Shop" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]],
                            ],
                        @[
                            [[UINavigationController alloc] initWithRootViewController:[[CommunityController alloc] initWithTitle:MENU_COMMUNITY withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[RankingController alloc] initWithTitle:@"Ranking" withRevealBlock:revealBlock]],
                            [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]],
                            [[UINavigationController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Help" withRevealBlock:revealBlock]]
                            ]
                        ];
*/
        if (!bIsDraft) {
            cellInfos = @[
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MAIN_FEED, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_COMMUNITY, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Photos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Videos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_TOUR, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_QUIZ, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Shop", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MUSIC, @"")},
                              ],
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Settings", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Help", @"")},
                              ]
                          ];
        } else {
            cellInfos = @[
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MAIN_FEED, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_DRAFT, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_COMMUNITY, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Photos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Videos", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_TOUR, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_QUIZ, @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Shop", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(MENU_MUSIC, @"")},
                              ],
                          @[
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Settings", @"")},
                              @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Help", @"")},
                              ]
                          ];

        }
        
    }

	
    
    
	// Add drag feature to each root navigation controller
	[controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		[((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
//			UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
//																						 action:@selector(dragContentView:)];
//			panGesture.cancelsTouchesInView = YES;
//			[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
            
//            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
//																						 action:@selector(handlePan:)];
//			[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
		}];
	}];
	
	self.searchController = [[GHSidebarSearchViewController alloc] initWithSidebarViewController:self.revealController];
	self.searchController.view.backgroundColor = SIDE_SEARCH_COLOR_BACKGROUND_VIEW;
    self.searchController.searchDelegate = self;
	self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchController.searchBar.backgroundColor = SIDE_SEARCH_COLOR_BACKGROUND;
	self.searchController.searchBar.placeholder = NSLocalizedString(@"Search for friends...", @"");
	for (UIView *subview in self.searchController.searchBar.subviews) {
		if ([subview isKindOfClass:[UITextField class]]) {
			UITextField *searchTextField = (UITextField *) subview;
            searchTextField.textColor = SIDE_SEARCH_COLOR_TEXT;
		}
	}
	
	self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController 
																		withSearchBar:self.searchController.searchBar 
																		  withHeaders:headers
                                                                     withHeaderImages:headers_image
																	  withControllers:controllers 
																		withCellInfos:cellInfos];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    self.m_playView = [[MyPlayerView alloc] initWithFrame:CGRectMake(0, screenHeight-TOOLBAR_HEIGHT, 320, 400)];
    [self.revealController.view addSubview:self.m_playView];
    
    self.window.rootViewController = self.revealController;
}

- (void) changeHeaderName:(NSString*) name
{
    [self.menuController setHeaderName:[name uppercaseString]];
}

- (void) didSelectedIndexView
{
    [self.menuController selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionTop];

}
- (void) didSelectedSettingView
{
    [self.menuController selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionTop];
    
}
- (void) openMediaPlayer
{
  
    [self.m_playView onClose];
}

-(void) orientationMediaPlayer:(BOOL) bLandscape
{
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenHeight;
//    CGFloat screenWidth;
//
//    if (bLandscape) {
//        screenWidth = screenRect.size.height;
//        screenHeight = screenRect.size.width;
//    }
//    else {
//        screenWidth = screenRect.size.width;
//        screenHeight = screenRect.size.height;
//    }
//    self.m_playView.frame = CGRectMake(0, screenHeight-TOOLBAR_HEIGHT, screenWidth, 400);

    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    self.m_playView.frame = CGRectMake(0, screenBounds.size.height-TOOLBAR_HEIGHT, screenBounds.size.width, 400);
    
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
    if (self.fullScreenVideoIsPlaying == YES) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        if(self.window.rootViewController){
            UIViewController *presentedViewController ;
            if ([self.window.rootViewController isKindOfClass:([UINavigationController class])])
            {
                presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
            }
            else if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]){
                UITabBarController *controller = (UITabBarController*)self.window.rootViewController;
                
                id selectedController =  [controller presentedViewController];
                
                if (!selectedController) {
                    selectedController = [controller selectedViewController];
                }
                
                if ([selectedController isKindOfClass:([UINavigationController class])])
                {
                    presentedViewController = [[(UINavigationController *)selectedController viewControllers] lastObject];
                }
                else{
                    presentedViewController = selectedController;
                }
            }
            else
            {
                presentedViewController = self.window.rootViewController;
            }

            if ([presentedViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
                
                orientations = [presentedViewController supportedInterfaceOrientations];
            }
        }
    }
    
    return orientations;
}


#pragma mark Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	// Convert the token to a hex string and make sure it's all caps
	NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
	[tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
	[tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
	[tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
	
    
    NSLog(@"%@", tokenString);
    
    //store the devicetoken for registering to coursemob
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tokenString forKey:@"deviceToken"];
    [defaults synchronize];
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    m_info = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    
    NSLog(@"push = %@", m_info);
    
    NSString * message = [[m_info objectForKey:@"aps"] objectForKey:@"alert"];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
													message:message
                                                   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Show", nil];
    alert.tag = 999;
	[alert show];
	
	application.applicationIconBadgeNumber = 0;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        if (buttonIndex == 1) { //show
            NSString * push_type = [m_info objectForKey:@"push_type"];
            NSArray * feeds = [m_info objectForKey:@"feeds"];

            NSString * postType = nil, *contentId = nil;

            if ([push_type isEqualToString:@"main_feed"]) {

//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_SHOW_MAINFEED object:nil userInfo:nil];
//                
//                [self.menuController selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                if (feeds == nil) {
                    return;
                } else {
                    int count = (int) feeds.count;
                    NSDictionary * feed = [feeds objectAtIndex:count-1];
                    
                    postType = [feed objectForKey:@"post_type"];
                    contentId = [feed objectForKey:@"content_id"];
                }
                
                if (postType == nil || (NSString *)[NSNull null] == postType
                    || contentId == nil || (NSString *)[NSNull null] == contentId) {
                    return;
                }
                
                RevealBlock revealBlock = ^(){
                    [self.revealController toggleSidebar:YES
                                                duration:kGHRevealSidebarDefaultAnimationDuration];
                };
                
                DeepLinkController * pController = [[DeepLinkController alloc] initWithDatas:postType contentId:contentId withRevealBlock:revealBlock];
                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pController];
                
                self.revealController.contentViewController = nav;
                [self.revealController toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
                
                return;
            }
        }
    }
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}


#pragma mark -
#pragma Facebook Url
/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    BOOL wasHandled = [FBAppCall handleOpenURL:url
                             sourceApplication:sourceApplication
                               fallbackHandler:^(FBAppCall *call) {
                                   NSURL *targetUrl = [[call appLinkData] targetURL];
                                   NSString * urlString = [targetUrl absoluteString];
                                   
                                   NSLog(@"path = %@", urlString);
                                   
                                   NSArray * arry = [urlString componentsSeparatedByString:@"/"];
                                   if (arry.count > 6) {
                                       
                                       NSString *channelId = nil, * postType = nil, *contentId = nil;
                                       channelId = arry[3];
                                       postType = arry[5];
                                       contentId = arry[6];
                                       
                                       RevealBlock revealBlock = ^(){
                                           [self.revealController toggleSidebar:YES
                                                                       duration:kGHRevealSidebarDefaultAnimationDuration];
                                       };
                                       
                                       DeepLinkController * pController = [[DeepLinkController alloc] initWithDatas:postType contentId:contentId withRevealBlock:revealBlock];
                                       UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pController];
                                       
                                       self.revealController.contentViewController = nav;
                                       [self.revealController toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
                                       
                                       self.menuController.m_selIndex = [NSIndexPath indexPathForRow:-1 inSection:0];
                                       [self.menuController._menuTableView reloadData];
                                   }
                               }
                       ];
    
    if (wasHandled) {
        return wasHandled;
    }
    
    NSString* scheme = [url scheme];
    if ([scheme isEqualToString:DEEPLINK_APP_URL]) { // deeplink
        [self gotoDeepLink:url];
        return YES;
    }
    else { // facebook
        // attempt to extract a token from the url
        return [FBSession.activeSession handleOpenURL:url];
    }
    
    return NO;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}


#pragma mark -
#pragma SEARCH FRIEND


#pragma mark GHSidebarSearchViewControllerDelegate

-(void) getUserListServer
{
    NSString * resultString = [MyUrl getRanking];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:resultString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            arrAllUsers = [result objectForKey:@"rankings"];
        }
    }
}
- (void) loadDataForTable {
//    [NSThread detachNewThreadSelector: @selector(getUserListServer) toTarget:self withObject:nil];
}


- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback {
//    arrSearchedUsers = [[NSMutableArray alloc] init];
//    
//    for (NSDictionary *dic in arrAllUsers) {
//        NSString * userName = [[dic objectForKey:@"userName"] lowercaseString];
//        
//        if ([userName rangeOfString:[text lowercaseString]].location != NSNotFound) {
//            [arrSearchedUsers addObject:dic];
//        }
//    }
//
//    callback(arrSearchedUsers);

    m_strSearch = text;
    [NSThread detachNewThreadSelector: @selector(getSearchUserListServer:) toTarget:self withObject:callback];

}

-(void) getSearchUserListServer:(SearchResultsBlock) callback
{
    NSString * resultString = [MyUrl getUserSearch:m_strSearch];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:resultString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            arrSearchedUsers = [result objectForKey:@"rankings"];
            
            callback(arrSearchedUsers);
        }
    }
}


- (void)searchResult:(id)result selectedAtIndexPath:(NSIndexPath *)indexPath {
    self.searchController.searchBar.text = @"";
//    [self.searchController searchDisplayControllerWillEndSearch:self.searchController.searchDisplayController];
    [self.searchController.searchDisplayController setActive:NO animated:NO];

    NSString * userId = [result objectForKey:@"user_id"];
    
    RevealBlock revealBlock = ^(){
		[self.revealController toggleSidebar:YES
									duration:kGHRevealSidebarDefaultAnimationDuration];
	};
    
    FanDetailController * pController = [[FanDetailController alloc] initWithUserID:userId withRevealBlock:revealBlock];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pController];
    
//    [self.revealController hideSidebar];

    self.revealController.contentViewController = nav;
	[self.revealController toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];

}

- (UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	static NSString* identifier = @"MainMenuCell";
	MainMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"MainMenuCell" bundle:nil];
        cell =(MainMenuCell*) viewController.view;
    }
    
    NSString * fanAvatarUrl = [entry objectForKey:@"img_url"];
    [DLImageLoader loadImageFromURL:fanAvatarUrl
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:37.0];
                                  [cell.imgAvatar setImage:image];
                            }
                              else{
                                  [cell.imgAvatar setImage:[UIImage imageNamed:@"demo-avatar"]];
                              }
                          }];


	cell.lbUserName.text = [entry objectForKey:@"userName"];
	
	return cell;
}

#pragma mark
#pragma - Deep Link

-(void) gotoDeepLink:(NSURL*) url
{
    NSString * host = [url host];
    if (![host isEqualToString:[NSString stringWithFormat:@"%d", CID]]) {
        return;
    }
    
    NSArray * paths = [url pathComponents];
    
    NSLog(@"paths = %@", paths);
    
    NSString * postType = nil, *contentId = nil;
    if ([paths count] > 2) {
        postType = [paths objectAtIndex:1];
        contentId = [paths objectAtIndex:2];
    }
    else{
        return;
    }
    
    
    RevealBlock revealBlock = ^(){
        [self.revealController toggleSidebar:YES
                                    duration:kGHRevealSidebarDefaultAnimationDuration];
    };
    
    DeepLinkController * pController = [[DeepLinkController alloc] initWithDatas:postType contentId:contentId withRevealBlock:revealBlock];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pController];
    
    self.revealController.contentViewController = nav;
    [self.revealController toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
    
    self.menuController.m_selIndex = [NSIndexPath indexPathForRow:-1 inSection:0];
    [self.menuController._menuTableView reloadData];
}

@end
