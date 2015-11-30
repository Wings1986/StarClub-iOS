//
//  FanDetailController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/30/13.
//
//

#import "FanDetailController.h"
#import "ProfileCell.h"
#import "AddTextController.h"
#import "AddPhotoController.h"
#import "CommentAutoController.h"
#import "SendMsgController.h"
#import "FollowUserController.h"

#import "FanFeedTextCell.h"
#import "FanFeedImageCell.h"

#import "StarTracker.h"



@interface FanDetailController ()<UIActionSheetDelegate, CommentAutoControllerDelegate>
{
//    IBOutlet UILabel * lbUserName;
//    IBOutlet UIButton * btnBack;
    
    int followers;
    int followings;
    
    BOOL did_follow;
    BOOL did_block;
    
    int m_nIndexDel;
}

@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSMutableDictionary * userInfo;

@end

@implementation FanDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithUserID:(NSString *) userId {
    self = [super init];
    if (self) {
        self.userId = userId;
    }
    return self;
}
-(id) initWithUserID:(NSString *) userId withRevealBlock:(RevealBlock)revealBlock{
    self = [super init];
    if (self) {
        _revealBlock = [revealBlock copy];
        self.userId = userId;
    }
    return self;
}

- (void)viewDidLoad
{
    m_bMoreLoad = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [StarTracker StarSendView:@"Fan Detail"];
    
    self.title = @"";
    
    UIButton * btnCancel = [[UIButton alloc] init];
    
    if (_revealBlock != nil) {
        btnCancel.frame = CGRectMake(0, 0, 59, 40);
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"btn_slider_menu.png"] forState:UIControlStateNormal];
    }
    else {
        btnCancel.frame = CGRectMake(0, 0, 50, 40);
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    }
    [btnCancel addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    
    if ([Global getUserType] == FAN) {
        UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [btnEdit setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
        [btnEdit addTarget:self action:@selector(onAddMore) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
        self.navigationItem.rightBarButtonItem = btnItemEdit;
    }
    
    
    self.m_nNumOfSection = 2;
    self.m_nNumOfHeader = 4;
    
//    self.userInfo = [[NSMutableDictionary alloc] init];
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

        m_nPage = 1;
        [self getUserProfile];
    }
    
}


-(IBAction)onClickBack:(id)sender {
    
    if (_revealBlock != nil) {
        [super revealSidebar];
    }
    else {
        [super onBack];
    }
}
-(IBAction)onAddMore{
    
    NSString * strFollow = did_follow ? @"Unfollow" : @"Follow";
    NSString * strBlock = did_block ? @"Unblock User" : @"Block User";
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:strFollow, @"Message", strBlock, nil];
    action.tag = 1900;
    action.destructiveButtonIndex = 2;
    
    [action showInView:[self.view window]];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1800) {
        
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
            FanFeedImageCell *cell = (FanFeedImageCell*)[self.mTableView cellForRowAtIndexPath:nowIndex];
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
    else if (actionSheet.tag == 1900) {
        if (buttonIndex == 0) { // follow
            [self onFollowButton];
        }
        else if (buttonIndex == 2) { // block
            [self onBlock];
        }
        else if (buttonIndex == 1) { // message
            [self onMessage:nil];
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
    
}


- (void) getUserProfile{
    
//    [super showLoading];
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}

-(void) postServer
{
    NSString * urlResult = [MyUrl getUserInfo:self.userId page:m_nPage];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
//            [super hideLoading];
            
            did_follow = [[result objectForKey:@"did_follow"] boolValue];
            did_block = [[result objectForKey:@"did_block"] boolValue];
            
            self.userInfo = [result objectForKey:@"user"];

//            NSArray * arrFollowers = [self.userInfo objectForKey:@"followeds"];
//            followers = (int)[arrFollowers count];
            followers = [[self.userInfo objectForKey:@"followeds"] intValue];
            
//            NSArray * arrFollowings = [self.userInfo objectForKey:@"followings"];
//            followings = (int)[arrFollowings count];
            followings = [[self.userInfo objectForKey:@"followings"] intValue];
            

            self.title = [self.userInfo objectForKey:@"name"];
            
            if (self.arrAllTableList == nil || m_nPage <= 1) {
                self.arrAllTableList = [result objectForKey:@"feeds"];
            }
            else {
                [self.arrAllTableList addObjectsFromArray:[result objectForKey:@"feeds"]];
            }
            
            m_bEnableBanner = [result[@"channel_info"][@"enable_banner_ads_ios"] boolValue];
            m_channel_BrightcoveId = [result[@"channel_info"] objectForKey:@"bc_playerid_ios"];
            m_channelUrl = [result[@"channel_info"] objectForKey:@"url"];
            [super filterFeed];
            
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
    [self getUserProfile];
}
- (void)startMoreLoad
{
    [super startMoreLoad];
    
    [self getUserProfile];
}

- (void) doneLoadingTableViewData {
    [super doneLoadingTableViewData];
}

#pragma mark -
#pragma mark button event ----------
-(void) onComment:(UIButton *)btn
{
    int nIndex = (int)btn.tag - BTN_COMMENT_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:nIndex];
    
    //    [feed setObject:@"Profile_Post" forKey:POSTTYPE];
    //    [feed setObject:[feed objectForKey:@"content_id"] forKey:CONTENTID];
    
    [super onCommentFeed:feed index:nIndex Delegate:self];
}

-(void) commentDone:(int)index comments:(NSArray *)arrComment count:(int)totalComment{
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[self.arrTableList objectAtIndex:index]];
    [dic setObject:arrComment forKey:@"comments"];
    [dic setObject:[NSNumber numberWithInt:totalComment] forKey:@"comments_count"];
    
    [self.arrTableList replaceObjectAtIndex:index withObject:dic];
    
    [self doneLoadingTableViewData];
}


