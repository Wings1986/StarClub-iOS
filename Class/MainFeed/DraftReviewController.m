//
//  DraftReviewController.m
//

#import "DraftReviewController.h"

#import "NSDate+TimeAgo.h"
#import "DLImageLoader.h"

#import "FeedImageCell.h"
#import "FanFeedImageCell.h"
#import "FeedTextCell.h"
#import "FanFeedTextCell.h"
#import "FeedQuizCell.h"

#import "CommentAutoController.h"
#import "PollsController.h"
#import "QuizController.h"

#import "BaseNavController.h"
#import "GHAppDelegate.h"

#import "AddTextController.h"
#import "AddPhotoController.h"
#import "AddVideoController.h"

#import "StarTracker.h"

#import "PublishFeedController.h"
#import "LikeListController.h"


@interface DraftReviewController ()<CommentAutoControllerDelegate, UIActionSheetDelegate,
                AddTextContollerDelegate, AddPhotoContollerDelegate, AddVideoContollerDelegate, PublishFeedDelegate>
{
    int m_nIndexDel;
}

@end



@implementation DraftReviewController

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
    m_bMoreLoad = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [ StarTracker StarSendView: MENU_DRAFT];
 
    self.m_nNumOfSection = 1;
    self.m_nNumOfHeader = 4;
    
    [self.arrTableList removeAllObjects];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];

    
    if (!bLoaded) {
        bLoaded = YES;

        [super showLoading:@"Loading..."];
        
        m_nPage = 1;
        [self getFeedDatas];
    }
}

- (void) getFeedDatas{

    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];

}
-(void) postServer
{
    NSString * urlString = [MyUrl getDraftFeedUrl:@"all" page:m_nPage];
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:pinResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            [self hideLoading];

            if (self.arrAllTableList == nil || m_nPage == 1) {
                self.arrAllTableList = [result objectForKey:@"feeds"];
            }
            else {
                [self.arrAllTableList addObjectsFromArray:[result objectForKey:@"feeds"]];
            }
            
            self.arrTableList = [NSMutableArray arrayWithArray:self.arrAllTableList];

            

            
            m_channel_BrightcoveId = [result[@"channel_info"] objectForKey:@"bc_playerid_ios"];
            m_channelUrl = [result[@"channel_info"] objectForKey:@"url"];
            
            //            [super filterFeed];
            
            self.starInfo = [result objectForKey:@"star"];

            m_nPage ++;
        }
        else {
            NSString * ErrMessage = [result objectForKey:@"message"];
            [self showFail:ErrMessage];
        }
        
    }

    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];

}

- (void)startRefresh
{
    [super startRefresh];
    
    m_nPage = 1;
    [self getFeedDatas];
}
- (void)startMoreLoad
{
    [super startMoreLoad];
    
    [self getFeedDatas];
}
- (void) doneLoadingTableViewData {
    
    [super doneLoadingTableViewData];
}



#pragma mark -
#pragma mark Comment Delegate
-(void) commentDone:(int)index comments:(NSArray *)arrComment count:(int)totalComment{

    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[self.arrTableList objectAtIndex:index]];
    [dic setObject:arrComment forKey:@"comments"];
    [dic setObject:[NSNumber numberWithInt:totalComment] forKey:@"comments_count"];
    
    [self.arrTableList replaceObjectAtIndex:index withObject:dic];

    [self doneLoadingTableViewData];
}

-(void) addCommentDone
{
//    [self getFeedDatas];
}


#pragma mark -
#pragma mark button event ----------
-(void) onAddMore
{
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil otherButtonTitles:@"Add Post", @"Update", nil];
    action.tag = 1987;
    [action showInView:[self.view window]];
}
-(void) onAddPost:(UIButton*) btn
{
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Create Post" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Text", @"Image", @"Video", nil];
    action.tag = 1989;
    [action showInView:[self.view window]];
}

- (void) addTextPostDone {
    m_nPage = 1;
    [self getFeedDatas];
}
-(void) addPhotoPostDone {
    m_nPage = 1;
    [self getFeedDatas];
}
-(void) addVideoPostDone {
    m_nPage = 1;
    [self getFeedDatas];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1989) {
        if (buttonIndex == 0) { // add text
            AddTextController * pController = [[AddTextController alloc] init];
            pController.delegate = self;
            [self onPush:pController];
        }
        else if (buttonIndex == 1) {//add photo
            AddPhotoController * pController = [[AddPhotoController alloc] init];
            pController.delegate = self;
            [self onPush:pController];
        }
        else if (buttonIndex == 2) { // add video
            AddVideoController * pController = [[AddVideoController alloc] init];
            pController.delegate = self;
            [self onPush:pController];
            
        }
    }
    else if (actionSheet.tag == 1988) { // delete feed
        if (buttonIndex == 0) {
            [NSThread detachNewThreadSelector: @selector(deleteServer) toTarget:self withObject:nil];
        }
    }
    else if (actionSheet.tag == 1977) { // report
        if (buttonIndex == 0) {
            NSDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexDel];
            
            [NSThread detachNewThreadSelector: @selector(getAdminServer:) toTarget:self withObject:feed];
        }
    }
    else if (actionSheet.tag == 1987) { // add more
        if (buttonIndex == 0) { // Add post
            [self onAddPost:nil];
        }
        else if (buttonIndex == 1) { // update
//            [self onUpdate];
        }
    }
    else if(actionSheet.tag == 1800) { // share facebook
        NSDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexShare];
        
        NSString* postType = [feed objectForKey:@"post_type"];
        
        NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:m_nIndexShare inSection:self.m_nNumOfSection-1];
        
        int feedType = TYPE_PHOTO;
        postType = [postType lowercaseString];
        if ([postType rangeOfString:@"photo"].location != NSNotFound) {
            feedType = TYPE_PHOTO;
        } else if ([postType rangeOfString:@"text"].location != NSNotFound) {
            feedType = TYPE_TEXT;
        }
        
        UIImage * imagePhoto = NULL;
        if (feedType == TYPE_TEXT) {
            imagePhoto = nil;
        } else {
            FeedImageCell *cell = (FeedImageCell*)[self.mTableView cellForRowAtIndexPath:nowIndex];
            imagePhoto = cell.imgPhoto.image;
        }
        
        NSString * text = [feed objectForKey:@"caption"];
        NSString * imgUrl = [feed objectForKey:@"image_path"];
        NSString * contentId = [feed objectForKey:@"content_id"];
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
        else if (buttonIndex == 2) { // instagram
            [super onInstagram:postObj];
        }
    }
    else if (actionSheet.tag == 1300) {
        if (buttonIndex == 0) {
            if ([Global getUserType] == FAN) {
                [self approveFeed];
            }
            else {
                [self publishFeed];
            }
        }
    }
}


