//
//  ImageGalleryViewController.m
//
//  Created by  on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageGalleryViewController.h"
#import "DLImageLoader.h"

#import "CommentAutoController.h"

#import "GHAppDelegate.h"
#import "StarTracker.h"

#import "PublishFeedController.h"


@interface ImageGalleryViewController ()<CommentAutoControllerDelegate>
{
    
    NSMutableDictionary * resultExtro;
    
    NSMutableDictionary * m_dic;
    
    BOOL bLoaded;
}

@end

@implementation ImageGalleryViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithDic:(NSDictionary *) dic
{
    self = [super init];
    if (self) {
        m_dic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [StarTracker StarSendView:@"Photo Detail"];
}

-(BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown; //Or anyother orientation of your choice
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        GHAppDelegate * appDelegate = APPDELEGATE;
        [appDelegate orientationMediaPlayer:YES];
        [appDelegate.m_playView setChangeInterface:YES];
    }
    else {
        GHAppDelegate * appDelegate = APPDELEGATE;
        [appDelegate orientationMediaPlayer:NO];
        [appDelegate.m_playView setChangeInterface:NO];
    }

}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSLog(@"m_dic = %@", m_dic);
    
    
    GHAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.revealController increaseContentSize];
    appDelegate.m_playView.hidden = YES;
    
    
    self.navigationController.navigationBarHidden = YES;
    UIImageView *backgroundView = (UIImageView*)[self.navigationController.view viewWithTag:999];
    if (backgroundView != nil) {
        [backgroundView removeFromSuperview];
    }
    
    
    self.automaticallyAdjustsScrollViewInsets = false;

    [mLoadingView startAnimating];
    mLoadingView.hidden = NO;
    
    
    if (!bLoaded) {
        bLoaded = YES;

        NSString * description = [m_dic objectForKey:ID_PHOTO_CAPTION];
        if (description != nil) {
            lbDescription.text = description;
        } else {
            lbDescription.hidden = YES;
        }

        
        NSString * imageUrl = [m_dic objectForKey:ID_PHOTO_URL];
        
        [mImageView setContentMode:UIViewContentModeScaleAspectFit];
        [DLImageLoader loadImageFromURL:imageUrl
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      UIImage * image = [UIImage imageWithData:imgData];
                                      [mImageView setImage:image];
                                      
                                      [mLoadingView stopAnimating];
                                      mLoadingView.hidden = YES;

                                  }
                              }];
        

        mScrollView.minimumZoomScale = 1.0;
        mScrollView.maximumZoomScale = 30.0;

        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        tapGesture.numberOfTapsRequired = 1;
        
        UITapGestureRecognizer * tapDoubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDoubleRecognized:)];
        tapDoubleGesture.numberOfTapsRequired = 2;
//        tapDoubleGesture.numberOfTouchesRequired = 1;

        [tapGesture requireGestureRecognizerToFail:tapDoubleGesture];
        
        mImageView.userInteractionEnabled = YES;
        [mImageView addGestureRecognizer:tapGesture];
        [mImageView addGestureRecognizer:tapDoubleGesture];

        
        [self getExtraInfo];

    }
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mImageView;
}

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = mScrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    mScrollView.contentOffset = co;
}
#pragma mark
#pragma Touch Gesture
-(void) tapDoubleRecognized : (UITapGestureRecognizer*) sender {

    if (mScrollView.zoomScale == 1.0) {
        mScrollView.zoomScale = 1.8;
    }
    else {
        mScrollView.zoomScale = 1.0;
    }
}

-(void) tapRecognized : (UITapGestureRecognizer*) sender {
    if ([bottomBar isHidden]) {
        [self showToolbar:YES];
    }
    else {
        [self showToolbar:NO];
    }
}

-(void) showToolbar:(BOOL) bShow
{
    if (bShow) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        
        [bottomBar setHidden:NO];
        [topBar setHidden:NO];
        
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        //        [UIView setAnimationDelegate:self];
        //        [UIView setAnimationDidStopSelector:@selector(didStopAnimation)];
        
        [bottomBar setHidden:YES];
        [topBar setHidden:YES];
        
        
        [UIView commitAnimations];
    }
}