-(void) onAddComment:(UIButton *) btn
{
    int nIndex = (int)btn.tag - BTN_ADD_COMMENT_ID;
    
    NSMutableDictionary * feed = [self.arrTableList objectAtIndex:nIndex];
    
    [super onAddCommentFeed:feed index:nIndex Delegate:self];
}
-(void) addCommentDone
{
//    [self getUserProfile];
}

-(void) onShare:(UIButton*) btn
{
    m_nIndexShare = (int)btn.tag - BTN_FACEBOOK_ID;
    
    NSDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexShare];
    
    PublishFeedController * pController = [[PublishFeedController alloc] initWithShare:feed];
    [super onPush:pController];

//    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", nil];
//    action.tag = 1800;
//    [action showInView:[self.view window]];
}


-(void) onMore:(UIButton*) sender
{
    int tag = (int)sender.tag - BTN_MORE_ID;
    m_nIndexDel = tag;
    
    if ([Global getUserType] != FAN) {
        UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
        action.tag = 1988;
        [action showInView:[self.view window]];
    }
    else {
        UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:nil, nil];
        action.tag = 1977;
        [action showInView:[self.view window]];
    }

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
    
    [self.mTableView reloadData];
    
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
                FanFeedImageCell *cell = (FanFeedImageCell*)[self.mTableView cellForRowAtIndexPath:nowIndex];
                imagePhoto = cell.imgPhoto.image;
            }
            
            NSString * text = [feed objectForKey:@"caption"];
            
            [super onReportEmail:arrEmail content:text image:imagePhoto];
            
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
    [dicPhoto setObject:@"photo" forKey:POSTTYPE];
    [dicPhoto setObject:[feed objectForKey:@"url_link"] forKey:@"url_link"];

    [self gotoPhotoDetail:dicPhoto];
}





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


#pragma mark -
#pragma mark Follow
-(void) onFollowButton
{
    [NSThread detachNewThreadSelector: @selector(postFollowServer) toTarget:self withObject:nil];
}
-(void) postFollowServer {
    
    NSString * urlResult = @"";
    
    NSLog(@"userid = %@", self.userId);
    
    if (did_follow == NO) {
        urlResult = [MyUrl setFollowing:self.userId];
    } else {
        urlResult = [MyUrl setUnFollowing:self.userId];
    }
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            followers = [[result objectForKey:@"numbers"] intValue];
            
            NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:0 inSection:0];
            
            [self performSelectorOnMainThread:@selector(donePostFollwServer:) withObject:nowIndex waitUntilDone:YES];
            
        }
    }

}

-(void) donePostFollwServer:(NSIndexPath*) nowIndex
{
    ProfileCell *cell = (ProfileCell*)[self.mTableView cellForRowAtIndexPath:nowIndex];
    cell.lbFollowers.text = [NSString stringWithFormat:@"%d", followers];
    
    did_follow = !did_follow;
    if (did_follow) {
        [cell.btnAddPost setTitle:@"Unfollow" forState:UIControlStateNormal];
    } else {
        [cell.btnAddPost setTitle:@"Follow" forState:UIControlStateNormal];
    }

}

#pragma mark -
#pragma mark Send Message
-(void) onMessage:(UIButton*) btn
{
    if (did_block) {
        [super showMessage:@"NOTE!" message:@"This user is blocked and You can not send some message." delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    SendMsgController * pController = [[SendMsgController alloc] initWithReceiverId:self.userId userName:[self.userInfo objectForKey:@"name"] message:@""];
    [super onPush:pController];
}


#pragma mark -
#pragma mark Block
-(void) onBlock
{
    [NSThread detachNewThreadSelector: @selector(postBlockServer) toTarget:self withObject:nil];
}
-(void) postBlockServer {
    
    
    NSString * urlResult = @"";
    if (did_block) {
        urlResult = [MyUrl setUnblockFan:self.userId];
    } else {
        urlResult = [MyUrl setBlockFan:self.userId];
    }
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            did_block = !did_block;
        }
    }
    
}

