//
//  PhotoListController.h
//

#import <UIKit/UIKit.h>


@protocol PhotoListControllerDelegate

-(void) setBackImageArray:(NSArray*) arrBackImages page:(int) page;

@end



@interface PhotoListController : ParentTableViewController


@property (nonatomic, strong) id<PhotoListControllerDelegate> delegate;


- (id) initWithIndexAndDatas:(int) index : (NSArray*) datas;
- (id) initWithIndexAndDatas:(int) index : (NSArray*) datas :(int) page enableAds:(BOOL) enableAds;

@end