#pragma mark -
- (void) getExtraInfo{
    
    //    [self showLoading:@"Login..."];
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
    
}
-(void) postServer
{
    NSString * postType = [m_dic objectForKey:POSTTYPE];
    NSString * contentID = [m_dic objectForKey:CONTENTID];
    
    NSString * urlResult = [MyUrl getExtraInfo:postType :contentID];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            resultExtro = [[NSMutableDictionary alloc] initWithDictionary:result];
            
            [self performSelectorOnMainThread:@selector(setInterface) withObject:nil waitUntilDone:YES];
        }
    }
}

- (void) setInterface
{
    NSArray * comments = [resultExtro objectForKey:@"comments"];
    
    int nComment = (int)[comments count];
    NSString * sComment = @"";
    if (nComment == 1) {
        sComment = [NSString stringWithFormat:@"%d Comment", nComment];
    } else if (nComment > 1) {
        sComment = [NSString stringWithFormat:@"%d Comments", nComment];
    } else {
        sComment = @"No Comments";
    }
    lbComment.text = sComment;

    BOOL didLike = [[resultExtro objectForKey:@"did_like"] boolValue];
    int like = [[resultExtro objectForKey:@"numberoflike"] intValue];
    
    lbLike.text = [NSString stringWithFormat:@"%d", like];
    
    [btnLike setSelected:didLike];
}

#pragma mark  --------------------------

- (IBAction)onClose:(id)sender{


    GHAppDelegate * appDelegate = APPDELEGATE;
    [appDelegate.revealController decreaseContentSize];
    appDelegate.m_playView.hidden = NO;

    [appDelegate orientationMediaPlayer:NO];
    [appDelegate.m_playView setChangeInterface:NO];

//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
//    [self onBack];
}

- (IBAction)onAction:(id)sender
{
    
    NSString * text = [m_dic objectForKey:ID_PHOTO_CAPTION];
    NSString * contentId = [m_dic objectForKey:@"id"];
    
    m_dic[@"caption"] = text;
    m_dic[@"content_id"] = contentId;
    m_dic[@"post_type"] = @"photo";
    
    PublishFeedController * pController = [[PublishFeedController alloc] initWithShare:m_dic];
    [super onPush:pController];
    
    
//    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", nil];
//    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        
    NSString * text = [m_dic objectForKey:ID_PHOTO_CAPTION];
    NSString * imgUrl = [m_dic objectForKey:ID_PHOTO_URL];
    NSString * contentId = [m_dic objectForKey:@"content_id"];
    NSString * postType = [m_dic objectForKey:@"post_type"];
    NSString * deepLink = [[m_dic objectForKey:@"deep_link_web"] stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    
    NSMutableDictionary* postObj = [[NSMutableDictionary alloc] init];
    [postObj setObject:text forKey:@"TEXT"];
    if (mImageView.image != nil) {
        [postObj setObject:mImageView.image forKey:@"IMAGE"];
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
-(IBAction)onClickComment:(id)sender
{
    [super onCommentFeed:m_dic index:-1 Delegate:self];
    
}
-(IBAction)onAddComment:(id)sender
{
    [super onAddCommentFeed:m_dic index:-1 Delegate:self];
    
}

-(void) commentDone:(int)index comments:(NSArray *)arrComment count:(int)totalComment
{
    lbComment.text = [NSString stringWithFormat:@"%d Comments", totalComment];
}

-(IBAction) onLike:(id)sender
{
    if (![btnLike isSelected]) {
        [btnLike setSelected:YES];
    } else {
        [btnLike setSelected:NO];
    }
    
    [NSThread detachNewThreadSelector: @selector(likeServer:) toTarget:self withObject:nil];
}
-(void) likeServer:(NSDictionary *) dic
{
    NSString* postType = @"photo";
    NSString * contentId = [m_dic objectForKey:@"content_id"];
    
    NSString * urlString = [MyUrl addLike:postType contentId:contentId like:[btnLike isSelected]];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        int numberOfLike = [[result objectForKey:@"numbersoflike"] intValue];
        lbLike.text = [NSString stringWithFormat:@"%d", numberOfLike];
    }
}

@end
