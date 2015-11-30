//
//  CommentController.m
//  StarClub
//

#import "CommentAutoController.h"
#import "CommentCell.h"

#import "NSDate+TimeAgo.h"
#import "DLImageLoader.h"

#import "FanDetailController.h"
#import "GHAppDelegate.h"

#import "StarTracker.h"



@interface CommentAutoController ()
{
    NSString * strComment;
    
    UITapGestureRecognizer *gestureRecognizer;
    
    int m_nIndexDel;
    
    BOOL bAddComment;
    
    BOOL m_bChanged;
    
    NSMutableArray * arrComments;
    int m_nTotalComment;
}

@property(nonatomic, strong) NSDictionary * m_info;
@property(nonatomic, assign) int m_nIndex;


@end

@implementation CommentAutoController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithData:(NSDictionary*) dic index:(int) index
{
    self = [super init];
    if (self) {
        self.m_info = [[NSDictionary alloc] initWithDictionary:dic];
        self.m_nIndex = index;
        bAddComment = NO;
    }
    return self;
}
-(id) initWithAddComment:(NSDictionary*) dic index:(int) index
{
    self = [super init];
    if (self) {
        self.m_info = [[NSDictionary alloc] initWithDictionary:dic];
        self.m_nIndex = index;
        bAddComment = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    m_bMoreLoad = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.m_nNumOfSection = 1;
    self.m_nNumOfHeader = 0;
    
    
    m_nTotalComment = -1;
    
    if (bAddComment) {
        self.title = @"Add Comment";
    } else {
        self.title = @"Comments";
    }
    
    [StarTracker StarSendView:self.title];
    
    txtPost.layer.borderColor = [[UIColor colorWithRed:181.0f/255.0f green:181.0f/255.0f blue:181.0f/255.0f alpha:1.0f] CGColor];
    txtPost.layer.borderWidth = 1;
    
    
    UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnCancel setImage:[UIImage imageNamed:@"btn_done.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_send.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickPost:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemRight = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemRight;

    
    gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];

    
    // avatar
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * userImageUrl = [userInfo objectForKey:@"img_url"];
    if (userImageUrl == nil || userImageUrl.length < 1) {
        UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"]  circleImageWithSize:imgAvatar.frame.size.width];
        [imgAvatar setImage:image];
    }
    else {
        [DLImageLoader loadImageFromURL:userImageUrl
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:imgAvatar.frame.size.width];
                                      [imgAvatar setImage:image];
                                  }
                              }];
    }
    
    m_bChanged = NO;
    
}



- (void) viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear: animated];

    // Force any text fields that might be being edited to end so the text is stored
    [self.view.window endEditing: YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"%@", NSStringFromClass([self.navigationController class]));
    
    if (!bLoaded) {
        bLoaded = YES;
        
        m_nPage = 0;
        [self getComments];
    }
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (bAddComment && ![txtPost isFirstResponder]) {
        [txtPost becomeFirstResponder];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) onClickCancel:(id)sender
{
    if ([txtPost isFirstResponder]) {
        [txtPost resignFirstResponder];
    }
    
    if (m_bChanged == YES) {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        
        for (int i = 0 ; i < (int)[arrComments count]; i ++) {
            if (i > 2) {
                break;
            }
            
            [array addObject:[arrComments objectAtIndex:i]];
        }
        
        [self.delegate commentDone: self.m_nIndex comments:array count:m_nTotalComment];
    }

    [self onBack];
    
}