-(void) onPhotoDetail:(UITapGestureRecognizer*) gesture
{
    UIImageView * imageView = (UIImageView*) gesture.view;
    int tag = (int)imageView.tag - BTN_PHOTO_ID;
    
    NSDictionary * feed = [self.arrTableList objectAtIndex:tag];
    
    NSMutableDictionary * dicPhoto = [[NSMutableDictionary alloc] initWithDictionary:feed];
    [dicPhoto setObject:[feed objectForKey:@"content_id"] forKey:CONTENTID];
    [dicPhoto setObject:[feed objectForKey:@"caption"] forKey:ID_PHOTO_CAPTION];
    [dicPhoto setObject:[feed objectForKey:@"fullimage_path"] forKey:ID_PHOTO_URL];
    [dicPhoto setObject:[feed objectForKey:@"post_type"] forKey:POSTTYPE];
    [dicPhoto setObject:[feed objectForKey:@"url_link"] forKey:@"url_link"];

    
    [self gotoPhotoDetail:dicPhoto];
}



#pragma mark -
-(void) onQuizStartButton:(UIButton*) sender
{
    int tag = (int)sender.tag - BTN_START_ID;
    
    NSDictionary * dic = [self.arrTableList objectAtIndex:tag];
    
    BOOL bAnswered = [[dic objectForKey:@"answered"] boolValue];
    if (bAnswered) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"NOTE"
                                                        message: @"You've already answered this quiz."
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString * post_type = [dic objectForKey:@"post_type"];
    if ([post_type isEqualToString:@"poll"]) {
        PollsController * pController = [[PollsController alloc] initWithData:dic];
        [super onPush:pController];
    }
    else {
        //        QuizCheckController * pController = [[QuizCheckController alloc] initWithData:dic];
        QuizController * pController = [[QuizController alloc] initWithData:dic];
        [super onPush:pController];
    }
}
-(void) onApprovePublish:(UIButton*) btn
{
    m_nIndexShare = (int)btn.tag - BTN_FACEBOOK_ID;
    
    UIActionSheet* action;
    
    if ([Global getUserType] != FAN) { //admin
//        action = [[UIActionSheet alloc] initWithTitle:@"Do you want to publish this feed?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Publish", nil];
        
        [self publishFeed];
        
    } else {
        action = [[UIActionSheet alloc] initWithTitle:@"Do you want to approve this feed?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Approve", nil];
    }
    action.tag = 1300;
    [action showInView:[self.view window]];

}
-(void) approveFeed
{
    NSDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexShare];
    
    BOOL did_approve = [feed[@"did_approve"] boolValue];
    
    if (did_approve) {
        [super showMessage:@"" message:@"You have already approved this Post" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    [self showLoading:@"Draft approved."];

    [NSThread detachNewThreadSelector: @selector(approveServer:) toTarget:self withObject:feed];
}
-(void) approveServer:(NSMutableDictionary*) feed
{
    NSString * postType = [feed objectForKey:@"post_type"];
    NSString * contentId = [feed objectForKey:@"content_id"];
    
    NSString * urlString = [MyUrl setApprove:postType contentId:contentId like:1];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            [super hideLoading];
            
            int numbersofapproval = [[result objectForKey:@"numbersofapproval"] intValue];
            
            [feed setObject:[NSNumber numberWithInt:numbersofapproval] forKey:@"numberofapproval"];
            [feed setObject:[NSNumber numberWithInt:1] forKey:@"did_approve"];
            
            [self.arrTableList replaceObjectAtIndex:m_nIndexShare withObject:feed];
            
            [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
            
            int i = 0 ;
            for (i = 0 ; i < (int)[self.arrAllTableList count] ; i ++) {
                NSDictionary * _dic = [self.arrAllTableList objectAtIndex:i];
                NSString * cId = [_dic objectForKey:@"content_id"];
                if ([cId isEqualToString:contentId]) {
                    break;
                }
            }
            
            [self.arrAllTableList replaceObjectAtIndex:i withObject:feed];
            
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

-(void) publishFeed
{
    NSDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexShare];
//    NSString* postType = [feed objectForKey:@"post_type"];

    PublishFeedController * pController = [[PublishFeedController alloc] initWithFeed:feed];
    pController.delegate = self;
    
    [super onPush:pController];
}

-(void)setPublished
{
    m_nPage = 1;
    [self getFeedDatas];
}

-(void) onDraftUser:(UIGestureRecognizer*) gesture
{
    UILabel * label = (UILabel*) gesture.view;
    int tag = (int)label.tag - BTN_LIKE_LIST_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:tag];
    
    LikeListController * pController = [[LikeListController alloc] initWithFeedForDraft:feed];
    [self onPush:pController];
}
-(void) onDraftUser2:(UIButton*) btn
{
    int tag = (int)btn.tag - BTN_LIKE_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:tag];
    
    LikeListController * pController = [[LikeListController alloc] initWithFeedForDraft:feed];
    [self onPush:pController];
}


//-(void) onShare:(UIButton*) btn
//{
//    m_nIndexShare = (int)btn.tag - BTN_FACEBOOK_ID;
//    
//    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", nil];
//    action.tag = 1800;
//    [action showInView:[self.view window]];
//}

-(void) onMsgUser:(UITapGestureRecognizer*) gesture {
    UILabel * label = (UILabel*) gesture.view;
    int tag = (int)label.tag - BTN_MSG_USER_ID;

    int feedId = tag / 3;
    int ncommentId = tag % 3;

    NSDictionary * feed = [self.arrTableList objectAtIndex:feedId];
    
    NSArray * arrcomments = [feed objectForKey:@"comments"];
    if (arrcomments == nil || [arrcomments count] == 0) {
        return;
    }
    
    NSDictionary * oneComment = [arrcomments objectAtIndex:ncommentId];
    int userId = [[oneComment objectForKey:@"user_id"] intValue];
    
    NSString * type = [oneComment objectForKey:@"admin_type"];
    if (type == nil || (NSString *)[NSNull null] == type || [type isEqualToString:@""] ) {
        [super gotoFanDetail:[NSString stringWithFormat:@"%d", userId]];
    }
}
-(void) onMore:(UIButton*) sender
{
    int tag = (int)sender.tag - BTN_MORE_ID;
    m_nIndexDel = tag;
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
    action.tag = 1988;
    [action showInView:[self.view window]];
}