#pragma mark -
#pragma Follower & Following
//-(void) onFollowerUser:(UIButton*) btn
//{
//    
//    NSArray * arrFollowers = [self.userInfo objectForKey:@"followeds"];
//    
//    if (arrFollowers == nil || [arrFollowers count] == 0) {
//        return;
//    }
//    
//    FollowUserController * pController = [[FollowUserController alloc] initWithUserList:arrFollowers title:@"Followers"];
//    [self onPush:pController];
//    
//}
//-(void) onFollowingUser:(UIButton*) btn
//{
//    NSArray * arrFollowings = [self.userInfo objectForKey:@"followings"];
//    
//    if (arrFollowings == nil || [arrFollowings count] == 0) {
//        return;
//    }
//    
//    FollowUserController * pController = [[FollowUserController alloc] initWithUserList:arrFollowings title:@"Following"];
//    [self onPush:pController];
//    
//}

#pragma mark -
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 101;
    }
    else {
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
        height += textHeight;
        
        if (feedType == TYPE_TEXT) {
            
        }
        else {
            
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
    
    if (indexPath.section == 0) {
        
        static NSString *CellIdentifier = @"ProfileCell";
        
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"ProfileCell" bundle:nil];
            cell =(ProfileCell*) viewController.view;
        }
        
        if (self.userInfo == nil) {
            return cell;
        }
        
        NSString * imageUrl = [self.userInfo objectForKey:@"img_url"];
        if (imageUrl == nil || imageUrl.length < 1) {
            UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:cell.imgAvatar.frame.size.width];
            [cell.imgAvatar setImage:image];
        }
        else {
            [DLImageLoader loadImageFromURL:imageUrl
                                  completed:^(NSError *error, NSData *imgData) {
                                      if (error == nil) {
                                          // if we have no errors
                                          UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:cell.imgAvatar.frame.size.width];
                                          [cell.imgAvatar setImage:image];
                                      }
                                      else {
                                          UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:cell.imgAvatar.frame.size.width];
                                          [cell.imgAvatar setImage:image];
                                      }
                                      
                                  }];
        }
        
        cell.lbFollowers.text = [NSString stringWithFormat:@"%d", followers];
//        [cell.btnFollowers addTarget:self action:@selector(onFollowerUser:) forControlEvents:UIControlEventTouchUpInside];

        cell.lbFollowing.text = [NSString stringWithFormat:@"%d", followings];
//        [cell.btnFollowings addTarget:self action:@selector(onFollowingUser:) forControlEvents:UIControlEventTouchUpInside];
        
        
        int point = [[self.userInfo objectForKey:@"point"] intValue];
        cell.lbPoints.text = [NSString stringWithFormat:@"%d", point];
        
        
        [cell.btnAddPost setTitle:(did_follow ? @"UnFollow" : @"Follow") forState:UIControlStateNormal];
        [cell.btnAddPost addTarget:self action:@selector(onFollowButton) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.btnIndex setTitle:@"Message" forState:UIControlStateNormal];
        [cell.btnIndex addTarget:self action:@selector(onMessage:) forControlEvents:UIControlEventTouchUpInside];

        if ([Global getUserType] != FAN) {
            cell.btnAddPost.hidden = YES;
            cell.btnIndex.hidden = YES;
        }
        
        
        return cell;
    }
    
    else if (indexPath.section == 1){
        
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
                        bannerView.adUnitID = ADMOB_COMMUNITY_ID_1;
                    } else if (nId % 3 == 1) {
                        bannerView.adUnitID = ADMOB_COMMUNITY_ID_2;
                    } else {
                        bannerView.adUnitID = ADMOB_COMMUNITY_ID_3;
                    }

                    bannerView.rootViewController = self;
                    
                    bannerView.tag = indexPath.row + BANNER_ID;
                    
                    [cell addSubview:bannerView];
                }
            }
            
            // Initiate a generic request to load it with an ad.
            GADRequest *request = [GADRequest request];
            [bannerView loadRequest:request];
            
            return cell;
        }
        else if (feedType == TYPE_PHOTO || feedType == TYPE_VIDEO) {
            static NSString *CellIdentifier = @"FanFeedImageCell";
            
            FanFeedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FanFeedImageCell" bundle:nil];
                cell =(FanFeedImageCell*) viewController.view;
            }
            
            // Configure the cell.
            
