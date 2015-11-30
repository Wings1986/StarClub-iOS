//
//  PhotoGridController.m
//  GHSidebarNav
//

#import "PhotoGridController.h"
#import "PhotoDetailController.h"
#import "DLImageLoader.h"

#import "RTFlyoutMenu.h"
#import "RTFlyoutItem.h"

#import "MJRefresh.h"

#import "PhotoListController.h"

#import "StarTracker.h"

#import "PhotoGridCell.h"


#define frameWidth  60
#define frameHeight 36
#define MAX_ITEM  4

NSString *const MJCollectionViewCellIdentifier = @"REUSE";


@interface PhotoGridController ()<UICollectionViewDataSource, UICollectionViewDelegate, /*RTFlyoutMenuDelegate, RTFlyoutMenuDataSource,*/ MJRefreshBaseViewDelegate, PhotoListControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView * viewToolBar;
    IBOutlet UIScrollView * scrollTitle;
    IBOutlet UICollectionView * scrollImage;
    
    IBOutlet UIButton * btnFilter;
    IBOutlet UIView  * viewFilter;
    IBOutlet UITableView * tvFilter;
    IBOutlet UIView * viewSubGesture;
    
    int lastScrolledOffset;
    int m_nSelectBtn;
    
    NSMutableArray * arrTitles;
    
    NSMutableArray * arrOrgImages;
    NSMutableArray * arrImages;
    
    int m_nPage;
    
    BOOL m_bShow;
}

@property (strong, nonatomic) RTFlyoutMenu *flyoutMenu;

@property (nonatomic) NSArray *mainItems;
@property (nonatomic) NSArray *subItems;

@property (nonatomic, assign) BOOL _loading;

@end

@implementation PhotoGridController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [StarTracker StarSendView:@"Photo Grid Gallery"];
    
    scrollTitle.pagingEnabled = YES;
	scrollTitle.showsHorizontalScrollIndicator = NO;
    
    scrollImage.alwaysBounceVertical = YES;
    [scrollImage registerNib:[UINib nibWithNibName:@"PhotoGridCell" bundle:nil] forCellWithReuseIdentifier:MJCollectionViewCellIdentifier];

    
    // 3.集成刷新控件
    // 3.1.下拉刷新
//    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
//    header.scrollView = scrollImage;
//    header.delegate = self;
//    // 自动刷新
//    [header beginRefreshing];
//    
//    // 3.2.上拉加载更多
//    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
//    footer.scrollView = scrollImage;
//    footer.delegate = self;
    
    __weak PhotoGridController *weakSelf = self;
    
    // setup pull-to-refresh
    [scrollImage addPullToRefreshWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startRefresh];
        }
        
    }];
    
    {
        // setup infinite scrolling
        [scrollImage addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf._loading) {
                weakSelf._loading = YES;
                [weakSelf startMoreLoad];
            }
        }];
    }
    
    
    m_nPage = 0;
    m_nSelectBtn = 0;
    [btnFilter setTitle:@"All" forState:UIControlStateNormal];

    viewFilter.hidden = YES;
    m_bShow = NO;
    tvFilter.layer.cornerRadius = 5;
    tvFilter.layer.borderWidth = 1;
    tvFilter.layer.borderColor = [[UIColor grayColor] CGColor];
    
    UITapGestureRecognizer * tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCloseMenu:)];
    tapGestureUser.numberOfTapsRequired = 1;
    [viewSubGesture addGestureRecognizer:tapGestureUser];
}

- (void)startRefresh {
    
    m_nPage = 0;
    [self getPhotoGallery:nil];
    
}

- (void)startMoreLoad {
    
    [self getPhotoGallery:nil];
}
- (void) doneLoadingTableViewData
{
    [scrollImage reloadData];
    
    [scrollImage.pullToRefreshView stopAnimating];
    [scrollImage.infiniteScrollingView stopAnimating];
    
    self._loading = NO;
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.automaticallyAdjustsScrollViewInsets = false;

    if (!bLoaded) {
        bLoaded = YES;

        m_nPage = 0;
        [self getPhotoGallery:nil];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
//    if (m_nPage == 1) {
//        [self setToolMenu];
//    }
//    [self setImageScroll];
    
    // 刷新表格
//    [tvFilter reloadData];
//    [scrollImage reloadData];
//    [self performSelector:@selector(refreshFilterView) withObject:nil];
    [self performSelector:@selector(refreshCollectView) withObject:nil];
    
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    if (refreshView != nil) {
        [refreshView endRefreshing];
    }
}
- (void) refreshFilterView
{
    [tvFilter reloadData];
}
- (void) refreshCollectView
{
    [scrollImage reloadData];
}

#pragma mark - 刷新控件的代理方法
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{

    NSLog(@"%@----开始进入刷新状态", refreshView.class);
    
    // 1.添加假数据
    if([refreshView isKindOfClass:[MJRefreshHeaderView class]])
    {
        // do somthing
        m_nPage = 0;
        [self getPhotoGallery:refreshView];
    }
    if ([refreshView isKindOfClass:[MJRefreshFooterView class]])
    {
        [self getPhotoGallery:refreshView];
    }

}

#pragma mark 刷新完毕
- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"%@----刷新完毕", refreshView.class);
}