-(void) deleteServer
{
    NSDictionary *feed = [self.arrTableList objectAtIndex:m_nIndexDel];
    
    NSString * postType = [feed objectForKey:@"post_type"];
    NSString * contentId = [feed objectForKey:@"content_id"];
    
    NSString * urlResult = [MyUrl getDeleteFeed:postType :contentId];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            [self performSelectorOnMainThread:@selector(doneDeleteServer:) withObject:feed waitUntilDone:YES];
            
            return;
        }
    }
    
}
-(void) doneDeleteServer:(NSDictionary*)feed
{
    [self.arrTableList removeObjectAtIndex:m_nIndexDel];

    [self doneLoadingTableViewData];
    
    [self.arrAllTableList removeObject:feed];
}

-(void) getAdminServer:(NSDictionary*) feed
{
    NSString * urlResult = [MyUrl getAdminList];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
        
            NSArray * arrResult = [result objectForKey:@"admins"];
            
            NSMutableArray * arrEmail = [[NSMutableArray alloc] init];
            for (NSDictionary* dic in arrResult) {
                [arrEmail addObject:[dic objectForKey:@"email"]];
            }
            
            
            NSString* postType = [feed objectForKey:@"post_type"];
            
            NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:m_nIndexDel inSection:self.m_nNumOfSection-1];
            
            int feedType = TYPE_PHOTO;
            postType = [postType lowercaseString];
            
            if ([postType rangeOfString:@"text"].location != NSNotFound) {
                feedType = TYPE_TEXT;
            }
            
            UIImage * imagePhoto = NULL;
            if (feedType == TYPE_TEXT) {
                imagePhoto = nil;
            } else {
                FeedImageCell *cell = (FeedImageCell*)[self.mTableView cellForRowAtIndexPath:nowIndex];
                imagePhoto = cell.imgPhoto.image;
            }
            
            NSString * text = [feed objectForKey:@"caption"];
            
            [super onReportEmail:arrEmail content:text image:imagePhoto];
            
        }
    }
}


