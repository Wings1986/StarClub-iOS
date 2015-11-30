//
//  ParentTableViewController.m
//  StarClub
//

#import "ParentTableViewController.h"


#import "ImageGalleryViewController.h"
#import "FanDetailController.h"
#import "YoutubeController.h"
#import "BuyCreditController.h"
#import "LikeListController.h"

#import "NSDictionary+JRAdditions.h"
#import "GHAppDelegate.h"

#import "BaseNavController.h"
#import  "StarTracker.h"

#ifdef BRIGHT_SDK
#import "BCOVPlayerController.h"
#endif

#pragma mark Private Interface
@interface ParentTableViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (nonatomic, assign) BOOL _loading;

@end



#pragma mark Implementation
@implementation ParentTableViewController


#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mFeedType = TYPE_ALL;
    self.arrTableList = [[NSMutableArray alloc] init];
    self.starInfo = [[NSMutableDictionary alloc] init];
    
    self.mTableView.rowHeight = 560;
    [self.mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    __weak ParentTableViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.mTableView addPullToRefreshWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startRefresh];
        }

    }];
    
    if (m_bMoreLoad) {
        // setup infinite scrolling
        [self.mTableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf._loading) {
                weakSelf._loading = YES;
                [weakSelf startMoreLoad];
            }
        }];
    }
}

- (void)startRefresh {
}

- (void)startMoreLoad {
    
}
- (void) doneLoadingTableViewData
{
    __weak ParentTableViewController *weakSelf = self;
    
//    [weakSelf.mTableView beginUpdates];
//    
//    [weakSelf.mTableView endUpdates];
    [weakSelf.mTableView reloadData];
    
    [weakSelf.mTableView.pullToRefreshView stopAnimating];
    [weakSelf.mTableView.infiniteScrollingView stopAnimating];
    
    weakSelf._loading = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!bLoaded) {

//        if (_refreshHeaderView == nil) {
//            
//            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.mTableView.frame.size.height, self.view.frame.size.width, self.mTableView.bounds.size.height)];
//            view.delegate = self;
//            [self.mTableView addSubview:view];
//            _refreshHeaderView = view;
//            
//        }
//        
//        //  update the last update date
//        [_refreshHeaderView refreshLastUpdatedDate];
        
    }
}

#pragma mark -
#pragma makr Like Button
-(void) onLikeList:(UITapGestureRecognizer*) gesture
{
    UILabel * label = (UILabel*) gesture.view;
    int tag = (int)label.tag - BTN_LIKE_LIST_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:tag];
    
    
    LikeListController * pController = [[LikeListController alloc] initWithFeed:feed];
    [self onPush:pController];
}


-(void) onLikeButton:(UIButton*) sender
{
    if ([sender isSelected]) {
        [sender setSelected:NO];
        [sender setHighlighted:NO];
    }
    else {
        [sender setSelected:YES];
        [sender setHighlighted:YES];
    }
    
    int nIndex = (int)sender.tag - BTN_LIKE_ID;
    
    
    NSDictionary * data = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:nIndex], @"index",
                           [NSNumber numberWithBool:[sender isSelected]], @"select",
                           nil];
    NSLog(@"%@", data);
    
    [NSThread detachNewThreadSelector: @selector(likeServer:) toTarget:self withObject:data];
    
}
-(void) likeServer:(NSDictionary *) dic
{
    int index = [[dic objectForKey:@"index"] intValue];
    int select = [[dic objectForKey:@"select"] intValue];
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:index];
    
    NSString* postType = [feed objectForKey:@"post_type"];
    NSString* contentId = [feed objectForKey:@"content_id"];
    
    NSString * urlString = [MyUrl addLike:postType contentId:contentId like:select];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        
        int numberOfLike = [[result objectForKey:@"numbersoflike"] intValue];
        
        [feed setObject:[NSNumber numberWithInt:numberOfLike] forKey:@"numberoflike"];
        [feed setObject:[NSNumber numberWithBool:select==1?YES:NO] forKey:@"did_like"];
        
        [self.arrTableList replaceObjectAtIndex:index withObject:feed];

        [self performSelectorOnMainThread:@selector(doneRefreshTable) withObject:nil waitUntilDone:YES];
        
        int i = 0 ;
        for (i = 0 ; i < (int)[self.arrAllTableList count] ; i ++) {
            NSDictionary * _dic = [self.arrAllTableList objectAtIndex:i];
            NSString * cId = [_dic objectForKey:@"content_id"];
            if ([cId isEqualToString:contentId]) {
                break;
            }
        }

        [self.arrAllTableList replaceObjectAtIndex:i withObject:feed];
    }
    else {
        NSLog(@"push fail");
    }
    
}
-(void) doneRefreshTable
{
    [self.mTableView reloadData];
}


