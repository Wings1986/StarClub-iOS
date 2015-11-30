//
//  ParentTableViewController.h
//  StarClub
//

//#import "EGORefreshTableHeaderView.h"
#import "SVPullToRefresh.h"


#import "UIImage+JSMessagesView.h"

#import "NSDate+TimeAgo.h"
#import "DLImageLoader.h"

#import "GADBannerView.h"
#import "DFPSwipeableBannerView.h"


#import "PublishFeedController.h"


#define HEADER_HEIGHT   32.0f


#define BTN_USER_ID     1000
#define BTN_LIKE_ID     5000
#define BTN_PHOTO_ID    10000
#define BTN_LOCK_ID     15000
#define BTN_COMMENT_ID  20000
#define BTN_FACEBOOK_ID  25000
#define BTN_TWITTER_ID  30000
#define BTN_HEADER_ID   35000
#define BTN_MSG_USER_ID   45000
#define BTN_START_ID    50000
#define BANNER_ID       60000
#define BAR_ID          65000
#define BTN_ADD_COMMENT_ID  70000
#define BTN_MORE_ID     80000
#define BTN_LIKE_LIST_ID    90000

#define BTN_DETAIL_ID   1000


@interface ParentTableViewController : RootViewController
{
    NSDictionary * m_feedLock;
    int            m_nSelLock;
    int            m_numWant;

    int m_nPage;
    
    BOOL    m_bMoreLoad;
}


@property (nonatomic, strong) IBOutlet UITableView * mTableView;


@property (nonatomic, assign) FEED_TYPE mFeedType;

@property (nonatomic, assign) int m_nNumOfSection;
@property (nonatomic, assign) int m_nNumOfHeader;


@property (nonatomic, strong) NSMutableArray * arrAllTableList;
@property (nonatomic, strong) NSMutableArray * arrTableList;
@property (nonatomic, strong) NSMutableDictionary * starInfo;


- (void)startRefresh;
- (void)startMoreLoad;
- (void) doneLoadingTableViewData;

//- (void)doneLoadingTableViewData;
//- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;



- (void) filterFeed;


-(void) onLikeButton:(UIButton*) sender;
-(void) onLikeList:(UITapGestureRecognizer*) gesture;

-(void) onComment:(UIButton *)btn;
-(void) onAddComment:(UIButton *)btn;

-(void) onPhotoLock:(UITapGestureRecognizer*) gesture;

-(void) gotoPhotoDetail:(NSDictionary *) dic;

-(void) onVideoDetail:(UITapGestureRecognizer*) recognize;

-(void) gotoFanDetail:(NSString*) userID;


@end