#pragma mark 监听刷新状态的改变
- (void)refreshView:(MJRefreshBaseView *)refreshView stateChange:(MJRefreshState)state
{
    switch (state) {
        case MJRefreshStateNormal:
            NSLog(@"%@----切换到：普通状态", refreshView.class);
            break;
            
        case MJRefreshStatePulling:
            NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
            break;
            
        case MJRefreshStateRefreshing:
            NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
            break;
        default:
            break;
    }
}

#pragma mark - collection数据源代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
//    [collectionView.collectionViewLayout invalidateLayout];
    
    if (arrImages == nil) {
        return 0;
    }
    
    return arrImages.count;
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(100, 100);
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MJCollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSDictionary * dic = [arrImages objectAtIndex:indexPath.row];
    
    [cell.imgPhoto setImage:nil];
    
    NSString * urlString = [dic objectForKey:@"img_small_thumb"];
    [DLImageLoader loadImageFromURL:urlString
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  cell.imgPhoto.image = [UIImage imageWithData:imgData];
                              } else {
                                  // if we got error when load image
                              }
                          }];
    
    
    int nCreditWant = [[dic objectForKey:@"credit"] intValue];
    BOOL bUnlocked = [[dic objectForKey:@"unlock"] boolValue];
    
    if (nCreditWant == 0 || bUnlocked) {
        cell.imgLock.hidden = YES;
    } else {
        cell.imgLock.hidden = NO;
    }

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int nSelIndex = (int)indexPath.row;
    
    NSDictionary * selectImage = [arrImages objectAtIndex:nSelIndex];
    int nSelect = (int)[arrOrgImages indexOfObject:selectImage];
    
    PhotoListController * pController = [[PhotoListController alloc] initWithIndexAndDatas:nSelect :arrOrgImages : m_nPage enableAds:m_bEnableBanner];
    pController.delegate = self;
    [super onPush:pController];

}


#pragma mark
#pragma - Delegate
- (void) setBackImageArray:(NSArray *)arrBackImages page:(int)page
{
    if (m_nPage == page)
        return;
    
    
    [arrOrgImages removeAllObjects];
    [arrImages removeAllObjects];
    
    NSLog(@"arrBackImage = %d", (int)[arrBackImages count]);
    
    arrOrgImages = [NSMutableArray arrayWithArray:arrBackImages];
    arrImages = [NSMutableArray arrayWithArray:arrBackImages];
    
    m_nPage = page;
    
    [scrollImage reloadData];
}

-(void)getPhotoGallery:(MJRefreshBaseView*) refreshView{

    [self showLoading:@"Loading"];

    [NSThread detachNewThreadSelector: @selector(postServer:) toTarget:self withObject:refreshView];
}
-(void) postServer:(MJRefreshBaseView*)refreshView
{
    NSString * urlString = [MyUrl getPhotoGallery:m_nPage];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        
        [self hideLoading];
        
        NSArray * arrResult = [result objectForKey:@"photos"];
        
        if (arrResult == nil) {
            return;
        }
        
        if (arrOrgImages == nil || m_nPage == 0) {
            arrOrgImages = [NSMutableArray arrayWithArray:arrResult];
        }
        else {
            [arrOrgImages addObjectsFromArray:arrResult];
        }

        arrImages = [[NSMutableArray alloc] initWithArray:arrOrgImages];
    
        NSArray * filters = [result objectForKey:@"filters"];
        if (arrTitles == nil || m_nPage == 0) {
            arrTitles = [NSMutableArray arrayWithArray:filters];
        } else {
            for (NSString * one in filters) {
                if (![arrTitles containsObject:one]) {
                    [arrTitles addObject:one];
                }
            }
        }
        NSLog(@"filter = %@", arrTitles);
        
        m_bEnableBanner = [result[@"channel_info"][@"enable_banner_ads_ios"] boolValue];
        m_channel_BrightcoveId = [result[@"channel_info"] objectForKey:@"bc_playerid_ios"];
        m_channelUrl = [result[@"channel_info"] objectForKey:@"url"];

        m_nPage ++;

    }
    else {
        NSString * ErrMessage = [result objectForKey:@"message"];
        [self showFail:ErrMessage];
    }
    
    // 2.2秒后刷新表格UI
    if (refreshView != nil) {
        [self performSelector:@selector(doneWithView:) withObject:refreshView];
    }
    else {
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil];
    }

}