-(IBAction) onClickPost:(id)sender
{
    if (txtPost.text.length < 1) {
        [super showMessage:@"Warning!" message:@"Please input message!" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    strComment = txtPost.text;
    txtPost.text = @"";
    if ([txtPost isFirstResponder]) {
        [txtPost resignFirstResponder];
    }

    [self addComment];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) { // NO
        
    }
    else if (buttonIndex == 1) {
        [NSThread detachNewThreadSelector: @selector(deleteCommentToServer) toTarget:self withObject:nil];
        
    }
}



#pragma mark - UITableViewDataSource


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * ownerName = [userInfo objectForKey:@"name"];
    
    int index = (int)indexPath.row;
    NSDictionary * oneComment = [arrComments objectAtIndex:index];
    
    NSString * userName = [oneComment objectForKey:@"name"];
    
    
    if ([ownerName isEqualToString:userName]
        || [Global getUserType] != FAN) {
        m_nIndexDel = index;
        [super showMessage:@"NOTE!" message:@"Do you want to remove this comment?" delegate:self firstBtn:@"NO" secondBtn:@"YES"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrComments == nil) {
        return 0;
    }
    
	return [arrComments count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * comment = [arrComments objectAtIndex:indexPath.row];
    
    int LABEL_WIDTH = 240;
    
    UILabel * labelText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, 50)];
    labelText.font = [UIFont fontWithName:FONT_NAME size:15.0f];
    labelText.text = [comment objectForKey:@"comment"];
    labelText.numberOfLines = 0;
    [labelText sizeToFit];
    
    
    int calculatedHeight = 5 + 28 + labelText.frame.size.height + 4 + 21 + 2;

    return calculatedHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CommentCell";
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"CommentCell" bundle:nil];
        cell =(CommentCell*) viewController.view;
    }

    NSDictionary * oneComment = [arrComments objectAtIndex:indexPath.row];
    
    
    NSString * userImageUrl = [oneComment objectForKey:@"img_url"];
    if (userImageUrl == nil || userImageUrl.length < 1) {
        UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"]  circleImageWithSize:cell.imgPhoto.frame.size.width];
        [cell.imgPhoto setImage:image];
    }
    else {
        [DLImageLoader loadImageFromURL:userImageUrl
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      UIImage * image = [[UIImage imageWithData:imgData]  circleImageWithSize:cell.imgPhoto.frame.size.width];
                                      [cell.imgPhoto setImage:image];
                                  }
                                  else {
                                      UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"]  circleImageWithSize:cell.imgPhoto.frame.size.width];
                                      [cell.imgPhoto setImage:image];
                                  }
                              }];
    }
    
    cell.imgPhoto.tag = BTN_PHOTO_ID + indexPath.row;
    cell.imgPhoto.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesturePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFanDetail:)];
    tapGesturePhoto.numberOfTapsRequired = 1;
    [cell.imgPhoto addGestureRecognizer:tapGesturePhoto];
    
    
    cell.lbTitle.text = [oneComment objectForKey:@"name"];
    
    cell.lbComment.frame = CGRectMake(70, cell.lbTitle.frame.origin.y + cell.lbTitle.frame.size.height,
                                      240, 50);
    cell.lbComment.font = [UIFont fontWithName:FONT_NAME size:15.0f];
    cell.lbComment.text = [oneComment objectForKey:@"comment"];
    cell.lbComment.numberOfLines = 0;
    [cell.lbComment sizeToFit];
    
    cell.lbTime.frame = CGRectMake(232, cell.lbComment.frame.origin.y+cell.lbComment.frame.size.height+2, 80, 20);
    NSDate *dateSent = [NSDate dateWithTimeIntervalSince1970:[[oneComment objectForKey:@"time_stamp"] doubleValue]];
    cell.lbTime.text = [dateSent timeAgo];

	return cell;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        [self performSelector:@selector(onClickPost:) withObject:nil afterDelay:0.1];
        
        return NO;
    }
    
    return YES;
}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self onClickPost:nil];
//    
//    return YES;
//}

#pragma mark - Data management
-(void) getComments
{
    [NSThread detachNewThreadSelector: @selector(getCommentsFromServer) toTarget:self withObject:nil];
}
-(void) addComment
{
    [NSThread detachNewThreadSelector: @selector(postCommentsToServer) toTarget:self withObject:nil];
}

-(void) getCommentsFromServer{
    
    NSString* postType = [self.m_info objectForKey:POSTTYPE];
    NSString* contentId = [self.m_info objectForKey:CONTENTID];
    
    NSString * urlString = [MyUrl getComment:postType contentId:contentId page:m_nPage];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        
        if (arrComments == nil || m_nPage == 0) {
            arrComments = [result objectForKey:@"comments"];
        }
        else {
            [arrComments addObjectsFromArray:[result objectForKey:@"comments"]];
        }
        
        m_nPage ++;
        
        [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
    }
    else {
        NSLog(@"comment fail");
    }

}

-(void) deleteCommentToServer{
    
    NSDictionary * m = [arrComments objectAtIndex:m_nIndexDel];
    
    NSString* postType = [m objectForKey:@"post_type"];
    NSString* contentId = [m objectForKey:@"content_id"];
    NSString* commentId = [m objectForKey:@"id"];
    
    NSString * urlString = [MyUrl deleteComment:postType contentId:contentId commentId:commentId count:(int)[arrComments count]-1];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"delete success");
        
        arrComments = [result objectForKey:@"comments"];
        m_nTotalComment  = [[result objectForKey:@"comments_count"] intValue];
        
        m_bChanged = YES;
        [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
    }
    else {
        NSLog(@"comment fail");
    }
    
}


