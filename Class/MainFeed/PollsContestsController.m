//
//  PollsContestsController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/30/13.
//
//

#import "PollsContestsController.h"
#import "QuizController.h"
//#import "QuizCheckController.h"
#import "PollsController.h"

#import "FeedQuizCell.h"

#import "CommentAutoController.h"

#import "StarTracker.h"


@interface PollsContestsController ()<CommentAutoControllerDelegate>

@end

@implementation PollsContestsController

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
    m_bMoreLoad = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [StarTracker StarSendView: @"Poll"];
    
    [self.arrTableList removeAllObjects];
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
        
    }
    
    [self showLoading:@"Loading..."];
    
    m_nPage = 1;
    [self getFeedDatas];

}

- (void) getFeedDatas{
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
    
}
-(void) postServer
{
    NSString * urlString = [MyUrl getMainFeedUrl:@"poll_quiz" page:m_nPage];
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:pinResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            [self hideLoading];
            
//            self.arrAllTableList = [result objectForKey:@"feeds"];
//            self.arrTableList = [NSMutableArray arrayWithArray:self.arrAllTableList];
            if (m_nPage <= 1) {
                self.arrTableList = [result objectForKey:@"feeds"];
            } else {
                [self.arrTableList addObjectsFromArray:[result objectForKey:@"feeds"]];
            }
            
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
-(void) commentDone:(int)index comments:(NSArray *)arrComment count:(int)totalComment {
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[self.arrTableList objectAtIndex:index]];
    [dic setObject:arrComment forKey:@"comments"];
    [dic setObject:[NSNumber numberWithInt:totalComment] forKey:@"comments_count"];
    
    [self.arrTableList replaceObjectAtIndex:index withObject:dic];
    
    [self doneLoadingTableViewData];
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


-(void) onQuizStartButton:(UIButton*) sender
{
    int tag = (int)sender.tag - BTN_START_ID;
    
    NSDictionary * dic = [self.arrTableList objectAtIndex:tag];
    
    BOOL bAnswered = [[dic objectForKey:@"answered"] boolValue];
    if (bAnswered) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"NOTE"
                                                        message: @"You've already answered this post."
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1800) {
        
        NSDictionary * feed = [self.arrTableList objectAtIndex:m_nIndexShare];
        
        
        NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:m_nIndexShare inSection:self.m_nNumOfSection-1];
        
        
        UIImage * imagePhoto = NULL;
        FeedQuizCell *cell = (FeedQuizCell*)[self.mTableView cellForRowAtIndexPath:nowIndex];
        imagePhoto = cell.imgPhoto.image;
        
        NSString * text = [feed objectForKey:@"caption"];
        NSString * imgUrl = [feed objectForKey:@"image_path"];
        NSString * contentId = [feed objectForKey:@"content_id"];
        NSString * postType = [feed objectForKey:@"post_type"];
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
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrTableList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int height = HEIGHT_HEADER;
    
    NSDictionary * feed = [self.arrTableList objectAtIndex:indexPath.row];
    
    // Image
    height += HEIGHT_IMAGE;
    
    // message
    NSArray * arrMsg = [feed objectForKey:@"comments"];
    if ([arrMsg count] >= 3) {
        height += HEIGHT_MSG_ONE * 3 + HEIGHT_MSG_OFFSET*2;
    }
    else {
        if ([arrMsg count] != 0) {
            height += (HEIGHT_MSG_ONE * [arrMsg count]) + HEIGHT_MSG_OFFSET*2;
        }
    }

    
    height += HEIGHT_SHARE + HEIGHT_SPACE;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FeedQuizCell";
    
    FeedQuizCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FeedQuizCell" bundle:nil];
        cell =(FeedQuizCell*) viewController.view;
    }
    
    // Configure the cell.
    NSDictionary * feed = [self.arrTableList objectAtIndex:indexPath.row];
    
    
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
    
    int like = [[feed objectForKey:@"numberoflike"] intValue];
    cell.lbLikeNum.text = [NSString stringWithFormat:@"%d", like];
    cell.lbLikeNum.tag = BTN_LIKE_LIST_ID + indexPath.row;
    cell.lbLikeNum.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGestureLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLikeList:)];
    tapGestureLike.numberOfTapsRequired = 1;
    [cell.lbLikeNum addGestureRecognizer:tapGestureLike];
    
    
    cell.btnLike.tag = BTN_LIKE_ID + indexPath.row;
    BOOL didLike = [[feed objectForKey:@"did_like"] boolValue];
    [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateSelected];
    [cell.btnLike setImage:[UIImage imageNamed:@"btn_star_sel_black.png"] forState:UIControlStateHighlighted];
    [cell.btnLike setSelected:didLike];
    [cell.btnLike addTarget:self action:@selector(onLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    
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

    cell.btnShare.tag = BTN_FACEBOOK_ID + indexPath.row;
    [cell.btnShare addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}
@end
