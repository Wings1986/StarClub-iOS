//
//  VideosController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/30/13.
//
//

#import "VideosController.h"
#import "PhotoCell.h"
#import "GHAppDelegate.h"
#import "DLImageLoader.h"
#import "CommentAutoController.h"
#import "LikeListController.h"

#import "NSDictionary+JRAdditions.h"

#import "BuyCreditController.h"

#import "StarTracker.h"



@interface VideosController ()<CommentAutoControllerDelegate>
{
    
}
@end

@implementation VideosController

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

    [StarTracker StarSendView:@"Videos"];
    
    m_bMoreLoad = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!bLoaded) {
        bLoaded = YES;
        
        [super showLoading:@"Loading..."];
        m_nPage = 1;
        [self getVideoGallery];
    }
}

-(void)getVideoGallery{
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
//    NSString * urlString = [MyUrl getVideoGallery];
    NSString * urlString = [MyUrl getVideoGallery:m_nPage];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        
        if (self.arrAllTableList == nil || m_nPage <= 1) {
            self.arrAllTableList = [result objectForKey:@"videos"];
        }
        else {
            [self.arrAllTableList addObjectsFromArray:[result objectForKey:@"videos"]];
        }
        
        self.arrTableList = [NSMutableArray arrayWithArray:self.arrAllTableList];

        m_bEnableBanner = [result[@"channel_info"][@"enable_banner_ads_ios"] boolValue];
        m_channel_BrightcoveId = [result[@"channel_info"] objectForKey:@"bc_playerid_ios"];
        m_channelUrl = [result[@"channel_info"] objectForKey:@"url"];
        
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

        m_nPage ++;
        
        [super hideLoading];
    }
    else {
        NSString * ErrMessage = [result objectForKey:@"message"];
        [self showFail:ErrMessage];
    }

    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];


}
- (void)startRefresh
{
    [super startRefresh];
    
    m_nPage = 1;
    [self getVideoGallery];
}
- (void)startMoreLoad
{
    [super startMoreLoad];
    
    [self getVideoGallery];
}
- (void) doneLoadingTableViewData {
    [super doneLoadingTableViewData];
}