-(void) postCommentsToServer{
    
    NSString* postType = [self.m_info objectForKey:POSTTYPE];
    NSString* contentId = [self.m_info objectForKey:CONTENTID];
    NSString* comment = strComment;

    
    NSString * urlString = [MyUrl addComment:postType contentId:contentId comment:comment count:(int)[arrComments count]+1];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"comment success");

        arrComments = [result objectForKey:@"comments"];
        m_nTotalComment  = [[result objectForKey:@"comments_count"] intValue];
        
        m_bChanged = YES;

        [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
    }
    else {
        NSLog(@"comment fail");
    }

}


- (void)startRefresh
{
    [super startRefresh];
    
    m_nPage = 0;
    [self getComments];
}
- (void)startMoreLoad
{
    [super startMoreLoad];
    
    [self getComments];
}

- (void) refreshTable {
    [super doneLoadingTableViewData];
}


//- (void) refreshTable {
//
//    // load the new cell type
//    [mTableView reloadData];
//    
//}


-(void) onFanDetail:(UITapGestureRecognizer*) gesture
{
    UIImageView * imageView = (UIImageView*) gesture.view;
    int tag = (int)imageView.tag - BTN_PHOTO_ID;
    

    NSDictionary * oneComment = [arrComments objectAtIndex:tag];
    
    NSString * userId = [oneComment objectForKey:@"user_id"];
    NSString * type = [oneComment objectForKey:@"admin_type"];
    
    if (type == nil || (NSString *)[NSNull null] == type || [type isEqualToString:@""] ) {
        FanDetailController * pController = [[FanDetailController alloc] initWithUserID:userId];
        [super onPush:pController];
    }
    
}

-(void)hideKeyboard{
    if ([txtPost isFirstResponder]) {
        [txtPost resignFirstResponder];
    }
}


#pragma mark ---------- Key board
-(void) keyboardDidShow: (NSNotification *)notif
{
    if (keyboardVisible)
	{
		return;
	}
	
    [self.mTableView addGestureRecognizer:gestureRecognizer];

    
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
    float keyboardWidth = keyboardSize.width;
    float keyboardHeight = keyboardSize.height;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        keyboardWidth = keyboardSize.height;
        keyboardHeight = keyboardSize.width;
    }
    
    GHAppDelegate * appDelegate = APPDELEGATE;
    
	viewSend.frame = CGRectMake(viewSend.frame.origin.x, viewSend.frame.origin.y-keyboardHeight + (appDelegate.m_playView.hidden ? 0 : TOOLBAR_HEIGHT),
                                viewSend.frame.size.width, viewSend.frame.size.height);
    self.mTableView.frame = CGRectMake(self.mTableView.frame.origin.x, self.mTableView.frame.origin.y,
                                  self.mTableView.frame.size.width, self.mTableView.frame.size.height-keyboardHeight +(appDelegate.m_playView.hidden ? 0 : TOOLBAR_HEIGHT));
    
	// Keyboard is now visible
	keyboardVisible = YES;
    
    if ([arrComments count] != 0) {
        [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void) keyboardDidHide: (NSNotification *)notif
{
	// Is the keyboard already shown
	if (!keyboardVisible)
	{
		return;
	}

    [self.mTableView removeGestureRecognizer:gestureRecognizer];

    NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;

    float keyboardWidth = keyboardSize.width;
    float keyboardHeight = keyboardSize.height;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        keyboardWidth = keyboardSize.height;
        keyboardHeight = keyboardSize.width;
    }
    
    GHAppDelegate * appDelegate = APPDELEGATE;
    
    viewSend.frame = CGRectMake(viewSend.frame.origin.x, viewSend.frame.origin.y+keyboardHeight- (appDelegate.m_playView.hidden ? 0 : TOOLBAR_HEIGHT),
                                viewSend.frame.size.width, viewSend.frame.size.height);
    self.mTableView.frame = CGRectMake(self.mTableView.frame.origin.x, self.mTableView.frame.origin.y,
                                  self.mTableView.frame.size.width, self.mTableView.frame.size.height+keyboardHeight- (appDelegate.m_playView.hidden ? 0 : TOOLBAR_HEIGHT));
    
	// Keyboard is no longer visible
	keyboardVisible = NO;
}

@end