//            cell.viewUser.tag = BTN_USER_ID + indexPath.row;
//            cell.viewUser.userInteractionEnabled = YES;
//            UITapGestureRecognizer * tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserDetail:)];
//            tapGestureUser.numberOfTapsRequired = 1;
//            [cell.viewUser addGestureRecognizer:tapGestureUser];
            
            NSString * starImageUrl = [self.userInfo objectForKey:@"img_url"];
            if (starImageUrl == nil || starImageUrl.length < 1) {
                UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:cell.imgAvatar.frame.size.width];
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
                                          else {
                                              UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:cell.imgAvatar.frame.size.width];
                                              [cell.imgAvatar setImage:image];
                                          }
                                          
                                      }];
            }
            
            cell.lbUserName.text = [self.userInfo objectForKey:@"name"];

            
            NSDate *dateSent = [NSDate dateWithTimeIntervalSince1970:[[feed objectForKey:@"time_stamp"] doubleValue]];
            cell.lbTimeStamp.text = [dateSent timeAgoFull];
            
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
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            cell.lbTitle.frame = CGRectMake(TITLE_POS_X, TITLE_MARGIN+49, TITLE_WIDTH, 34);
            cell.lbTitle.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
            cell.lbTitle.text = [feed objectForKey:@"caption"];
            cell.lbTitle.numberOfLines = 0;
            [cell.lbTitle sizeToFit];

            
            cell.imgPhoto.tag = BTN_PHOTO_ID + indexPath.row;
            cell.imgPhoto.userInteractionEnabled = YES;
            if (feedType == TYPE_PHOTO) {
                UITapGestureRecognizer * tapGesturePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoDetail:)];
                tapGesturePhoto.numberOfTapsRequired = 1;
                [cell.imgPhoto addGestureRecognizer:tapGesturePhoto];
            } else {
                UITapGestureRecognizer * tapGestureVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoDetail:)];
                tapGestureVideo.numberOfTapsRequired = 1;
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
                [cell.btnMore setEnabled:YES];
                cell.lbLikeNum.userInteractionEnabled = YES;
            } else {
                cell.viewLock.hidden = NO;
                
                [cell.btnLike setEnabled:NO];
                [cell.btnComment setEnabled:NO];
                [cell.btnAddComment setEnabled:NO];
                [cell.btnShare setEnabled:NO];
                [cell.btnMore setEnabled:NO];
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
            
            cell.btnMore.tag = BTN_MORE_ID + indexPath.row;
            [cell.btnMore addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnShare.tag = BTN_FACEBOOK_ID + indexPath.row;
            [cell.btnShare addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        else if (feedType == TYPE_TEXT) {
            
            static NSString *CellIdentifier = @"FanFeedTextCell";
            
            FanFeedTextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FanFeedTextCell" bundle:nil];
                cell =(FanFeedTextCell*) viewController.view;
            }
            
            // Configure the cell.
            
//            cell.viewUser.tag = BTN_USER_ID + indexPath.row;
//            cell.viewUser.userInteractionEnabled = YES;
//            UITapGestureRecognizer * tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserDetail:)];
//            tapGestureUser.numberOfTapsRequired = 1;
//            [cell.viewUser addGestureRecognizer:tapGestureUser];
            
            NSString * starImageUrl = [self.userInfo objectForKey:@"img_url"];
            if (starImageUrl == nil || starImageUrl.length < 1) {
                UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:cell.imgAvatar.frame.size.width];
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
                                          else {
                                              UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:cell.imgAvatar.frame.size.width];
                                              [cell.imgAvatar setImage:image];
                                          }
                                          
                                      }];
            }
            
            cell.lbUserName.text = [self.userInfo objectForKey:@"name"];
            
            NSDate *dateSent = [NSDate dateWithTimeIntervalSince1970:[[feed objectForKey:@"time_stamp"] doubleValue]];
            cell.lbTimeStamp.text = [dateSent timeAgoFull];
            
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
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            cell.lbText.frame = CGRectMake(TITLE_POS_X, TITLE_MARGIN+HEIGHT_HEADER, TITLE_WIDTH, 34);
            cell.lbText.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
            cell.lbText.text = [feed objectForKey:@"caption"];
            cell.lbText.numberOfLines = 0;
            [cell.lbText sizeToFit];


            
            cell.viewLock.frame = cell.lbText.frame;
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
                [cell.btnMore setEnabled:YES];
            } else {
                cell.viewLock.hidden = NO;
                
                [cell.btnLike setEnabled:NO];
                [cell.btnComment setEnabled:NO];
                [cell.btnAddComment setEnabled:NO];
                [cell.btnShare setEnabled:NO];
                [cell.btnMore setEnabled:NO];
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
                NSString * strMsgText = @"Tst Msg";
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
            
            cell.btnMore.tag = BTN_MORE_ID + indexPath.row;
            [cell.btnMore addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnShare.tag = BTN_FACEBOOK_ID + indexPath.row;
            [cell.btnShare addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
                
        return nil;
        
    }
    
	return nil;
    
}

@end