#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section == 0) {
//        return 1;
//    }
//    else {
//        return [self.arrTableList count];
//    }
    
    return [self.arrTableList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (indexPath.section == 0) {
//        return 160;
//    }
//    else
    {
        int height = HEIGHT_HEADER;
        
        NSDictionary * feed = [self.arrTableList objectAtIndex:indexPath.row];
        
        int feedType = TYPE_TEXT;
        NSString * postType = [[feed objectForKey:@"post_type"] lowercaseString];
        if ([postType rangeOfString:@"photo"].location != NSNotFound) {
            feedType = TYPE_PHOTO;
        } else if ([postType rangeOfString:@"video"].location != NSNotFound) {
            feedType = TYPE_VIDEO;
        } else if ([postType rangeOfString:@"text"].location != NSNotFound) {
            feedType = TYPE_TEXT;
        } else if ([postType rangeOfString:@"banner"].location != NSNotFound) {
            return HEIGHT_BANNER + HEIGHT_SPACE;
        } else {
            feedType = TYPE_QUIZ;
        }
 
        
        UILabel * labelText = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_POS_X, 0, TITLE_WIDTH, 50)];
        labelText.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
        labelText.text = [feed objectForKey:@"caption"];
        labelText.numberOfLines = 0;
        [labelText sizeToFit];
        
        int textHeight = TITLE_MARGIN*2 + labelText.frame.size.height;
        
        
        if (feedType == TYPE_TEXT) {
            int nCreditWant = [[feed objectForKey:@"credit"] intValue];
            BOOL bUnlocked = [[feed objectForKey:@"unlock"] boolValue];
            
            if (nCreditWant == 0 || bUnlocked) {
                height += textHeight;
            } else {
                height += HEIGHT_IMAGE;
            }
        }
        else if (feedType == TYPE_QUIZ) {
            height += HEIGHT_IMAGE;
        }
        else {
            
            height += textHeight;

            NSString * sW = [feed objectForKey:@"img_width"];
            NSString * sH = [feed objectForKey:@"img_height"];
            
            if ((NSString *)[NSNull null] != sW && (NSString *)[NSNull null] != sH) {
                int _width, _height;
                _width = [sW intValue];
                _height = [sH intValue];

                int realHeight = (FULL_WIDTH * _height / _width);
                height += realHeight; //HEIGHT_IMAGE;
            }
            else {
                height += HEIGHT_IMAGE;
            }
            
        }
        
        // message
        NSArray * arrMsg = [feed objectForKey:@"comments"];
        if ([arrMsg count] >= 3) {
            height += HEIGHT_MSG_ONE * 3 + HEIGHT_MSG_OFFSET*2;
        }
        else {
            if ([arrMsg count] != 0) {
                height += (HEIGHT_MSG_ONE * [arrMsg count]) + HEIGHT_MSG_OFFSET*2;
            }
            else {
                if (feedType == TYPE_TEXT) {
                    height += 5;
                }
            }
        }
        
        height += HEIGHT_SHARE + HEIGHT_SPACE;
        
        return height;
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == 0) {
//        static NSString *CellIdentifier = @"CellIdentifier";
//        UIImageView * imv = nil;
//        
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//            
//            imv = (UIImageView*) [cell.contentView viewWithTag:1000+indexPath.row];
//            if(imv == nil)
//            {
//                imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
//                [imv setImage:[UIImage imageNamed:@"draftview_logo"]];
//                imv.tag = 1000 + indexPath.row;
//                [cell.contentView addSubview:imv];
//            }
//            
//        }
//        
//        return cell;
//        
//    }
//    else if (indexPath.section == 1) {
    {
        NSDictionary * feed = [self.arrTableList objectAtIndex:indexPath.row];
        
        int feedType = TYPE_TEXT;
        NSString * postType = [[feed objectForKey:@"post_type"] lowercaseString];
        if ([postType rangeOfString:@"photo"].location != NSNotFound) {
            feedType = TYPE_PHOTO;
        } else if ([postType rangeOfString:@"video"].location != NSNotFound) {
            feedType = TYPE_VIDEO;
        } else if ([postType rangeOfString:@"text"].location != NSNotFound) {
            feedType = TYPE_TEXT;
        } else if ([postType rangeOfString:@"banner"].location != NSNotFound) {
            feedType = TYPE_BANNER;
        } else {
            feedType = TYPE_QUIZ;
        }
        
        if (feedType == TYPE_BANNER) {
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
                        bannerView.adUnitID = ADMOB_HOME_ID_1;
                    } else if (nId % 3 == 1) {
                        bannerView.adUnitID = ADMOB_HOME_ID_2;
                    } else {
                        bannerView.adUnitID = ADMOB_HOME_ID_3;
                    }
                    
                    bannerView.rootViewController = self;
                    
                    bannerView.tag = indexPath.row + BANNER_ID;

                    // Initiate a generic request to load it with an ad.
                    GADRequest *request = [GADRequest request];
                    request.testDevices = [NSArray arrayWithObjects:
                                           GAD_SIMULATOR_ID,
                                           nil];
                    [bannerView loadRequest:request];

                    [cell addSubview:bannerView];
                }
            }


            return cell;
        }
        else if (feedType == TYPE_PHOTO || feedType == TYPE_VIDEO) {
            static NSString *CellIdentifier = @"FeedImageCell";
            
            FeedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

            if (cell == nil) {
                UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FeedImageCell" bundle:nil];
                cell = (FeedImageCell*) viewController.view;

//                if ([Global getUserType] == FAN) { //fan
//                    UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FeedImageCell" bundle:nil];
//                    cell = (FeedImageCell*) viewController.view;
//                }
//                else {
//                    UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FanFeedImageCell" bundle:nil];
//                    cell =(FanFeedImageCell*) viewController.view;
//                }
            }
            
            // Configure the cell.
            
//            cell.viewUser.tag = BTN_USER_ID + indexPath.row;
//            cell.viewUser.userInteractionEnabled = YES;
//            UITapGestureRecognizer * tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserDetail:)];
//            tapGestureUser.numberOfTapsRequired = 1;
//            [cell.viewUser addGestureRecognizer:tapGestureUser];
            
            
            
            NSString * starImageUrl = [self.starInfo objectForKey:@"img_url"];
            if (starImageUrl == nil || starImageUrl.length < 1) {
                UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"]  circleImageWithSize:cell.imgAvatar.frame.size.width];
                [cell.imgAvatar setImage:image];
            }
            else {
                [DLImageLoader loadImageFromURL:starImageUrl
                                      completed:^(NSError *error, NSData *imgData) {
                                          if (error == nil) {
                                              // if we have no errors
                                              UIImage * image = [[UIImage imageWithData:imgData]  circleImageWithSize:cell.imgAvatar.frame.size.width];
                                              [cell.imgAvatar setImage:image];
                                          }
                                      }];
            }

            cell.lbUserName.text = [self.starInfo objectForKey:@"name"];
            
            
            NSDate *dateSent = [NSDate dateWithTimeIntervalSince1970:[[feed objectForKey:@"time_stamp"] doubleValue]];
            cell.lbTimeStamp.text = [dateSent timeAgoFull];
            
            int approvalNum = [[feed objectForKey:@"numberofapproval"] intValue];
            int approvalAll = [[feed objectForKey:@"numberofdraftuser"] intValue];
            
            cell.lbLikeNum.text = [NSString stringWithFormat:@"%d", approvalNum];
            cell.lbLikeNum.tag = BTN_LIKE_LIST_ID + indexPath.row;
            cell.lbLikeNum.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDraftUser:)];
            tapGestureLike.numberOfTapsRequired = 1;
            [cell.lbLikeNum addGestureRecognizer:tapGestureLike];
            
            
            cell.btnLike.tag = BTN_LIKE_ID + indexPath.row;
            if (approvalNum == 0) {
                [cell.btnLike setImage:[UIImage imageNamed:@"star_red.png"] forState:UIControlStateNormal];
            } else if (approvalNum < approvalAll) {
                [cell.btnLike setImage:[UIImage imageNamed:@"star_yellow.png"] forState:UIControlStateNormal];
            } else if (approvalNum == approvalAll){
                [cell.btnLike setImage:[UIImage imageNamed:@"star_green.png"] forState:UIControlStateNormal];
            } else {
                [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_nor.png"] forState:UIControlStateNormal];
            }
            [cell.btnLike addTarget:self action:@selector(onDraftUser2:) forControlEvents:UIControlEventTouchUpInside];
            
//            BOOL didLike = [[feed objectForKey:@"did_like"] boolValue];s
//            [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateSelected];
//            [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateHighlighted];
//            [cell.btnLike setSelected:didLike];
//            [cell.btnLike addTarget:self action:@selector(onApproveButton:) forControlEvents:UIControlEventTouchUpInside];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            cell.lbTitle.frame = CGRectMake(TITLE_POS_X, TITLE_MARGIN+HEIGHT_HEADER, TITLE_WIDTH, 34);
            cell.lbTitle.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
            cell.lbTitle.text = [feed objectForKey:@"caption"];
            cell.lbTitle.numberOfLines = 0;
            [cell.lbTitle sizeToFit];

            cell.imgPhoto.tag = BTN_PHOTO_ID + indexPath.row;
            cell.imgPhoto.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGesturePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoDetail:)];
            tapGesturePhoto.numberOfTapsRequired = 1;
            UITapGestureRecognizer * tapGestureVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoDetail:)];
            tapGestureVideo.numberOfTapsRequired = 1;
            if (feedType == TYPE_PHOTO) {
                [cell.imgPhoto addGestureRecognizer:tapGesturePhoto];
            } else {
                [cell.imgPhoto addGestureRecognizer:tapGestureVideo];
            }
            
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
//            cell.imgPhoto.frame = CGRectMake(cell.imgPhoto.frame.origin.x, cell.imgPhoto.frame.origin.y,
//                                             FULL_WIDTH, height);
            cell.imgPhoto.frame = CGRectMake(cell.imgPhoto.frame.origin.x, HEIGHT_HEADER+TITLE_MARGIN*2+cell.lbTitle.frame.size.height,
                                             FULL_WIDTH, height);

            [cell.imgPhoto setImage:nil];
            NSString * imageUrl = [feed objectForKey:@"image_path"];
            [DLImageLoader loadImageFromURL:imageUrl
                                  completed:^(NSError *error, NSData *imgData) {
                                      if (error == nil) {
                                          // if we have no errors
                                          UIImage * image = [UIImage imageWithData:imgData];
                                          [cell.imgPhoto setImage:image];
                                      }
                                  }];
            
            
            cell.viewLock.frame = cell.imgPhoto.frame;
            cell.viewLock.tag = BTN_LOCK_ID + indexPath.row;
            cell.viewLock.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoLock:)];
            tapGestureLock.numberOfTapsRequired = 1;
            [cell.viewLock addGestureRecognizer:tapGestureLock];

            
            if (feedType == TYPE_VIDEO) {
                cell.ivVideoIcon.hidden = NO;
                cell.ivVideoIcon.center = CGPointMake(cell.imgPhoto.frame.size.width/2,
                                                      cell.imgPhoto.frame.origin.y + cell.imgPhoto.frame.size.height/2);
            } else {
                cell.ivVideoIcon.hidden = YES;
            }

            
            
            
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
                [cell.imgLockIcon setImage:[UIImage imageNamed:@"lock_key.png"]];
                cell.imgPremium.hidden = YES;
                
                [cell.btnLike setEnabled:NO];
                [cell.btnComment setEnabled:NO];
                [cell.btnAddComment setEnabled:NO];
                [cell.btnShare setEnabled:NO];
                cell.lbLikeNum.userInteractionEnabled = NO;
            }
            
            // draft video
            if (feedType == TYPE_VIDEO) {
                NSString * is_publish = feed[@"is_publish"];

                if ([is_publish isEqualToString:@"0"]) {
                    cell.ivVideoIcon.hidden = YES;
                    
                    cell.viewLock.hidden = NO;
                    [cell.imgLockIcon setImage:[UIImage imageNamed:@"draft_icon.png"]];
                    cell.lbLockNum.text = @"Processing Video...";
                    cell.imgPremium.hidden = YES;
                    
                    [cell.btnLike setEnabled:NO];
                    [cell.btnComment setEnabled:NO];
                    [cell.btnAddComment setEnabled:NO];
                    [cell.btnShare setEnabled:NO];
                    cell.lbLikeNum.userInteractionEnabled = NO;
                    
                    cell.viewLock.userInteractionEnabled = NO;
                }
            }
            
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            NSArray * arrMsg = [feed objectForKey:@"comments"];
            
            int nComment = [[feed objectForKey:@"comments_count"] intValue];
            NSString * sComment = @"";
            if (nComment == 1) {
                sComment = [NSString stringWithFormat:@"%d Comment", nComment];
            } else if (nComment > 1) {
                sComment = [NSString stringWithFormat:@"%d Comments", nComment];
            } else {
                sComment = @"No Comments";
            }
            cell.lbComment.text = sComment;
            
            cell.ivMessage1.hidden = YES;
            cell.lbMessage1.hidden = YES;
            cell.lbMsgTimeStamp1.hidden = YES;
            cell.ivMessage2.hidden = YES;
            cell.lbMessage2.hidden = YES;
            cell.lbMsgTimeStamp2.hidden = YES;
            cell.ivMessage3.hidden = YES;
            cell.lbMessage3.hidden = YES;
            cell.lbMsgTimeStamp3.hidden = YES;
            
            int k = 0;
            if ([arrMsg count] != 0) {
                NSString * strMsgName = @""; //[NSString stringWithFormat:@"%@  ", @"Michael"];
                NSString * strMsgText = @"I love you";
                NSString * strMsgTime = @"1d";

                for (int i = 0 ; i < (int)[arrMsg count]; i ++) {
                    if (i>2)
                        break;
                    
                    NSDictionary * lastMsg = [arrMsg objectAtIndex:i];
                    
                    strMsgName = [NSString stringWithFormat:@"%@  ", [lastMsg objectForKey:@"name"]];
                    strMsgText = [lastMsg objectForKey:@"comment"];
                    
                    NSDate *dateSentMsg = [NSDate dateWithTimeIntervalSince1970:[[lastMsg objectForKey:@"time_stamp"] doubleValue]];
                    strMsgTime = [dateSentMsg timeAgo];
                    
                    
                    UIFont *boldFont = [UIFont fontWithName:FONT_NAME_BOLD size:13.0];
                    NSDictionary *arialdict = [NSDictionary dictionaryWithObject: boldFont forKey:NSFontAttributeName];
                    NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:strMsgName attributes: arialdict];
                    [AattrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, strMsgName.length))];
                    
                    UIFont *lightFont = [UIFont fontWithName:FONT_NAME size:13.0];
                    NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:lightFont forKey:NSFontAttributeName];
                    NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc] initWithString: strMsgText attributes:veradnadict];
                    [VattrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f]
                                        range:(NSMakeRange(0, strMsgText.length))];
                    
                    [AattrString appendAttributedString:VattrString];
                    
                    if (k == 0) {
                        cell.lbMessage1.attributedText = AattrString;
                        cell.lbMessage1.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage1.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage1 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp1.text = strMsgTime;
                        
                        cell.ivMessage1.hidden = NO;
                        cell.lbMessage1.hidden = NO;
                        cell.lbMsgTimeStamp1.hidden = NO;
                    }
                    else if (k == 1) {
                        cell.lbMessage2.attributedText = AattrString;
                        cell.lbMessage2.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage2.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage2 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp2.text = strMsgTime;
                        
                        cell.ivMessage2.hidden = NO;
                        cell.lbMessage2.hidden = NO;
                        cell.lbMsgTimeStamp2.hidden = NO;
                    }
                    else if (k == 2) {
                        cell.lbMessage3.attributedText = AattrString;
                        cell.lbMessage3.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage3.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage3 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp3.text = strMsgTime;

                        cell.ivMessage3.hidden = NO;
                        cell.lbMessage3.hidden = NO;
                        cell.lbMsgTimeStamp3.hidden = NO;
                    }
                    k++;
                }

            }
            
            int nHeightMsg = 0;
            if (k != 0) {
                nHeightMsg = HEIGHT_MSG_ONE * k + HEIGHT_MSG_OFFSET*2;
            }
            cell.viewMsg.frame = CGRectMake(cell.viewMsg.frame.origin.x,
                                            cell.frame.size.height - HEIGHT_SPACE-HEIGHT_SHARE - nHeightMsg,
                                            cell.viewMsg.frame.size.width,
                                            nHeightMsg);
            
            

            cell.btnComment.tag = BTN_COMMENT_ID + indexPath.row;
            [cell.btnComment addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];

            cell.btnAddComment.tag = BTN_ADD_COMMENT_ID + indexPath.row;
            [cell.btnAddComment addTarget:self action:@selector(onAddComment:) forControlEvents:UIControlEventTouchUpInside];

            cell.btnShare.tag = BTN_FACEBOOK_ID + indexPath.row;
            [cell.btnShare addTarget:self action:@selector(onApprovePublish:) forControlEvents:UIControlEventTouchUpInside];

