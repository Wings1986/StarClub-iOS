//
//  CommentController.m
//  StarClub
//
//  Created by MAYA on 1/3/14.
//
//

#import "CommentController.h"
//#import "CommentCell.h"

#import "JSMessage.h"
#import "JSAutoMessageCell.h"

#import "UIImage+JSMessagesView.h"
#import "NSDate+TimeAgo.h"
#import "DLImageLoader.h"

#import "FanDetailController.h"
#import "GHAppDelegate.h"


// set to 1 to turn on row height caching
#define PERFORMANCE_ENABLE_HEIGHT_CACHE 1

// set to 1 to turn on a separate cell ID for rows showing the media icon
#define PERFORMANCE_ENABLE_MEDIA_CELL_ID 1

// set to 1 to use iOS 7's estimatedRowHeight table optimization
#define PERFORMANCE_ENABLE_ESTIMATED_ROW_HEIGHT 1


@interface CommentController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * mTableView;
    
    NSString * strComment;
    
    UIButton * btnTrash;
    UITapGestureRecognizer *gestureRecognizer;
    
    int m_nIndexDel;
    
    BOOL bAddComment;
    
    BOOL m_bChanged;
    
    NSMutableArray * arrComments;
}

@property(nonatomic, strong) NSDictionary * m_info;
@property(nonatomic, assign) int m_nIndex;


@property(nonatomic, strong) NSMutableArray				*messages;
@property(nonatomic, strong) NSMutableDictionary	*rowHeightCache;
@property(nonatomic, strong) JSAutoMessageCell		*sizingCell;


@end

@implementation CommentController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (bAddComment) {
        self.title = @"Add Comment";
    } else {
        self.title = @"Comments";
    }
    
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
    [DLImageLoader loadImageFromURL:userImageUrl
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:kJSAvatarSize];
                                  [imgAvatar setImage:image];
                              }
                          }];
    
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
        
        /*
         * create a cell instance to use for auto layout sizing
         */
        self.sizingCell = [[JSAutoMessageCell alloc] initWithReuseIdentifier:nil];
        self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth; // this must be set for the cell heights to be calculated correctly in landscape
        self.sizingCell.hidden = YES;
        
        [mTableView addSubview:self.sizingCell];
        
        self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(mTableView.bounds), 0);
        
        
        /*
         * create and prime our cache if enabled
         */
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
		self.rowHeightCache = [NSMutableDictionary dictionary];
#endif
        
        
        /*
         * load our dummy data
         */
        
//        self.messages = [self messagesFromFile];
        
        self.messages = [[NSMutableArray alloc] init];
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
        [self.delegate commentDone: self.m_nIndex comments:arrComments];
    }

    [self onBack];
    
}

-(IBAction) onClickPost:(id)sender
{
    strComment = txtPost.text;
    if ([txtPost isFirstResponder]) {
        [txtPost resignFirstResponder];
        txtPost.text = @"";
    }

    [self addComment];
}

#pragma mark - UITableViewDataSource
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        NSString * ownerName = [userInfo objectForKey:@"name"];
        
        int index = indexPath.row;
        JSMessage *m = [self.messages objectAtIndex:index];
        NSString * userName = m.username;
        
        if (![ownerName isEqualToString:userName]) {
            [super showMessage:@"NOTE!" message:@"You can not remove this comment." delegate:nil firstBtn:@"OK" secondBtn:nil];
            return;
        }
        else {
            m_nIndexDel = index;
            [NSThread detachNewThreadSelector: @selector(deleteCommentToServer) toTarget:self withObject:nil];
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        if (buttonIndex == 0) { // NO
            
        }
        else if (buttonIndex == 1) {
            [NSThread detachNewThreadSelector: @selector(deleteCommentToServer) toTarget:self withObject:nil];
            
        }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * ownerName = [userInfo objectForKey:@"name"];
    
    int index = indexPath.row;
    JSMessage *m = [self.messages objectAtIndex:index];
    NSString * userName = m.username;
    
    if (![ownerName isEqualToString:userName]) {
//        [super showMessage:@"NOTE!" message:@"You can not remove this comment." delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    else {
        m_nIndexDel = index;
        [super showMessage:@"NOTE!" message:@"Do you want to remove this comment?" delegate:self firstBtn:@"NO" secondBtn:@"YES"];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.messages.count;
}

#if PERFORMANCE_ENABLE_ESTIMATED_ROW_HEIGHT
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [JSMessageCell minimumHeightShowingMediaIcon:NO];
}
#endif

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	JSMessage *message = self.messages[indexPath.row];
	
	// check the cache first if enabled
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    NSNumber *cachedHeight = self.rowHeightCache[message.uniqueIdentifier];
	
    if (cachedHeight != nil) {
        return [cachedHeight floatValue];
    }
