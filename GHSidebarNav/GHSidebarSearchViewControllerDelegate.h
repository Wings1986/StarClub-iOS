//
//  GHSidebarSearchViewControllerDelegate.h



typedef void (^SearchResultsBlock)(NSArray *);

@protocol GHSidebarSearchViewControllerDelegate <NSObject>
@required
- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback;

- (void)searchResult:(id)result selectedAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

- (void) loadDataForTable;

@end