#pragma mark -
#pragma mark Comment 
-(void) onComment:(UIButton *)btn
{
    int nIndex = (int)btn.tag - BTN_COMMENT_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:nIndex];

    [super onCommentFeed:feed index:nIndex Delegate: self];
}

-(void) onAddComment:(UIButton *)btn
{
    int nIndex = (int)btn.tag - BTN_ADD_COMMENT_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:nIndex];

    [super onAddCommentFeed:feed index:nIndex Delegate: self];
    
}

#pragma mark -
#pragma mark button event ----------

-(void) onHeaderButton:(UIButton*) sender
{
    int oldType = self.mFeedType;
    
    int selTag = (int)sender.tag;
    
    UIView * parentView = sender.superview;
    
    for (UIView *sub in [parentView subviews])
    {
        if([sub isKindOfClass:[UIButton class]])
        {
            UIButton * btn = (UIButton*) sub;
            if (btn.tag == selTag) {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME_BOLD size:13.0f];
            }else {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME size:12.0f];
            }
            
        }
    }
    
    switch (selTag-BTN_HEADER_ID) {
        case 0:
            self.mFeedType = TYPE_ALL;
            break;
        case 1:
            self.mFeedType = TYPE_TEXT;
            break;
        case 2:
            self.mFeedType = TYPE_PHOTO;
            break;
        case 3:
            self.mFeedType = TYPE_VIDEO;
            break;
        case 4:
            self.mFeedType = TYPE_QUIZ;
            break;
    }
    
    if (oldType != self.mFeedType) {
        
        [self filterFeed];

        [self.mTableView reloadData];
    }
    
}

- (void) filterFeed{
    
    if (self.mFeedType == TYPE_ALL) {
        self.arrTableList = [NSMutableArray arrayWithArray:self.arrAllTableList];
    }
    else {
    
        NSMutableArray * arrTemp = [NSMutableArray new];
        
        for (NSDictionary * dic in self.arrAllTableList) {
            int feedType = TYPE_TEXT;
            NSString * postType = [[dic objectForKey:@"post_type"] lowercaseString];
            if ([postType rangeOfString:@"photo"].location != NSNotFound) {
                feedType = TYPE_PHOTO;
            } else if ([postType rangeOfString:@"video"].location != NSNotFound) {
                feedType = TYPE_VIDEO;
            } else if ([postType rangeOfString:@"text"].location != NSNotFound) {
                feedType = TYPE_TEXT;
            } else {
                feedType = TYPE_QUIZ;
            }
            
            if (self.mFeedType == feedType) {
                [arrTemp addObject:dic];
            }
        }
        self.arrTableList = [NSMutableArray arrayWithArray:arrTemp];
    }
    
    if (m_bEnableBanner) {
        int total = (int)[self.arrTableList count];
        int nAddCount = (int)[self.arrTableList count] / 2;
        
        int nIndex = 1;
        int nInsertId = 0;
        for (int i = 0 ; i < nAddCount; i ++) {
            if (nInsertId >= 3) {
                break;
            }
            NSMutableDictionary * feedBanner = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"banner", @"post_type",
                                                [NSNumber numberWithInt:nInsertId], @"id", nil];
            [self.arrTableList insertObject:feedBanner atIndex:nIndex];
            nInsertId ++;
            nIndex += 3;
        }
        if(total % 2 == 1){
            if (nInsertId < 3) {
                NSMutableDictionary * feedBanner = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"banner", @"post_type",
                                                    [NSNumber numberWithInt:nInsertId], @"id", nil];
                [self.arrTableList insertObject:feedBanner atIndex:[self.arrTableList count]];
            }
        }
    }

    
}

#pragma mark -
#pragma mark Photo Detail 