#pragma mark --------------- Table view ---------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrTableList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * feed = [self.arrTableList objectAtIndex:indexPath.row];
    NSString * postType = [[feed objectForKey:@"post_type"] lowercaseString];
    if (postType == nil) {
        NSString * sW = [feed objectForKey:@"img_width"];
        NSString * sH = [feed objectForKey:@"img_height"];
        
        int height = HEIGHT_SHARE + HEIGHT_SPACE;
        if ((NSString *)[NSNull null] != sW && (NSString *)[NSNull null] != sH) {
            int _width, _height;
            _width = [sW intValue];
            _height = [sH intValue];
            
            int realHeight = (FULL_WIDTH * _height / _width);
            height += realHeight; //HEIGHT_IMAGE;
        }
        else {
 //           height += 280.0f;
    height += HEIGHT_IMAGE;
        }
        
        // title
        
        UILabel * labelText = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_POS_X, 0, TITLE_WIDTH, 50)];
        labelText.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
        labelText.text = [feed objectForKey:@"description"];
        labelText.numberOfLines = 0;
        [labelText sizeToFit];
        
        int textHeight = TITLE_MARGIN*2 + labelText.frame.size.height;
        height += textHeight;
        
        return height;
    }
    else {
        return HEIGHT_BANNER+HEIGHT_SPACE;
    }
    
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * feed = [self.arrTableList objectAtIndex:indexPath.row];
    
    NSString * postType = [[feed objectForKey:@"post_type"] lowercaseString];
    if (postType != nil) {
#ifdef GOOGLE_DFP
        DFPBannerView * bannerView = nil;
#elif defined(GOOGLE_DFP_SWIPE)
        DFPSwipeableBannerView * bannerView = nil;
#else
        GADBannerView *bannerView = nil;
#endif
        
        static NSString *MyIdentifier = @"AdCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
            
#ifdef GOOGLE_DFP
            bannerView = (DFPBannerView*)[cell viewWithTag:indexPath.row + BANNER_ID];
            
#elif defined(GOOGLE_DFP_SWIPE)
            bannerView = (DFPSwipeableBannerView*)[cell viewWithTag:indexPath.row + BANNER_ID];
#else
            bannerView = (GADBannerView*)[cell viewWithTag:indexPath.row + BANNER_ID];
#endif
            
            if (bannerView == nil) {
#ifdef GOOGLE_DFP
                bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
                
#elif defined(GOOGLE_DFP_SWIPE)
                bannerView = [[DFPSwipeableBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
                
#else
                bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
#endif
                
                // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
                int nId = [[feed objectForKey:@"id"] intValue];
                if (nId % 3 == 0) {
                    bannerView.adUnitID = ADMOB_VIDEO_GALLARY_ID_1;
                } else if (nId % 3 == 1) {
                    bannerView.adUnitID = ADMOB_VIDEO_GALLARY_ID_2;
                } else {
                    bannerView.adUnitID = ADMOB_VIDEO_GALLARY_ID_3;
                }

                bannerView.rootViewController = self;
                bannerView.tag = indexPath.row + BANNER_ID;
                
//                [self preventBannerCaptureTouch:bannerView];

                [cell addSubview:bannerView];
            }
        }
        
        // Initiate a generic request to load it with an ad.
        GADRequest *request = [GADRequest request];
        [bannerView loadRequest:request];
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"PhotoCell";
        
        PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"PhotoCell" bundle:nil];
            cell =(PhotoCell*) viewController.view;
        }
        
        NSDictionary * dic = [self.arrTableList objectAtIndex:indexPath.row];
        
        [cell.imgPhoto setImage:nil];
        
        [DLImageLoader loadImageFromURL:[dic objectForKey:@"image_path"]
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      cell.imgPhoto.image = [UIImage imageWithData:imgData];
                                  } else {
                                      // if we got error when load image
                                  }
                              }];
        
        cell.imgPhoto.contentMode = UIViewContentModeScaleAspectFill;
        cell.imgPhoto.clipsToBounds = YES;
        cell.imgPhoto.userInteractionEnabled = YES;
        cell.imgPhoto.tag = BTN_PHOTO_ID + indexPath.row;
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoDetail:)];
        tapGesture.numberOfTapsRequired = 1;
        
        [cell.imgPhoto addGestureRecognizer:tapGesture];

        int height = 0;
        NSString * sW = [feed objectForKey:@"img_width"];
        NSString * sH = [feed objectForKey:@"img_height"];
        
        if ((NSString *)[NSNull null] != sW && (NSString *)[NSNull null] != sH) {
            int _width = [sW intValue];
            int _height = [sH intValue];
            
            int realHeight = (FULL_WIDTH * _height / _width);
            height = realHeight;
        }
        else {
            height = HEIGHT_IMAGE;
        }
        cell.imgPhoto.frame = CGRectMake(cell.imgPhoto.frame.origin.x, 0,
                                         FULL_WIDTH, height);

        
        cell.viewLock.frame = cell.imgPhoto.frame;
        cell.viewLock.tag = BTN_LOCK_ID + indexPath.row;
        cell.viewLock.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGestureLock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoLock:)];
        tapGestureLock.numberOfTapsRequired = 1;
        [cell.viewLock addGestureRecognizer:tapGestureLock];
        
        
        cell.ivVideoIcon.hidden = NO;
        cell.ivVideoIcon.center = CGPointMake(cell.imgPhoto.frame.size.width/2,
                                              cell.imgPhoto.frame.origin.y + cell.imgPhoto.frame.size.height/2);


        
        cell.lbDetail.frame = CGRectMake(TITLE_POS_X,cell.imgPhoto.frame.origin.y + cell.imgPhoto.frame.size.height + TITLE_MARGIN, TITLE_WIDTH, 34);
