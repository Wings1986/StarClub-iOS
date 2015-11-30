//
//  GHSidebarSearchViewController.h

#import "GHSidebarSearchViewControllerDelegate.h"
@class GHRevealViewController;


extern const NSTimeInterval kGHSidebarDefaultSearchDelay;

@interface GHSidebarSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>


@property (nonatomic, strong) UIView *_searchBarSuperview;
@property (nonatomic, assign) NSUInteger _searchBarSuperIndex;


@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) NSArray *entries;
@property (weak, nonatomic) id<GHSidebarSearchViewControllerDelegate> searchDelegate;
@property (nonatomic) NSTimeInterval searchDelay;

- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC;

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller;

@end