#endif
	
	
	CGFloat calculatedHeight = 0;
	
	// determine which dyanmic height method to use
    {
		self.sizingCell.message = message;
		
		[self.sizingCell setNeedsLayout];
		[self.sizingCell layoutIfNeeded];
		
		calculatedHeight = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
	}
	
	// cache the value if enabled
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    self.rowHeightCache[message.uniqueIdentifier] = @(calculatedHeight);
#endif
	
	return calculatedHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *autoCellId = @"autoCell";
	static NSString *autoCellMediaId = @"autoMediaCell";
    
	JSMessageCell *cell = nil;
	JSMessage *message = self.messages[indexPath.row];
	
	// manual layout cells
	{
		NSString *cellId = nil;
		
		// choose the appropriate cell ID
#if PERFORMANCE_ENABLE_MEDIA_CELL_ID
        if (message.hasMedia) {
            cellId = autoCellMediaId;
            
        } else {
            cellId = autoCellId;
        }
		
#else
        cellId = autoCellId;
#endif
		
		
		cell = [tableView dequeueReusableCellWithIdentifier:cellId];
		
		if (cell == nil) {
			cell = [[JSAutoMessageCell alloc] initWithReuseIdentifier:cellId];
		}
        
        cell.avatarView.tag = BTN_PHOTO_ID + indexPath.row;
        cell.avatarView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesturePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFanDetail:)];
        tapGesturePhoto.numberOfTapsRequired = 1;
        [cell.avatarView addGestureRecognizer:tapGesturePhoto];
	}
	
	cell.message = message;
    
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
    
    NSString * urlString = [MyUrl getComment:postType contentId:contentId page:0];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"comment success");
        
        [self.messages removeAllObjects];
        arrComments = [result objectForKey:@"comments"];

        for (NSDictionary * dic in arrComments) {
            JSMessage *m = [[JSMessage alloc] init];
            
            m.uniqueIdentifier = [NSNumber numberWithInt:2];
            m.username = [dic objectForKey:@"name"];
            m.imageUrl = [dic objectForKey:@"img_url"];
            m.messageText = [dic objectForKey:@"comment"];
            m.dateSent = [NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"time_stamp"] doubleValue]];
            m.hasMedia = NO;
            m.content_id = [dic objectForKey:@"content_id"];
            m.post_type = [dic objectForKey:@"post_type"];
            m.userId = [dic objectForKey:@"user_id"];
            m.commentId = [dic objectForKey:@"id"];
            
            [self.messages addObject:m];
            
        }
        
        // sort
        
        [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
        //[self refreshTable];
    }
    else {
        NSLog(@"comment fail");
    }

}