//            if ([Global getUserType] != FAN) { // fan more
//                cell.btnMore.tag = BTN_MORE_ID + indexPath.row;
//                [cell.btnMore addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
//                
//                if (nCreditWant == 0 || bUnlocked) {
//                    [cell.btnMore setEnabled:YES];
//                } else {
//                    [cell.btnMore setEnabled:NO];
//                }
//            }
            cell.ivShareIcon.hidden = YES;
            cell.lbApprove.hidden = NO;
            if ([Global getUserType] != FAN) { // fan more
                cell.lbApprove.text = @"Publish";
            } else {
                cell.lbApprove.text = @"Approve";
            }
            
            return cell;
        }
        else if (feedType == TYPE_TEXT) {
            
            static NSString *CellIdentifier = @"FeedTextCell";
            
            FeedTextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FeedTextCell" bundle:nil];
                cell =(FeedTextCell*) viewController.view;
                
//                if ([Global getUserType] == FAN) { // fan more
//                    UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FeedTextCell" bundle:nil];
//                    cell =(FeedTextCell*) viewController.view;
//                }
//                else {
//                    UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FanFeedTextCell" bundle:nil];
//                    cell =(FanFeedTextCell*) viewController.view;
//                }
            }
            
            // Configure the cell.
            
//            cell.viewUser.tag = BTN_USER_ID + indexPath.row;
//            cell.viewUser.userInteractionEnabled = YES;
//            UITapGestureRecognizer * tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserDetail:)];
//            tapGestureUser.numberOfTapsRequired = 1;
//            [cell.viewUser addGestureRecognizer:tapGestureUser];
            
            NSString * starImageUrl = [self.starInfo objectForKey:@"img_url"];
            if (starImageUrl == nil || starImageUrl.length < 1) {
                UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"]  circleImageWithSize:cell.imgAvatar.frame.size.width];
                [cell.imgAvatar setImage:image];
            }
            else {
                [DLImageLoader loadImageFromURL:starImageUrl
                                      completed:^(NSError *error, NSData *imgData) {
                                          if (error == nil) {
                                              // if we have no errors
                                              UIImage * image = [[UIImage imageWithData:imgData]  circleImageWithSize:cell.imgAvatar.frame.size.width];
                                              [cell.imgAvatar setImage:image];
                                          }
                                      }];
            }
            
            cell.lbUserName.text = [self.starInfo objectForKey:@"name"];

            NSDate *dateSent = [NSDate dateWithTimeIntervalSince1970:[[feed objectForKey:@"time_stamp"] doubleValue]];
            cell.lbTimeStamp.text = [dateSent timeAgoFull];
            
            int approvalNum = [[feed objectForKey:@"numberofapproval"] intValue];
            int approvalAll = [[feed objectForKey:@"numberofdraftuser"] intValue];
            
            cell.lbLikeNum.text = [NSString stringWithFormat:@"%d", approvalNum];
            cell.lbLikeNum.tag = BTN_LIKE_LIST_ID + indexPath.row;
            cell.lbLikeNum.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDraftUser:)];
            tapGestureLike.numberOfTapsRequired = 1;
            [cell.lbLikeNum addGestureRecognizer:tapGestureLike];
            
            
            cell.btnLike.tag = BTN_LIKE_ID + indexPath.row;
            if (approvalNum == 0) {
                [cell.btnLike setImage:[UIImage imageNamed:@"star_red.png"] forState:UIControlStateNormal];
            } else if (approvalNum < approvalAll) {
                [cell.btnLike setImage:[UIImage imageNamed:@"star_yellow.png"] forState:UIControlStateNormal];
            } else if (approvalNum == approvalAll){
                [cell.btnLike setImage:[UIImage imageNamed:@"star_green.png"] forState:UIControlStateNormal];
            } else {
                [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_nor.png"] forState:UIControlStateNormal];
            }
            [cell.btnLike addTarget:self action:@selector(onDraftUser2:) forControlEvents:UIControlEventTouchUpInside];
            
            //            BOOL didLike = [[feed objectForKey:@"did_like"] boolValue];s
            //            [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateSelected];
            //            [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateHighlighted];
            //            [cell.btnLike setSelected:didLike];
            //            [cell.btnLike addTarget:self action:@selector(onApproveButton:) forControlEvents:UIControlEventTouchUpInside];
            
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            cell.lbText.frame = CGRectMake(TITLE_POS_X, TITLE_MARGIN+HEIGHT_HEADER, TITLE_WIDTH, 34);
            cell.lbText.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
            cell.lbText.text = [feed objectForKey:@"caption"];
            cell.lbText.numberOfLines = 0;
            [cell.lbText sizeToFit];
            
            cell.viewLock.frame = CGRectMake(0, HEIGHT_HEADER, FULL_WIDTH, HEIGHT_IMAGE);
            cell.viewLock.tag = BTN_LOCK_ID + indexPath.row;
            cell.viewLock.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoLock:)];
            tapGestureLock.numberOfTapsRequired = 1;
            [cell.viewLock addGestureRecognizer:tapGestureLock];
            
            
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            NSArray * arrMsg = [feed objectForKey:@"comments"];
            
            int nComment = [[feed objectForKey:@"comments_count"] intValue];
            NSString * sComment = @"";
            if (nComment == 1) {
                sComment = [NSString stringWithFormat:@"%d Comment", nComment];
            } else if (nComment > 1) {
                sComment = [NSString stringWithFormat:@"%d Comments", nComment];
            } else {
                sComment = @"No Comments";
            }
            cell.lbComment.text = sComment;
            cell.ivMessage1.hidden = YES;
            cell.lbMessage1.hidden = YES;
            cell.lbMsgTimeStamp1.hidden = YES;
            cell.ivMessage2.hidden = YES;
            cell.lbMessage2.hidden = YES;
            cell.lbMsgTimeStamp2.hidden = YES;
            cell.ivMessage3.hidden = YES;
            cell.lbMessage3.hidden = YES;
            cell.lbMsgTimeStamp3.hidden = YES;
            
            int k = 0;
            if ([arrMsg count] != 0) {
                NSString * strMsgName = @""; //[NSString stringWithFormat:@"%@  ", @"Michael"];
                NSString * strMsgText = @"Test Msg";
                NSString * strMsgTime = @"1d";
                
                for (int i = 0 ; i < (int)[arrMsg count]; i ++) {
                    if (i>2)
                        break;
                    
                    NSDictionary * lastMsg = [arrMsg objectAtIndex:i];
                    
                    strMsgName = [NSString stringWithFormat:@"%@  ", [lastMsg objectForKey:@"name"]];
                    strMsgText = [lastMsg objectForKey:@"comment"];
                    
                    NSDate *dateSentMsg = [NSDate dateWithTimeIntervalSince1970:[[lastMsg objectForKey:@"time_stamp"] doubleValue]];
                    strMsgTime = [dateSentMsg timeAgo];
                    
                    
                    UIFont *boldFont = [UIFont fontWithName:FONT_NAME_BOLD size:13.0];
                    NSDictionary *arialdict = [NSDictionary dictionaryWithObject: boldFont forKey:NSFontAttributeName];
                    NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:strMsgName attributes: arialdict];
                    [AattrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, strMsgName.length))];
                    
                    UIFont *lightFont = [UIFont fontWithName:FONT_NAME size:13.0];
                    NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:lightFont forKey:NSFontAttributeName];
                    NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc] initWithString: strMsgText attributes:veradnadict];
                    [VattrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f]
                                        range:(NSMakeRange(0, strMsgText.length))];
                    
                    [AattrString appendAttributedString:VattrString];
                    
                    if (k == 0) {
                        cell.lbMessage1.attributedText = AattrString;
                        cell.lbMessage1.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage1.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage1 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp1.text = strMsgTime;
                        
                        cell.ivMessage1.hidden = NO;
                        cell.lbMessage1.hidden = NO;
                        cell.lbMsgTimeStamp1.hidden = NO;
                    }
                    else if (k == 1) {
                        cell.lbMessage2.attributedText = AattrString;
                        cell.lbMessage2.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage2.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage2 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp2.text = strMsgTime;
                        
                        cell.ivMessage2.hidden = NO;
                        cell.lbMessage2.hidden = NO;
                        cell.lbMsgTimeStamp2.hidden = NO;
                    }
                    else if (k == 2) {
                        cell.lbMessage3.attributedText = AattrString;
                        cell.lbMessage3.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage3.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage3 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp3.text = strMsgTime;
                        
                        cell.ivMessage3.hidden = NO;
                        cell.lbMessage3.hidden = NO;
                        cell.lbMsgTimeStamp3.hidden = NO;
                    }
                    k++;
                }
                
            }
            
            int nHeightMsg = 0;
            if (k != 0) {
                nHeightMsg = HEIGHT_MSG_ONE * k + HEIGHT_MSG_OFFSET*2;
            }
            cell.viewMsg.frame = CGRectMake(cell.viewMsg.frame.origin.x,
                                            cell.frame.size.height - HEIGHT_SPACE-HEIGHT_SHARE - nHeightMsg,
                                            cell.viewMsg.frame.size.width,
                                            nHeightMsg);
            

            
            cell.btnComment.tag = BTN_COMMENT_ID + indexPath.row;
            [cell.btnComment addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnAddComment.tag = BTN_ADD_COMMENT_ID + indexPath.row;
            [cell.btnAddComment addTarget:self action:@selector(onAddComment:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnShare.tag = BTN_FACEBOOK_ID + indexPath.row;
            [cell.btnShare addTarget:self action:@selector(onApprovePublish:) forControlEvents:UIControlEventTouchUpInside];

//            if ([Global getUserType] != FAN) { // fan more
//                cell.btnMore.tag = BTN_MORE_ID + indexPath.row;
//                [cell.btnMore addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
//                
//                if (nCreditWant == 0 || bUnlocked) {
//                    [cell.btnMore setEnabled:YES];
//                } else {
//                    [cell.btnMore setEnabled:NO];
//                }
//
//            }
            cell.ivShareIcon.hidden = YES;
            cell.lbApprove.hidden = NO;
            if ([Global getUserType] != FAN) { // fan more
                cell.lbApprove.text = @"Publish";
            } else {
                cell.lbApprove.text = @"Approve";
            }

            
            return cell;
        }
        else if (feedType == TYPE_QUIZ) {
            static NSString *CellIdentifier = @"FeedQuizCell";
            
            FeedQuizCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FeedQuizCell" bundle:nil];
                cell =(FeedQuizCell*) viewController.view;
            }
            
            
            NSString * starImageUrl = [self.starInfo objectForKey:@"img_url"];
            [DLImageLoader loadImageFromURL:starImageUrl
                                  completed:^(NSError *error, NSData *imgData) {
                                      if (error == nil) {
                                          // if we have no errors
                                          UIImage * image = [[UIImage imageWithData:imgData]  circleImageWithSize:cell.imgAvatar.frame.size.width];
                                          [cell.imgAvatar setImage:image];
                                      }
                                  }];
            
            cell.lbUserName.text = [self.starInfo objectForKey:@"name"];
            
            NSDate *dateSent = [NSDate dateWithTimeIntervalSince1970:[[feed objectForKey:@"time_stamp"] doubleValue]];
            cell.lbTimeStamp.text = [dateSent timeAgoFull];
            
            int approvalNum = [[feed objectForKey:@"numberofapproval"] intValue];
            int approvalAll = [[feed objectForKey:@"numberofdraftuser"] intValue];
            
            cell.lbLikeNum.text = [NSString stringWithFormat:@"%d", approvalNum];
            cell.lbLikeNum.tag = BTN_LIKE_LIST_ID + indexPath.row;
            cell.lbLikeNum.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDraftUser:)];
            tapGestureLike.numberOfTapsRequired = 1;
            [cell.lbLikeNum addGestureRecognizer:tapGestureLike];
            
            
            cell.btnLike.tag = BTN_LIKE_ID + indexPath.row;
            if (approvalNum == 0) {
                [cell.btnLike setImage:[UIImage imageNamed:@"star_red.png"] forState:UIControlStateNormal];
            } else if (approvalNum < approvalAll) {
                [cell.btnLike setImage:[UIImage imageNamed:@"star_yellow.png"] forState:UIControlStateNormal];
            } else if (approvalNum == approvalAll){
                [cell.btnLike setImage:[UIImage imageNamed:@"star_green.png"] forState:UIControlStateNormal];
            } else {
                [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_nor.png"] forState:UIControlStateNormal];
            }
            [cell.btnLike addTarget:self action:@selector(onDraftUser2:) forControlEvents:UIControlEventTouchUpInside];
            
            //            BOOL didLike = [[feed objectForKey:@"did_like"] boolValue];s
            //            [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateSelected];
            //            [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateHighlighted];
            //            [cell.btnLike setSelected:didLike];
            //            [cell.btnLike addTarget:self action:@selector(onApproveButton:) forControlEvents:UIControlEventTouchUpInside];
            
            /////////////////////////////////////    QUIZ     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            cell.lbQuizTitle.text = [feed objectForKey:@"caption"];
            cell.lbQuizText.text = [feed objectForKey:@"text"];
            cell.lbQuizText.numberOfLines = 0;
            
            [cell.btnStart addTarget:self action:@selector(onQuizStartButton:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnStart.tag = BTN_START_ID + indexPath.row;
            
            NSString * imageUrl = [feed objectForKey:@"image_path"];
            [DLImageLoader loadImageFromURL:imageUrl
                                  completed:^(NSError *error, NSData *imgData) {
                                      if (error == nil) {
                                          // if we have no errors
                                          UIImage * image = [UIImage imageWithData:imgData];
                                          [cell.imgPhoto setImage:image];
                                      }
                                  }];
            
            
            cell.viewLock.tag = BTN_LOCK_ID + indexPath.row;
            cell.viewLock.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoLock:)];
            tapGestureLock.numberOfTapsRequired = 1;
            [cell.viewLock addGestureRecognizer:tapGestureLock];
            
            
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
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            NSArray * arrMsg = [feed objectForKey:@"comments"];
            
            int nComment = [[feed objectForKey:@"comments_count"] intValue];
            NSString * sComment = @"";
            if (nComment == 1) {
                sComment = [NSString stringWithFormat:@"%d Comment", nComment];
            } else if (nComment > 1) {
                sComment = [NSString stringWithFormat:@"%d Comments", nComment];
            } else {
                sComment = @"No Comments";
            }
            cell.lbComment.text = sComment;
            
            
            cell.ivMessage1.hidden = YES;
            cell.lbMessage1.hidden = YES;
            cell.lbMsgTimeStamp1.hidden = YES;
            cell.ivMessage2.hidden = YES;
            cell.lbMessage2.hidden = YES;
            cell.lbMsgTimeStamp2.hidden = YES;
            cell.ivMessage3.hidden = YES;
            cell.lbMessage3.hidden = YES;
            cell.lbMsgTimeStamp3.hidden = YES;
            
            int k = 0;
            if ([arrMsg count] != 0) {
                NSString * strMsgName = @""; //[NSString stringWithFormat:@"%@  ", @"Michael"];
                NSString * strMsgText = @"Test Msg";
                NSString * strMsgTime = @"1d";
                
                for (int i = 0 ; i < (int)[arrMsg count]; i ++) {
                    if (i>2)
                        break;
                    
                    NSDictionary * lastMsg = [arrMsg objectAtIndex:i];
                    
                    strMsgName = [NSString stringWithFormat:@"%@  ", [lastMsg objectForKey:@"name"]];
                    strMsgText = [lastMsg objectForKey:@"comment"];
                    
                    NSDate *dateSentMsg = [NSDate dateWithTimeIntervalSince1970:[[lastMsg objectForKey:@"time_stamp"] doubleValue]];
                    strMsgTime = [dateSentMsg timeAgo];
                    
                    
                    UIFont *boldFont = [UIFont fontWithName:FONT_NAME_BOLD size:13.0];
                    NSDictionary *arialdict = [NSDictionary dictionaryWithObject: boldFont forKey:NSFontAttributeName];
                    NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:strMsgName attributes: arialdict];
                    [AattrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, strMsgName.length))];
                    
                    UIFont *lightFont = [UIFont fontWithName:FONT_NAME size:13.0];
                    NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:lightFont forKey:NSFontAttributeName];
                    NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc] initWithString: strMsgText attributes:veradnadict];
                    [VattrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f]
                                        range:(NSMakeRange(0, strMsgText.length))];
                    
                    [AattrString appendAttributedString:VattrString];
                    
                    if (k == 0) {
                        cell.lbMessage1.attributedText = AattrString;
                        cell.lbMessage1.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage1.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage1 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp1.text = strMsgTime;
                        
                        cell.ivMessage1.hidden = NO;
                        cell.lbMessage1.hidden = NO;
                        cell.lbMsgTimeStamp1.hidden = NO;
                    }
                    else if (k == 1) {
                        cell.lbMessage2.attributedText = AattrString;
                        cell.lbMessage2.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage2.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage2 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp2.text = strMsgTime;
                        
                        cell.ivMessage2.hidden = NO;
                        cell.lbMessage2.hidden = NO;
                        cell.lbMsgTimeStamp2.hidden = NO;
                    }
                    else if (k == 2) {
                        cell.lbMessage3.attributedText = AattrString;
                        cell.lbMessage3.tag = BTN_MSG_USER_ID + indexPath.row * 3 + k;
                        cell.lbMessage3.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapGestureMsgUsee = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMsgUser:)];
                        tapGestureMsgUsee.numberOfTapsRequired = 1;
                        [cell.lbMessage3 addGestureRecognizer:tapGestureMsgUsee];
                        cell.lbMsgTimeStamp3.text = strMsgTime;
                        
                        cell.ivMessage3.hidden = NO;
                        cell.lbMessage3.hidden = NO;
                        cell.lbMsgTimeStamp3.hidden = NO;
                    }
                    k++;
                }
                
            }
            
            int nHeightMsg = 0;
            if (k != 0) {
                nHeightMsg = HEIGHT_MSG_ONE * k + HEIGHT_MSG_OFFSET*2;
            }
            cell.viewMsg.frame = CGRectMake(cell.viewMsg.frame.origin.x,
                                            cell.frame.size.height - HEIGHT_SPACE-HEIGHT_SHARE - nHeightMsg,
                                            cell.viewMsg.frame.size.width,
                                            nHeightMsg);
            
            cell.btnComment.tag = BTN_COMMENT_ID + indexPath.row;
            [cell.btnComment addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnAddComment.tag = BTN_ADD_COMMENT_ID + indexPath.row;
            [cell.btnAddComment addTarget:self action:@selector(onAddComment:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnShare.tag = BTN_FACEBOOK_ID + indexPath.row;
            [cell.btnShare addTarget:self action:@selector(onApprovePublish:) forControlEvents:UIControlEventTouchUpInside];
            
            
            cell.ivShareIcon.hidden = YES;
            cell.lbApprove.hidden = NO;
            if ([Global getUserType] != FAN) { // fan more
                cell.lbApprove.text = @"Publish";
            } else {
                cell.lbApprove.text = @"Approve";
            }

            return cell;
        }
        
        
        return nil;

    }
    
	return nil;
    
}



@end