//        cell.lbDetail.frame = CGRectMake(TITLE_POS_X, TITLE_MARGIN+HEIGHT_HEADER, TITLE_WIDTH, 34);
        cell.lbDetail.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
        cell.lbDetail.text = [dic objectForKey:@"description"];
        cell.lbDetail.numberOfLines = 0;
        [cell.lbDetail sizeToFit];
        
        
        int nCreditWant = [[feed objectForKey:@"credit"] intValue];
        cell.lbLockNum.text = [NSString  stringWithFormat:@"%d Credits", nCreditWant];
        
        BOOL bUnlocked = [[feed objectForKey:@"unlock"] boolValue];
        
        if (nCreditWant == 0 || bUnlocked) {
            cell.viewLock.hidden = YES;
            
            [cell.btnLike setEnabled:YES];
            [cell.btnComment setEnabled:YES];
            [cell.btnAddComment setEnabled:YES];
            [cell.btnShare setEnabled:YES];
            cell.lbLikeNum.userInteractionEnabled = YES;
        } else {
            cell.viewLock.hidden = NO;
            
            [cell.btnLike setEnabled:NO];
            [cell.btnComment setEnabled:NO];
            [cell.btnAddComment setEnabled:NO];
            [cell.btnShare setEnabled:NO];
            cell.lbLikeNum.userInteractionEnabled = NO;
        }
        
        int nComment = [[dic objectForKey:@"numbersofcomments"] intValue];
        NSString * sComment = @"";
        if (nComment == 1) {
            sComment = [NSString stringWithFormat:@"%d Comment", nComment];
        } else if (nComment > 1) {
            sComment = [NSString stringWithFormat:@"%d Comments", nComment];
        } else {
            sComment = @"No Comments";
        }
        cell.lbComment.text = sComment;
        
        

        cell.btnComment.tag = BTN_COMMENT_ID + indexPath.row;
        [cell.btnComment addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];

        cell.btnAddComment.tag = BTN_ADD_COMMENT_ID + indexPath.row;
        [cell.btnAddComment addTarget:self action:@selector(onAddComment:) forControlEvents:UIControlEventTouchUpInside];

        cell.btnShare.tag = BTN_FACEBOOK_ID + indexPath.row;
        [cell.btnShare addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
        
        int like = [[feed objectForKey:@"numberoflike"] intValue];
        cell.lbLikeNum.text = [NSString stringWithFormat:@"%d", like];
        cell.lbLikeNum.tag = BTN_LIKE_LIST_ID + indexPath.row;
        cell.lbLikeNum.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGestureLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLikeList:)];
        tapGestureLike.numberOfTapsRequired = 1;
        [cell.lbLikeNum addGestureRecognizer:tapGestureLike];
        
        
        cell.btnLike.tag = BTN_LIKE_ID + indexPath.row;
        BOOL didLike = [[feed objectForKey:@"did_like"] boolValue];
        [cell.btnLike setSelected:didLike];
        [cell.btnLike addTarget:self action:@selector(onLikeButton:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void) onComment:(UIButton *)btn
{
    int nIndex = (int)btn.tag - BTN_COMMENT_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:nIndex];
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:[feed objectForKey:@"id"] forKey:CONTENTID];
    [dic setObject:@"video" forKey:POSTTYPE];
    
    [super onCommentFeed:dic index:nIndex Delegate:self];
}

-(void) commentDone:(int)index comments:(NSArray *)arrComment count:(int)totalComment {
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[self.arrTableList objectAtIndex:index]];
    
    [dic setObject:arrComment forKey:@"comments"];
    [dic setObject:[NSNumber numberWithInt:totalComment] forKey:@"numbersofcomments"];
    [dic setObject:[NSNumber numberWithInt:totalComment] forKey:@"numbersofcomments"];
    
    [self.arrTableList replaceObjectAtIndex:index withObject:dic];
    
    [self doneLoadingTableViewData];
}



-(void) onShare:(UIButton*) btn
{
    m_nIndexShare = (int)btn.tag - BTN_FACEBOOK_ID;

    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexShare];
    
    NSString * text = [feed objectForKey:@"description"];
    NSString * contentId = [feed objectForKey:@"id"];
    
    feed[@"caption"] = text;
    feed[@"content_id"] = contentId;
    feed[@"post_type"] = @"video";
    
    PublishFeedController * pController = [[PublishFeedController alloc] initWithShare:feed];
    [super onPush:pController];