-(void) deleteCommentToServer{
    
    JSMessage * m = [self.messages objectAtIndex:m_nIndexDel];
    
    NSString* postType = m.post_type;
    NSString* contentId = m.content_id;
    NSString* commentId = m.commentId;
    
    NSString * urlString = [MyUrl deleteComment:postType contentId:contentId commentId:commentId];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"delete success");
        
        [self.messages removeObjectAtIndex:m_nIndexDel];
        [arrComments removeObjectAtIndex:m_nIndexDel];
        
        
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

    
    NSString * urlString = [MyUrl addComment:postType contentId:contentId comment:comment];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"comment success");

        [self.messages removeAllObjects];
        
        arrComments = [result objectForKey:@"comments"];
        
        for (NSDictionary * dic in arrComments) {
            JSMessage *m = [[JSMessage alloc] init];
            
            m.uniqueIdentifier = [NSNumber numberWithInt:2];
            m.username = [dic objectForKey:@"name"];
            m.imageUrl = [dic objectForKey:@"img_url"];
            m.messageText = [dic objectForKey:@"comment"];
            m.dateSent = [NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"time_stamp"] doubleValue]];
            m.hasMedia = NO;
            m.content_id = [dic objectForKey:@"content_id"];
            m.post_type = [dic objectForKey:@"post_type"];
            m.userId = [dic objectForKey:@"user_id"];
            m.commentId = [dic objectForKey:@"id"];
            
            [self.messages addObject:m];
            
        }

        m_bChanged = YES;
        [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
//        [self refreshTable];
    }
    else {
        NSLog(@"comment fail");
    }

}

- (void) refreshTable {

    // invalidate the cache if enabled

#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    self.rowHeightCache = [NSMutableDictionary dictionary];
#endif
    
    // load the new cell type
    [mTableView reloadData];
    
}
- (NSMutableArray*)messagesFromFile {
	NSError *error = nil;
	NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"messages" ofType:@"json"]]
														 options:kNilOptions
														   error:&error];
	if (error != nil) {
		NSLog(@"Error: was not able to load messages.");
		return nil;
	}
	
	NSArray *rawMessages = data[@"messages"];
	NSMutableArray *finalMessages = [NSMutableArray array];
	
	for (NSDictionary *messageData in rawMessages) {
		JSMessage *m = [[JSMessage alloc] init];
		
		m.uniqueIdentifier = messageData[@"uniqueIdentifier"];
		m.username = messageData[@"username"];
		m.messageText = messageData[@"messageText"];
		m.dateSent = [NSDate dateWithTimeIntervalSince1970:[messageData[@"messageDate"] doubleValue]];
		m.hasMedia = [messageData[@"hasMedia"] boolValue];
		
		[finalMessages addObject:m];
	}
	
	return finalMessages;
}


-(void) onFanDetail:(UITapGestureRecognizer*) gesture
{
    UIImageView * imageView = (UIImageView*) gesture.view;
    int tag = imageView.tag - BTN_PHOTO_ID;
    
    JSMessage *m = [self.messages objectAtIndex:tag];
    NSString * userId = m.userId;
    
    NSDictionary * oneComment = [arrComments objectAtIndex:tag];
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
	
    [mTableView addGestureRecognizer:gestureRecognizer];

    
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
    mTableView.frame = CGRectMake(mTableView.frame.origin.x, mTableView.frame.origin.y,
                                  mTableView.frame.size.width, mTableView.frame.size.height-keyboardHeight +(appDelegate.m_playView.hidden ? 0 : TOOLBAR_HEIGHT));
    
	// Keyboard is now visible
	keyboardVisible = YES;
    
    if ([self.messages count] != 0) {
//        [mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void) keyboardDidHide: (NSNotification *)notif
{
	// Is the keyboard already shown
	if (!keyboardVisible)
	{
		return;
	}

    [mTableView removeGestureRecognizer:gestureRecognizer];

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
    mTableView.frame = CGRectMake(mTableView.frame.origin.x, mTableView.frame.origin.y,
                                  mTableView.frame.size.width, mTableView.frame.size.height+keyboardHeight- (appDelegate.m_playView.hidden ? 0 : TOOLBAR_HEIGHT));
    
	// Keyboard is no longer visible
	keyboardVisible = NO;
}

@end
