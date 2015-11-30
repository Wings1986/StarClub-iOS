//
//  GHMenuViewController.m


#import "GHMenuViewController.h"
#import "GHMenuCell.h"
#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "GHAppDelegate.h"
#import "Global.h"

/*  Controllers   */
#import "AllAccessController.h"
#import "PhotosController.h"
#import "PhotoGridController.h"
#import "VideosController.h"
#import "PollsContestsController.h"
#import "ShopController.h"

#import "ProfileController.h"
#import "CommunityController.h"
#import "InboxController.h"
#import "RankingController.h"
#import "SettingController.h"
#import "HelpController.h"

#import "DraftReviewController.h"

#import "BaseNavController.h"


#pragma mark -
#pragma mark Implementation
@implementation GHMenuViewController {
	GHRevealViewController *_sidebarVC;
	UISearchBar *_searchBar;
	NSMutableArray *_headers;
  	NSArray *_headerImages;
	NSArray *_controllers;
	NSArray *_cellInfos;
}

@synthesize m_selIndex, _menuTableView;


#pragma mark Memory Management
- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC 
					  withSearchBar:(UISearchBar *)searchBar 
						withHeaders:(NSArray *)headers
						withHeaderImages:(NSArray *)headerImages
					withControllers:(NSArray *)controllers
					  withCellInfos:(NSArray *)cellInfos {
	if (self = [super initWithNibName:nil bundle:nil]) {
		_sidebarVC = sidebarVC;
        
        if ([Global getUserType] == FAN) {
            _searchBar = searchBar;
        } else {
            _searchBar = nil;
        }
        
		_headers = [NSMutableArray arrayWithArray:headers];
        _headerImages = headerImages;
		
        _controllers = controllers;
		_cellInfos = cellInfos;
		
		_sidebarVC.sidebarViewController = self;
        
        if (_controllers != nil) {
            _sidebarVC.contentViewController = _controllers[0][0];
        } else {
            _sidebarVC.contentViewController = [self getViewController:0 :0];
        }
        
        m_selIndex = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	return self;
}


- (void) setHeaderName:(NSString*) name
{
    if (name == nil) {
        return;
    }
    
    [_headers replaceObjectAtIndex:0 withObject:name];
    
    [_menuTableView reloadData];
}

#pragma mark UIViewController
- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	self.view.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    if (_searchBar != nil) {
        _searchBar.frame = CGRectMake(0.0f, 20.0f, _searchBar.frame.size.width, _searchBar.frame.size.height);
        [self.view addSubview:_searchBar];
    }

	_menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 20+44.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds) - 64.0f)
												  style:UITableViewStylePlain];
    
    if ([Global getUserType] != FAN) {
        _menuTableView.frame = CGRectMake(0.0f, 20.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds) - 20.0f);
    }
    
	_menuTableView.delegate = self;
	_menuTableView.dataSource = self;
	_menuTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_menuTableView.backgroundColor = [UIColor clearColor];
	_menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_menuTableView];
	[self selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.view.frame = CGRectMake(0.0f, 0.0f,kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
    
    if (_searchBar != nil) {
        [_searchBar sizeToFit];
    }

}

- (void)viewDidLayoutSubviews {
//    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
//        CGRect viewBounds = self.view.frame;
//        CGFloat topBarOffset = self.topLayoutGuide.length;
//        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset,
//                                      viewBounds.size.width, viewBounds.size.height);
//    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_cellInfos[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHMenuCell";
    GHMenuCell *cell = (GHMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = _cellInfos[indexPath.section][indexPath.row];
	cell.textLabel.text = info[kSidebarCellTextKey];
//	cell.imageView.image = info[kSidebarCellImageKey];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (_headers[section] == [NSNull null]) ? 0.0f : 27.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = _headers[section];
	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 27.0f)];
        headerView.backgroundColor = [UIColor colorWithRed:(248.0f/255.0f) green:(248.0f/255.0f) blue:(248.0f/255.0f) alpha:1.0f];
        
        
//		CAGradientLayer *gradient = [CAGradientLayer layer];
//		gradient.frame = headerView.bounds;
//		gradient.colors = @[
//            (id)[UIColor colorWithRed:(200.0f/255.0f) green:(200.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0f].CGColor,
//			(id)[UIColor colorWithRed:(240.0f/255.0f) green:(240.0f/255.0f) blue:(240.0f/255.0f) alpha:1.0f].CGColor,
//		];
//		[headerView.layer insertSublayer:gradient atIndex:0];

		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 3.0f, 21.0f, 21.0f)];
        [imageView setImage:[UIImage imageNamed:_headerImages[section]]];
        [headerView addSubview:imageView];
        
        
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 50.0f, 5.0f)];
		textLabel.text = (NSString *) headerText;
		textLabel.font = [UIFont fontWithName:FONT_NAME size:([UIFont systemFontSize] * 1.0f)];