/*
#pragma mark -
#pragma mark ToolMenu

-(void) setToolMenu
{
    [[viewToolBar subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.mainItems = [[NSArray alloc] initWithObjects:[arrTitles firstObject], nil];
    self.subItems = [[NSArray alloc] initWithObjects:arrTitles, nil];
    
    NSDictionary *options = @{
                              RTFlyoutMenuUIOptionInnerItemSize: [NSValue valueWithCGSize:CGSizeMake(22, 22)],
                              RTFlyoutMenuUIOptionSubItemPaddings: [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(10, 15, 10, 15)]
                              };
	RTFlyoutMenu *m = [[RTFlyoutMenu alloc] initWithDelegate:self dataSource:self position:kRTFlyoutMenuPositionTop options:options];
	m.canvasView = self.view;
    
	CGRect mf = CGRectMake(5, 0, 50, 36);
	m.frame = mf;
    
    //	m.backgroundColor = [UIColor redColor];

	[viewToolBar addSubview:m];
	self.flyoutMenu = m;
    
	//	look & feel
	[[RTFlyoutItem appearanceWhenContainedIn:[viewToolBar class], nil] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[[RTFlyoutItem appearanceWhenContainedIn:[viewToolBar class], nil] setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];

}


#pragma mark - RTFlyoutMenuDataSource

- (NSUInteger)numberOfMainItemsInFlyoutMenu:(RTFlyoutMenu *)flyoutMenu {
	return [self.mainItems count];
}

- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForMainItem:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return nil;
    
	return [self.mainItems objectAtIndex:mainItemIndex];
}

- (NSUInteger)flyoutMenu:(RTFlyoutMenu *)flyoutMenu numberOfItemsInSubmenu:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return 0;
    
    NSArray * array = [self.subItems objectAtIndex:mainItemIndex];
	return [array count];
}

- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForSubItem:(NSUInteger)subItemIndex inMainItem:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return nil;

    NSArray * array = [self.subItems objectAtIndex:mainItemIndex];
	if (subItemIndex >= [array count]) return nil;
    
	return [[self.subItems objectAtIndex:mainItemIndex] objectAtIndex:subItemIndex];
}


#pragma mark - RTFlyoutMenuDelegate

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectMainItemWithIndex:(NSInteger)index {
//    NSLog(@"Tap on main item: %d", index);
}

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectSubItemWithIndex:(NSInteger)subIndex mainMenuItemIndex:(NSInteger)mainIndex {
//    NSLog(@"Tap on main/sub index: %d / %d", mainIndex, subIndex);
    
    if (subIndex >= 0) {
        m_nSelectBtn = (int)subIndex;
        [self change];
    }
    
}

- (void)didReloadFlyoutMenu:(RTFlyoutMenu *)flyoutMenu {
//	[self recenterFlyoutMenu];
}

*/


-(void) change {
    
    [arrImages removeAllObjects];
    
    NSString * filter = [[arrTitles objectAtIndex:m_nSelectBtn] lowercaseString];
    if ([filter rangeOfString:@"all"].location != NSNotFound) {
        arrImages = [[NSMutableArray alloc] initWithArray:arrOrgImages];
    }
    else {
        for (NSDictionary * dic in arrOrgImages) {
            NSString * tag = [[dic objectForKey:@"tags"] lowercaseString];
            
            if ([filter rangeOfString:tag].location != NSNotFound) {
                [arrImages addObject:dic];
            }
        }
    }
   
    [scrollImage reloadData];
    
//    [self setImageScroll];
}


#pragma mark
#define MENU_HEIGHT  400

-(void) showMenu:(BOOL) bShow
{
    if (bShow) {
        
        [self performSelector:@selector(refreshFilterView) withObject:nil];

        viewFilter.hidden = NO;
        viewFilter.frame = CGRectMake(viewFilter.frame.origin.x, viewFilter.frame.origin.y,
                                      viewFilter.frame.size.width, 0);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        viewFilter.frame = CGRectMake(viewFilter.frame.origin.x, viewFilter.frame.origin.y,
                                      viewFilter.frame.size.width, MENU_HEIGHT);
        
        [UIView commitAnimations];
        
                m_bShow = YES;
    }
    else {
        viewFilter.frame = CGRectMake(viewFilter.frame.origin.x, viewFilter.frame.origin.y,
                                      viewFilter.frame.size.width, MENU_HEIGHT);
        
        [UIView beginAnimations:nil context:nil];
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             viewFilter.frame = CGRectMake(viewFilter.frame.origin.x, viewFilter.frame.origin.y,
                                                           viewFilter.frame.size.width, 0);
                         }
                         completion:^(BOOL finished){
                             viewFilter.hidden = YES;
                         }];
        [UIView commitAnimations];
        
                m_bShow = NO;
    }
    
}

-(void) onCloseMenu:(UITapGestureRecognizer*) gesture
{
    if([gesture.view class] == tvFilter.class){
        return;
    }
    
    [self showMenu:NO];
}

- (IBAction) onClickFilter:(id)sender
{
    if (!m_bShow) {
        [self showMenu:YES];
    } else {
        [self showMenu:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrTitles == nil) {
        return 0;
    }
    
    return [arrTitles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
    }
    
    
    NSString * title = [arrTitles objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:10.0f];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *title = [arrTitles objectAtIndex:indexPath.row];
    [btnFilter setTitle:title forState:UIControlStateNormal];
    
    [self showMenu:NO];
    
    if (indexPath.row != m_nSelectBtn) {
        m_nSelectBtn = (int)indexPath.row;
        [self change];
    }
}

@end