-(void) gotoPhotoDetail:(NSDictionary *) dic
{
    NSString * url_link = [dic objectForKey:@"url_link"];
    if (url_link != nil && url_link != [NSNull class] && url_link.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url_link]];
        return;
    }

    
    ImageGalleryViewController * pController = [[ImageGalleryViewController alloc] initWithDic:dic];
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self onPush:pController];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];

//    UINavigationController * nav = [[BaseNavController alloc] initWithRootViewController:pController];
//    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -
#pragma mark Photo Lock
-(void) onPhotoLock:(UITapGestureRecognizer*) gesture
{
    
    UIImageView * imageView = (UIImageView*) gesture.view;
    int tag = (int)imageView.tag - BTN_LOCK_ID;
    
    m_nSelLock = tag;
    m_feedLock = [self.arrTableList objectAtIndex:tag];
    
    NSString * strNumOfCredit = [m_feedLock objectForKey:@"credit"];
    m_numWant = [strNumOfCredit intValue];
    int userNumOfCredit = [[[[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO] objectForKey:@"credit"] intValue];
    
    
    if (userNumOfCredit >= m_numWant) {
        NSString * msg = [NSString stringWithFormat:@"You have %d credits left. This content need %d credits to unlock. Do you want to unlock this content?",
                          userNumOfCredit, m_numWant];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Unlock Confirmation"
                                                        message: msg
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"YES", nil];
        alert.tag = 100;
        [alert show];
    }
    else {
        NSString * msg = [NSString stringWithFormat:@"You have %d credits left. This content need %d credits to unlock. You need to redeem StarCredits",
                          userNumOfCredit, m_numWant];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Unlock Confirmation"
                                                        message: msg
                                                       delegate: self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Buy", nil];
        alert.tag = 101;
        [alert show];
    }
    
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) { // OK
            [self onUnLock];
        }
    }
    else if (alertView.tag == 101) {
        if (buttonIndex == 1) { // OK
            BuyCreditController * pController = [[BuyCreditController alloc] init];
            [self onPush:pController];
//            GHAppDelegate * appDelegate = APPDELEGATE;
//            [appDelegate didSelectedSettingView];
        }
    }
}
-(void) onUnLock {
    if (m_feedLock == nil || m_nSelLock < 0) {
        return;
    }
    
    [self showLoading:@"Unlocking"];
    
    [NSThread detachNewThreadSelector: @selector(postLockServer) toTarget:self withObject:nil];
    
}
-(void) postLockServer
{
    NSString * postType = [m_feedLock objectForKey:@"post_type"];
    NSString * contentId = [m_feedLock objectForKey:@"content_id"];
    
    NSString * urlResult = [MyUrl getLock:postType contentId:contentId];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            [super hideLoading];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:USER_INFO]];

            int nCredit = [[userInfo objectForKey:@"credit"] intValue];
//            NSString *sCredit = [NSString stringWithFormat:@"%d", nCredit-m_numWant];
//            [userInfo setValue:sCredit forKey:@"credit"];
            [userInfo setValue:[NSNumber numberWithInt:nCredit-m_numWant] forKey:@"credit"];
            
            [defaults setValue:[userInfo dictionaryByReplacingNullsWithStrings] forKey:USER_INFO];
            [defaults synchronize];
            
            
            [m_feedLock setValue:[NSNumber numberWithBool:YES] forKey:@"unlock"];
            
            [self.arrTableList replaceObjectAtIndex:m_nSelLock withObject:m_feedLock];
            
            [self performSelectorOnMainThread:@selector(doneRefreshTable) withObject:nil waitUntilDone:YES];

            
            int i = 0 ;
            for (i = 0 ; i < (int)[self.arrAllTableList count] ; i ++) {
                NSDictionary * _dic = [self.arrAllTableList objectAtIndex:i];
                NSString * cId = [_dic objectForKey:@"content_id"];
                if ([cId isEqualToString:contentId]) {
                    break;
                }
            }
            [self.arrAllTableList replaceObjectAtIndex:i withObject:m_feedLock];

            
            return;
        }
        else {
            NSString * ErrMessage = [result objectForKey:@"message"];
            [self showFail:ErrMessage];
            return;
        }
    }
    
    [super hideLoading];
}



#pragma mark -
#pragma mark Fan Detail
-(void) gotoFanDetail:(NSString*) userID {

    FanDetailController * pController = [[FanDetailController alloc] initWithUserID:userID];
    [self onPush:pController];
}