//		textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
//		textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		textLabel.textColor = [UIColor blackColor]; //[UIColor colorWithRed:(125.0f/255.0f) green:(129.0f/255.0f) blue:(146.0f/255.0f) alpha:1.0f];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(204.0f/255.0f) green:(204.0f/255.0f) blue:(204.0f/255.0f) alpha:1.0f];
		[headerView addSubview:topLine];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 27.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(204.0f/255.0f) green:(204.0f/255.0f) blue:(204.0f/255.0f) alpha:1.0f];
		[headerView addSubview:bottomLine];
	}
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    BOOL bIsDraft  = [[userInfo objectForKey:@"is_draft"] boolValue];
    
    if (indexPath.section == 0
        && ((indexPath.row == 7 && !bIsDraft) || ((indexPath.row == 8 && bIsDraft)))) {
        GHAppDelegate * appDelegate = APPDELEGATE;
        [appDelegate openMediaPlayer];
    }
//    else if (indexPath.section == 1 && indexPath.row == 0 && [Global getUserType] != FAN) {
//        GHAppDelegate * appDelegate = APPDELEGATE;
//
//        [appDelegate signOut];
//        [appDelegate gotoLogInFrame];
//    }
    else {
        if (_controllers != nil) {
            _sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
        } else {
            if (m_selIndex && [m_selIndex compare:indexPath] != NSOrderedSame){
                _sidebarVC.contentViewController = [self getViewController:indexPath.section :indexPath.row];
                m_selIndex = indexPath;
            }
        }
        
        [_sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
    }
}

