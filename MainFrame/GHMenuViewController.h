//
//  GHMenuViewController.h

@class GHRevealViewController;


@interface GHMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) 	UITableView *_menuTableView;
@property(nonatomic, strong) NSIndexPath *m_selIndex;

- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC
					  withSearchBar:(UISearchBar *)searchBar
						withHeaders:(NSArray *)headers
                   withHeaderImages:(NSArray *)headerImages
					withControllers:(NSArray *)controllers
					  withCellInfos:(NSArray *)cellInfos;

    
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath 
					animated:(BOOL)animated 
			  scrollPosition:(UITableViewScrollPosition)scrollPosition;

- (void) setHeaderName:(NSString*) name;

@end