#pragma mark - 
#pragma mark Vide Play
-(void) onVideoDetail:(UITapGestureRecognizer*) recognize
{
    UIImageView * imageView = (UIImageView*) recognize.view;
    int tag = (int)imageView.tag;
    
    int videoId = tag - BTN_PHOTO_ID;
    
    NSDictionary * dic = [self.arrTableList objectAtIndex:videoId];
    NSString * videoUrl = [dic objectForKey:@"video_url"];
    NSString * brightCoveId = [dic objectForKey:@"brightcove_media_id"];
    
    
    if (videoUrl == nil || videoUrl == [NSNull class] || videoUrl.length < 1) {
        videoUrl = [dic objectForKey:@"destination"];
    }

    NSLog(@"videoUrl = %@", videoUrl);
    
    if ([videoUrl rangeOfString:@"youtube"].location != NSNotFound
        || [videoUrl rangeOfString:@"watch?"].location != NSNotFound
        || [videoUrl rangeOfString:@"youtu.be"].location != NSNotFound) {
        YoutubeController * pController = [[YoutubeController alloc] initWithUrl:videoUrl];
        [self onPush:pController];
    }
    else {
        NSScanner *scanner = [NSScanner scannerWithString:m_channel_BrightcoveId];
        BOOL numericPlayer = [scanner scanInteger:NULL] && [scanner isAtEnd];
        scanner = [NSScanner scannerWithString:brightCoveId];
        BOOL numericId = [scanner scanInteger:NULL] && [scanner isAtEnd];

        if (!numericPlayer || !numericId) {

                [super playVideo:videoUrl];   // No BC Video Id or backdoor switch to disable BC player

            }
        else {
            
            
            //brightCoveId  consists only of the digits 0 through 9
            BCOVPlayerController *pController = [[BCOVPlayerController alloc] initWithVideoURL:videoUrl videoId:brightCoveId];
            [super onPush:pController];
            }
        }




}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.m_nNumOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.m_nNumOfSection == 1) {
        return [self.arrTableList count];
    }
    else {
        if (section == 0) {
            return 1;
        } else {
            return [self.arrTableList count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.m_nNumOfSection == 2 && indexPath.section == 0) {
        return 160;
    }
    else {
        
        if (self.mFeedType == TYPE_TEXT) {
            return 250;
        }
        else if (self.mFeedType == TYPE_QUIZ) {
            return 350;
        }
        else {
            return 409;
        }
    }
    
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ((self.m_nNumOfSection == 2 && section == 1)
        || (self.m_nNumOfSection == 1 && section == 0)) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, HEADER_HEIGHT)];
        view.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
        
        /* Create custom view to display section header... */
        
        for (int i = 0; i < self.m_nNumOfHeader; i ++) {
            int posX = 60 * i + ((self.m_nNumOfHeader == 5)? 0 : 40);
            CGRect frame = CGRectMake(posX , 0, 60, HEADER_HEIGHT);
            
            UIButton * btn = [[UIButton alloc] initWithFrame:frame];
            btn.titleLabel.font = [UIFont fontWithName:FONT_NAME size:14.0f];
            NSString * strTitle = @"";
            if (i == 0) {
                strTitle = @"  All";
            } else if (i == 1) {
                strTitle = @"Text";
            } else if (i == 2) {
                strTitle = @"Photo";
            } else if (i == 3) {
                strTitle = @"Video";
            } else if (i == 4) {
                strTitle = @"Polls";
            }
            
            [btn setTitle:strTitle forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            btn.tag = BTN_HEADER_ID + i;
            [btn addTarget:self
                    action:@selector(onHeaderButton:)
          forControlEvents:UIControlEventTouchUpInside];
            
            if (i == self.mFeedType) {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME_BOLD size:13.0f];
            } else {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME size:12.0f];
            }
            
            [view addSubview:btn];
        }
        
        UIImageView * imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT-1, tableView.frame.size.width, 1)];
        [imv setImage:[UIImage imageNamed:@"line"]];
        [view addSubview:imv];
        
        return view;
        
    }
    
    return nil;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
    
//    if (self.m_nNumOfSection == 2 && section == 0)
//        return 0.0f;
//    
//    return HEADER_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

/*
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mTableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
//	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
*/




@end