#pragma mark Public Methods
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    
	[_menuTableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    
	if (scrollPosition == UITableViewScrollPositionNone) {
		[_menuTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
	}
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    BOOL bIsDraft  = [[userInfo objectForKey:@"is_draft"] boolValue];

    if (indexPath.section == 0
        && ((indexPath.row == 7 && !bIsDraft) || ((indexPath.row == 8 && bIsDraft)))) {
        GHAppDelegate * appDelegate = APPDELEGATE;
        [appDelegate openMediaPlayer];
    }
    else {
        if (_controllers != nil) {
            _sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
        }
        else {
            if (m_selIndex && [m_selIndex compare:indexPath] != NSOrderedSame){
                _sidebarVC.contentViewController = [self getViewController:indexPath.section :indexPath.row];
                m_selIndex = indexPath;
            }
        }
    }
}

-(UINavigationController*) getViewController:(int) section : (int) row
{
    GHAppDelegate * appDelegate = APPDELEGATE;
    
 	RevealBlock revealBlock = ^(){
		[appDelegate.revealController toggleSidebar:!appDelegate.revealController.sidebarShowing
									duration:kGHRevealSidebarDefaultAnimationDuration];
	};

    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * userName = [userInfo objectForKey:@"name"];
    BOOL bIsDraft  = [[userInfo objectForKey:@"is_draft"] boolValue];

    
    if (section == 0) {
        if (bIsDraft) {
            switch (row) {
                case 0:
                    return [[BaseNavController alloc] initWithRootViewController:[[AllAccessController alloc] initWithTitle:MENU_MAIN_FEED withRevealBlock:revealBlock]];
                    
                    break;
                    
                case 1:
                    return [[BaseNavController alloc] initWithRootViewController:[[DraftReviewController alloc] initWithTitle:MENU_DRAFT withRevealBlock:revealBlock]];
                    break;
                    
                case 2:
                    return [[BaseNavController alloc] initWithRootViewController:[[CommunityController alloc] initWithTitle:MENU_COMMUNITY withRevealBlock:revealBlock]];
                    break;
                    
                case 3:
                    //                    return [[BaseNavController alloc] initWithRootViewController:[[PhotosController alloc] initWithTitle:@"Photos" withRevealBlock:revealBlock]];
                    return [[BaseNavController alloc] initWithRootViewController:[[PhotoGridController alloc] initWithTitle:@"Photos" withRevealBlock:revealBlock]];
                    
                    break;
                    
                case 4:
                    return [[BaseNavController alloc] initWithRootViewController:[[VideosController alloc] initWithTitle:@"Videos" withRevealBlock:revealBlock]];
                    break;
                    
                case 5:
                    return [[BaseNavController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:MENU_TOUR withRevealBlock:revealBlock]];
                    break;
                    
                case 6:
                    return [[BaseNavController alloc] initWithRootViewController:[[PollsContestsController alloc] initWithTitle:MENU_QUIZ  withRevealBlock:revealBlock]];
                    break;
                    
                case 7:
                    return [[BaseNavController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Shop" withRevealBlock:revealBlock]];
                    break;
            }
        }
        else {
            switch (row) {
                case 0:
                    return [[BaseNavController alloc] initWithRootViewController:[[AllAccessController alloc] initWithTitle:MENU_MAIN_FEED withRevealBlock:revealBlock]];
                    
                    break;
                    
                    
                case 1:
                    return [[BaseNavController alloc] initWithRootViewController:[[CommunityController alloc] initWithTitle:MENU_COMMUNITY withRevealBlock:revealBlock]];
                    break;
                    
                case 2:
                    //                    return [[BaseNavController alloc] initWithRootViewController:[[PhotosController alloc] initWithTitle:@"Photos" withRevealBlock:revealBlock]];
                    return [[BaseNavController alloc] initWithRootViewController:[[PhotoGridController alloc] initWithTitle:@"Photos" withRevealBlock:revealBlock]];
                    
                    break;
                    
                case 3:
                    return [[BaseNavController alloc] initWithRootViewController:[[VideosController alloc] initWithTitle:@"Videos" withRevealBlock:revealBlock]];
                    break;
                    
                case 4:
                    return [[BaseNavController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:MENU_TOUR withRevealBlock:revealBlock]];
                    break;
                    
                case 5:
                    return [[BaseNavController alloc] initWithRootViewController:[[PollsContestsController alloc] initWithTitle:MENU_QUIZ withRevealBlock:revealBlock]];
                    break;
                    
                case 6:
                    return [[BaseNavController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Shop" withRevealBlock:revealBlock]];
                    break;
            }
        }
    }
    else {
        if ([Global getUserType] == FAN) {
            switch (row) {
                case 0:
                    return [[BaseNavController alloc] initWithRootViewController:[[ProfileController alloc] initWithTitle:userName withRevealBlock:revealBlock]];
                    break;
                    
                case 1:
                    return [[BaseNavController alloc] initWithRootViewController:[[InboxController alloc] initWithTitle:@"Inbox" withRevealBlock:revealBlock]];
                    break;
                    
                case 2:
                    return [[BaseNavController alloc] initWithRootViewController:[[RankingController alloc] initWithTitle:@"Ranking" withRevealBlock:revealBlock]];
                    break;
                    
                case 3:
                    return [[BaseNavController alloc] initWithRootViewController:[[SettingController alloc] initWithTitle:@"Settings" withRevealBlock:revealBlock]];
                    break;
                    
                case 4:
                    return [[BaseNavController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Help" withRevealBlock:revealBlock]];
                    
            }
        
        }
        else { // admin
            switch (row) {
                case 0:
                    return [[BaseNavController alloc] initWithRootViewController:[[SettingController alloc] initWithTitle:@"Settings" withRevealBlock:revealBlock]];
                    
                case 1:
                    return [[BaseNavController alloc] initWithRootViewController:[[HelpController alloc] initWithTitle:@"Help" withRevealBlock:revealBlock]];
                    
            }
        }
    }
    
    return nil;
    
}

@end