//    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", nil];
//    action.tag = 1800;
//    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1800) {
        
        NSDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexShare];
        
        NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:m_nIndexShare inSection:0];
        
        UIImage * imagePhoto = NULL;
        PhotoCell *cell = (PhotoCell*)[self.mTableView cellForRowAtIndexPath:nowIndex];
        imagePhoto = cell.imgPhoto.image;
        
        NSString * text = [feed objectForKey:@"description"];
        NSString * imgUrl = [feed objectForKey:@"image_path"];
        NSString * contentId = [feed objectForKey:@"id"];
        NSString * postType = @"video";
        NSString * deepLink =  [[feed objectForKey:@"deep_link_web"] stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
        
        
        NSMutableDictionary* postObj = [[NSMutableDictionary alloc] init];
        [postObj setObject:text forKey:@"TEXT"];
        if (imagePhoto != nil) {
            [postObj setObject:imagePhoto forKey:@"IMAGE"];
            [postObj setObject:imgUrl forKey:@"IMAGEURL"];
        }
        
        [postObj setObject:postType forKey:@"POSTTYPE"];
        [postObj setObject:contentId forKey:@"CONTENTID"];
        [postObj setObject:deepLink forKey:@"DEEPLINK"];
        
        
        if (buttonIndex == 0) { // facebook
            [super onFacebook:postObj];
        }
        else if (buttonIndex == 1) {//twitter
            [super onTwitter:postObj];
        }
        else if (buttonIndex == 2) {//instagram
            [super onInstagram:postObj];
        }
        
    }
}
-(void) onLikeList:(UITapGestureRecognizer*) gesture
{
    UILabel * label = (UILabel*) gesture.view;
    int tag = (int)label.tag - BTN_LIKE_LIST_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:tag];
    [feed setObject:@"video" forKey:@"post_type"];
    [feed setObject:[feed objectForKey:@"id"] forKey:@"content_id"];

    
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
    [NSThread detachNewThreadSelector: @selector(likeServer:) toTarget:self withObject:data];
    
}
-(void) likeServer:(NSDictionary *) dic
{
    int index = [[dic objectForKey:@"index"] intValue];
    int select = [[dic objectForKey:@"select"] intValue];
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:index];
    
    NSString* postType = @"video";
    NSString* contentId = [feed objectForKey:@"id"];
    
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
        
         [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
    }
    else {
        NSLog(@"push fail");
    }
    
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
    
    [self showLoading:@"Unlocking..."];
    
    [NSThread detachNewThreadSelector: @selector(postLockServer) toTarget:self withObject:nil];
    
}
-(void) postLockServer
{
    NSString * postType = @"video";
    NSString * contentId = [m_feedLock objectForKey:@"id"];
    
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
            
            [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
            
            int i = 0 ;
            for (i = 0 ; i < (int)[self.arrAllTableList count] ; i ++) {
                NSDictionary * _dic = [self.arrAllTableList objectAtIndex:i];
                NSString * cId = [_dic objectForKey:@"id"];
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


//- (void)preventBannerCaptureTouch:(GADBannerView*)bannerView
//{
//    for (UIWebView *webView in bannerView.subviews) {
//        if ([webView isKindOfClass:[UIWebView class]]) {
//            
//            for (UIGestureRecognizer *gestureRecognizer in webView.gestureRecognizers) {
//                if ([gestureRecognizer isKindOfClass:NSClassFromString(@"GADImpressionTicketGestureRecognizer")]) {
//                    gestureRecognizer.delegate = self;
//                }
//            }
//            
//            for (id view in [[[webView subviews] firstObject] subviews]) {
//                if ([view isKindOfClass:NSClassFromString(@"UIWebBrowserView")]) {
//                    for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
//                        if ([recognizer isKindOfClass:NSClassFromString(@"UIWebTouchEventsGestureRecognizer")]) {
//                            [view removeGestureRecognizer:recognizer];
//                        }
//                    }
//                    return;
//                }
//            }
//        }
//    }
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
@end
