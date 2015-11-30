//
//  BaseViewController.m
//  StarClub
//
//  Created by maya on 11/20/11.
//

#import "BaseViewController.h"

#import "CommentAutoController.h"

#import "GHAppDelegate.h"
#import "BuyCreditController.h"


#import <Social/Social.h>
#import "accounts/Accounts.h"
#import <Twitter/Twitter.h>


#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MFMailComposeViewController.h>//mail controller

#import "StarTracker.h"
#import "base64.h"

#import <FacebookSDK/FacebookSDK.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"

#import "CustomIOS7AlertView.h"

#import "FBShareController.h"


@interface BaseViewController ()<MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, CustomIOS7AlertViewDelegate>
{
    MPMoviePlayerController * moviePlayer;
    
    NSString * m_strFBPageName;
}

@property (nonatomic, strong)     UIDocumentInteractionController * docFile;

@end

#pragma mark Implementation
@implementation BaseViewController

    
#pragma mark UIViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    bLoaded = NO;
}

- (void)hideStatusBar
{
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
//    {
//        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//    }
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;

//    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    UIImageView *backgroundView = (UIImageView*)[self.navigationController.view viewWithTag:999];
    if (backgroundView == nil) {
        backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationController.navigationBar.frame), 64)];
        [backgroundView setImage:[UIImage imageNamed:@"navigation_back"]];
        backgroundView.tag = 999;
        [self.navigationController.view insertSubview:backgroundView belowSubview:self.navigationController.navigationBar];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self hideStatusBar];
//    double delayInSeconds = 0.2;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self hideStatusBar];
//    });
}

#pragma mark
#pragma oritation
-(BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait; //Or anyother orientation of your choice
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark Navigation Bar

- (void) onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) onPush:(UIViewController*) pController
{
    [self.navigationController pushViewController:pController animated:YES];
}


#pragma mark ---------- Alert View

-(void) showMessage:(NSString*) title message:(NSString*) message delegate:(id) delegate firstBtn:(NSString*) first secondBtn:(NSString*) second
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: message
                                                   delegate: delegate
                                          cancelButtonTitle:first
                                          otherButtonTitles:second, nil];
    [alert show];
}

#pragma mark -
#pragma mark Button Event

-(void) onCommentFeed:(NSDictionary*) dic index:(int) index Delegate:(id) delegate
{
//    CommentController * pController = [[CommentController alloc] initWithData:dic index:index];
//    pController.delegate = delegate;
//    [self onPush:pController];
    CommentAutoController * pController = [[CommentAutoController alloc] initWithData:dic index:index];
    pController.delegate = delegate;
    [self onPush:pController];

}

-(void) onAddCommentFeed:(NSDictionary*) dic index:(int) index Delegate:(id) delegate
{
    CommentAutoController * pController = [[CommentAutoController alloc] initWithAddComment:dic index:index];
    pController.delegate = delegate;
    [self onPush:pController];

//    CommentController * pController = [[CommentController alloc] initWithAddComment:dic index:index];
//    pController.delegate = delegate;
//    [self onPush:pController];
}

#pragma mark
#pragma report
-(void) onReportEmail:(NSArray*) emails content:(NSString*) body image:(UIImage*) image
{
    
    NSString *subject = @"Report";
    
    if(![MFMailComposeViewController canSendMail]){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please configure your mail settings to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
        [StarTracker StarSendEvent:@"App Event" :@"Report E-Mail Not Configured" :@"App Error State"];
        return;
    }
    
    MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:subject];
    [mc setToRecipients:emails];
    [mc setMessageBody:body isHTML:NO];
    
    if (image != nil) {
        NSData *data = UIImagePNGRepresentation(image);
        [mc addAttachmentData:data mimeType:@"image/png" fileName:@"attached"];
    }
    
    [self presentViewController:mc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    switch (result) {
        case MFMailComposeResultSent:
            
//            [[[UIAlertView alloc] initWithTitle:nil message:@"Email sent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            [StarTracker StarSendEvent:@"App Event" :@"Report E-Mail Sent" :@"Fan Action"];
            [self showWithCustomView:@"Email Sent!"];
            break;
        
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark Share

-(void) doAlertViewWithTextView:(NSMutableDictionary *) dicPost
{
    if (!m_bIsCustomCaptionFb) {
        [self gotoPost:dicPost];
        return;
    }
    
    UIImage* attach = dicPost[@"IMAGE"];
    if (attach == nil) {
        attach = [UIImage imageNamed:@"starclub-logo.jpg"];
    } else {
        
#ifdef DISABLE_BC_FB_WIN
        NSString * postType = dicPost[@"POSTTYPE"];

        if ([postType isEqualToString:@"video"]) { // add play_icon
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:dicPost[@"IMAGEURL"]]];
            attach = [UIImage imageWithData:data];
        }
#endif
        
    }
    
    NSString * text = dicPost[@"TEXT"];
//    NSString * title = [NSString stringWithFormat:@"%@ %@", text, APPSTORE_URL];
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView:text : attach]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Post", nil]];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *_alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[_alertView tag]);
        
        UIView * containView = _alertView.containerView;
        UITextView * textView = (UITextView*)[containView viewWithTag:1000];
//        UIImageView * imageView = (UIImageView*) [containView viewWithTag:1001];
        
        NSString* postText = textView.text;
       
        [dicPost setObject:postText forKey:@"TEXT"];
       
        if (buttonIndex == 1) {
            [self gotoPost:dicPost];
        }
        else if (buttonIndex == 0) { // cancel
            
            if (m_bDraft) {
                [self facebookPostDone:@"Facebook cancelled!"];
            }
        }
        
        [_alertView close];

        
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    [alertView close];
}

- (UIView *)createDemoView:(NSString *) title : (UIImage*) image
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];
    
    
    // header
    
    UITextView * textHeaderView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
    textHeaderView.text = @"Facebook";
    textHeaderView.font = [UIFont boldSystemFontOfSize:16.0f];
    textHeaderView.backgroundColor = [UIColor clearColor];
    [demoView addSubview:textHeaderView];
    
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 40, 190, 100)];
    textView.text = title;
    textView.backgroundColor = [UIColor clearColor];
    textView.layer.cornerRadius = 5;
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0f] CGColor];
    textView.tag = 1000;
    [demoView addSubview:textView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(210, 40, 70, 70)];
    [imageView setImage:image];
    imageView.tag = 1001;
    [demoView addSubview:imageView];
    
    return demoView;
}

- (void) gotoPost:(NSMutableDictionary*) dicPost
{
    BOOL bWall = [dicPost[@"POSTTOWALL"] boolValue];

    if (bWall == true) {
        
        [StarTracker StarSendEvent:@"App Event" :@"Facebook Timeline Post" :@"Fan Action"];
        
        NSString * postType = dicPost[@"POSTTYPE"];
        if (![postType isEqualToString:@"photo"]) {
            [self postWallwithText:dicPost];   // post as link
        } else {
            [self postWallwithPhoto:dicPost];
  //          [self postWallwithText:dicPost];
        }
            
 
    }    else {
        
        NSString * postType = dicPost[@"POSTTYPE"];
        if (![postType isEqualToString:@"photo"]) {
            [self postLinkWithPageId:dicPost];   // post as link
        } else {
            [self postPhotoWithPageId:dicPost];
        }
      
        [StarTracker StarSendEvent:@"App Event" :@"Facebook Page Post" :@"Fan Action"];
        
    }
}
-(void) onFacebookAdmin:(NSDictionary*)dicPost

{
    if (FBSession.activeSession.state != FBSessionStateOpen) {

        [[[UIAlertView alloc] initWithTitle:@"Syndicate Error!"
                                    message:@"Please login to Facebook.\n ( Settings - Post to Facebook - Login"
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
    } else {
       [self sendRequests:dicPost];
    
    }

}


    
// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
    [StarTracker StarSendEvent:@"App Event" :@"FB Login Error" :text];
}




- (void)sendRequests :(NSDictionary*)dicPost
{
    
NSMutableDictionary * dicChange = [NSMutableDictionary dictionaryWithDictionary:dicPost];

NSDictionary * params = nil;

[FBRequestConnection startWithGraphPath:@"/me/accounts"
                           parameters:params
                           HTTPMethod:@"GET"
                    completionHandler:^(FBRequestConnection * connect, id result, NSError* error) {
                        
                        if (!error) {
                            NSLog(@"result = %@", result);
                            
                            NSDictionary *dict = result;
                            NSMutableArray * pagesArray = [dict objectForKey:@"data"];
                            
                            NSLog(@"%d", (int)pagesArray.count);
                            
                            
                            
                            if (pagesArray.count  == 0)
                            {
                                [dicChange setObject:[NSNumber numberWithBool:YES] forKey:@"POSTTOWALL"];
                                [dicChange setObject:@"" forKey:@"PAGEID"];
                                [dicChange setObject:@"" forKey:@"PAGENAME"];
                                [dicChange setObject:@"" forKey:@"TOKEN"];
                                
                                [self doAlertViewWithTextView:dicChange];
                            }
                            else{
                                
                                NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
                                NSString * choose_fb_pageId = [userInfo objectForKey:@"facebook_page_id"];
                                
                                
                                NSString * facebookPageId, * token = nil, * pagename;
                                
                                for (NSDictionary * dic in pagesArray) {
                                    
                                    facebookPageId = [dic objectForKey:@"id"];
                                    
                                    if ([facebookPageId isEqualToString:choose_fb_pageId]) {
                                        
                                        token = [dic objectForKey:@"access_token"];
                                        pagename = [dic objectForKey:@"name"];
                                        break;
                                    }
                                }
                                
                                if (token == nil) {
                                    [dicChange setObject:[NSNumber numberWithBool:YES] forKey:@"POSTTOWALL"];
                                    [dicChange setObject:@"" forKey:@"PAGEID"];
                                    [dicChange setObject:@"" forKey:@"PAGENAME"];
                                    [dicChange setObject:@"" forKey:@"TOKEN"];
                                }
                                else {
                                    [dicChange setObject:[NSNumber numberWithBool:NO] forKey:@"POSTTOWALL"];
                                    [dicChange setObject:facebookPageId forKey:@"PAGEID"];
                                    [dicChange setObject:pagename forKey:@"PAGENAME"];
                                    [dicChange setObject:token forKey:@"TOKEN"];
                                }
                                
                                [self doAlertViewWithTextView:dicChange];
                                
                            }
                        }else {
                            [FBShareController displayFBerrorMsg:error msgTitle:@"Share Error"];
                        }
                    }];

}



-(void) postWallwithText:(NSDictionary*) dicPost
{
    NSString* imageUrl = dicPost[@"IMAGEURL"];
    if (imageUrl.length < 1) {
        imageUrl = @"http://bit.ly/UbzmG9";
//        imageUrl = SHARE_APP_LOGO;
    }
    else {

    }
    imageUrl =  [imageUrl stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    
    NSString * postText = dicPost[@"TEXT"];
    NSString * postType = dicPost[@"POSTTYPE"];
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    NSString *link = dicPost[@"DEEPLINK"];
    
    if ((link != nil || link.length > 0) && [postType isEqual: @"photo"]){
        link = dicPost[@"url_link"];
    }
    

    if (link.length < 1) {

        NSString * contentId = dicPost[@"CONTENTID"];

        link = [NSString stringWithFormat:@"%@/%@/%@", DEEPLINK_WEB_URL, postType, contentId];
    }
//    NSString * link = [NSString stringWithFormat:@"%@://%d/%@/%@", DEEPLINK_APP_URL, CID, dicPost[@"POSTTYPE"], dicPost[@"CONTENTID"]];
    
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       postText, @"message",
                       appName, @"name",
                       postText, @"caption",
                       @"TYRESE.STARSITE.COM", @"description",
                       link, @"link",
                       imageUrl, @"picture",
                       nil];

    
#ifndef DISABLE_BC_FB_WIN
    
    if ([dicPost[@"POSTTYPE"]  isEqual: @"video"]){
        link = [NSString stringWithFormat:@"%@%@", BC_FB_PLAYWINURL, dicPost[@"CONTENTID"]];
        
        
                       params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       postText, @"message",
                       appName, @"name",
                       //  postText, @"caption",
                       // @"TYRESE.STARSITE.COM", @"description",
                       link, @"link",
                       //     imageUrl, @"picture",
                       nil];
}
   
    
#endif
    
    // Make the request
   
    [FBRequestConnection startWithGraphPath:@"/me/feed"
     parameters:params
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
          
      if (!error) {
          // Link posted successfully to Facebook
          NSLog(@"result: %@", result);
          [StarTracker StarSendEvent:@"App Event" :@"Facebook Result" :result];
          NSString* msg = @"Syndicated to Facebook!";
          if (!m_bDraft) {
              UIAlertView *alertView = [[UIAlertView alloc]
                                        initWithTitle:@""
                                        message:msg
                                        delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
              [alertView show];
          }
          else {
              [self facebookPostDone:msg];
          }
          

 //     } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions){
//          [self postWebDialogWithLink:dicPost];
      }else {
          [FBShareController displayFBerrorMsg:error msgTitle:@"Share Error"];
      }
  }];

}


-(void) postWallwithPhoto:(NSDictionary*) dicPost
{
    NSString* imageUrl = dicPost[@"IMAGEURL"];
    if (imageUrl == nil && imageUrl.length < 1) {
        //        imageUrl = @"http://bit.ly/UbzmG9";
        imageUrl = SHARE_APP_LOGO;
    }
    else {

    }
    
    imageUrl =  [imageUrl stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    
    NSString * postText = dicPost[@"TEXT"];
    NSString * postType = dicPost[@"POSTTYPE"];
 //   NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    NSString *urllink = dicPost[@"url_link"];
    NSString *link = dicPost[@"DEEPLINK"];
    
    if (urllink.length > 0 && [postType isEqualToString: @"photo"]){
        link = urllink;
    }

    if (link.length < 1) {
        NSString * contentId = dicPost[@"CONTENTID"];
        
        link = [NSString stringWithFormat:@"%@/%@/%@", DEEPLINK_WEB_URL, postType, contentId];
    }
    //    NSString * link = [NSString stringWithFormat:@"%@://%d/%@/%@", DEEPLINK_APP_URL, CID, dicPost[@"POSTTYPE"], dicPost[@"CONTENTID"]];
    
   postText = [postText stringByAppendingString:@"\n\n"];
   postText = [postText stringByAppendingString:link];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
   //                                appName,@"name",
                                   postText, @"message",
                                   imageUrl, @"url",
                                   nil];
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"

                          completionHandler:^(FBRequestConnection * connection, id result, NSError *error)
                            {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                                  [StarTracker StarSendEvent:@"App Event" :@"Facebook Result" :result];
                                  NSString* msg = @"Syndicated to Facebook!";
                                  if (!m_bDraft) {
                                      UIAlertView *alertView = [[UIAlertView alloc]
                                                                initWithTitle:@""
                                                                message:msg
                                                                delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                                      [alertView show];
                                  }
                                  else {
                                      [self facebookPostDone:msg];
                                  }
                                  
  //                            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions){
  //                                [self postWebDialogWithPhoto:dicPost];
                              }else {
                                    [FBShareController displayFBerrorMsg:error msgTitle:@"Share Error"];
                              }
                          }];
    
  }




-(void) postWebDialogWithPhoto:dicPost
{
    
    // Prepare the web dialog parameters
    
    NSString *linkurl = dicPost[@"DEEPLINK"];
    

    NSString *txt = dicPost[@"TEXT"];
    NSString *picurl = dicPost[@"IMAGEURL"];

    
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    txt = [txt stringByAppendingString:@"\n\n"];
    txt = [txt stringByAppendingString:linkurl];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appName,@"name",
                                   linkurl, @"caption",
                                   txt, @"description",
                                   picurl, @"picture",
                                   nil];
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      [FBShareController displayFBerrorMsg:error msgTitle:@"Shared Dialog Error"];
                                                  }
                                                  
                                                  if (result == FBWebDialogResultDialogCompleted) {
                                                      [self facebookPostDone:@"Syndicated to Facebook!"];
                                                  }else {
                                                      [self facebookPostDone:@"Not Syndicated!"];
                                                  }
                                              }];
    
}



-(void) postWebDialogWithLink:dicPost
{
     
     // Prepare the web dialog parameters
    
    
    NSString *linkurl = dicPost[@"DEEPLINK"];
    

     NSString *txt = dicPost[@"TEXT"];
     NSString *picurl = dicPost[@"IMAGEURL"];
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
     
     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     appName, @"name",
                     @" ", @"caption",
                     txt, @"description",
                     linkurl, @"link",
                     picurl, @"picture",
                     nil];
                     
     // Show the feed dialog
     [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
             parameters:params
             handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
     if (error) {
             [FBShareController displayFBerrorMsg:error msgTitle:@"Shared Dialog Error"];
     }
     
     if (result == FBWebDialogResultDialogCompleted) {
         [self facebookPostDone:@"Syndicated to Facebook!"];
     }else {
         [self facebookPostDone:@"Not Syndicated!"];
     }
     }];

}



-(void) postLinkWithPageId:(NSDictionary*) dicPost
{
    NSString* imageUrl = dicPost[@"IMAGEURL"];
    if (imageUrl.length < 1) {
        //        imageUrl = @"http://bit.ly/UbzmG9";
        imageUrl = SHARE_APP_LOGO;
    }

    
    imageUrl =  [imageUrl stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    NSString *link = dicPost[@"DEEPLINK"];
    

    if (link.length < 1) {
        NSString * postType = dicPost[@"POSTTYPE"];
        NSString * contentId = dicPost[@"CONTENTID"];
        
        link = [NSString stringWithFormat:@"%@/%@/%@", DEEPLINK_WEB_URL, postType, contentId];
    }
//    NSString * link = [NSString stringWithFormat:@"%@://%d/%@/%@", DEEPLINK_APP_URL, CID, dicPost[@"POSTTYPE"], dicPost[@"CONTENTID"]];
    m_strFBPageName = dicPost[@"PAGENAME"];
    
    
    NSString * path = [NSString stringWithFormat:@"https://graph.facebook.com/%@/feed", dicPost[@"PAGEID"]];
    
    NSURL *urlPath = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:urlPath];

    
    [request setPostValue:dicPost[@"TEXT"] forKey:@"message"];
    [request setPostValue:dicPost[@"TOKEN"] forKey:@"access_token"];
    [request setPostValue:appName forKey:@"name"];
    //   [request setPostValue:@"Build great social apps and get more installs." forKey:@"caption"];
    [request setPostValue:dicPost[@"TEXT"] forKey:@"caption"];
    [request setPostValue:link forKey:@"link"];
    [request setPostValue:imageUrl forKey:@"picture"];

    
#ifndef DISABLE_BC_FB_WIN
    if ([dicPost[@"POSTTYPE"]  isEqual: @"video"]){
        link = [NSString stringWithFormat:@"%@%@", BC_FB_PLAYWINURL, dicPost[@"CONTENTID"]];

    [request setPostValue:dicPost[@"TEXT"] forKey:@"message"];
    [request setPostValue:dicPost[@"TOKEN"] forKey:@"access_token"];
    [request setPostValue:appName forKey:@"name"];
 //   [request setPostValue:@"Build great social apps and get more installs." forKey:@"caption"];
 //   [request setPostValue:dicPost[@"TEXT"] forKey:@"caption"];
    [request setPostValue:link forKey:@"link"];
  //  [request setPostValue:imageUrl forKey:@"picture"];
        
    }
#endif
    
    
    
    
    [request setDidFinishSelector:@selector(sendToPhotosFinished:)];
    [request setDelegate:self];
    [request startAsynchronous];
    

}

-(void) postPhotoWithPageId:(NSDictionary*) dicPost
{
    m_strFBPageName = dicPost[@"PAGENAME"];
    
    NSString * path = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos", dicPost[@"PAGEID"]];

    NSURL *urlPath = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:urlPath];
    NSData *imgData = [[NSData alloc] initWithData: UIImagePNGRepresentation(dicPost[@"IMAGE"])];
    if (imgData != nil) {
        [request setData:imgData withFileName:@"picture.png" andContentType:@"image/png" forKey:@"source"];
    }
    
    NSString * postType = dicPost[@"POSTTYPE"];
    NSString *urllink = dicPost[@"url_link"];
    NSString *link = dicPost[@"DEEPLINK"];
    
    if (urllink.length > 0 && [postType isEqualToString: @"photo"]){
        link = urllink;
    }


    if (link.length < 1) {
        NSString * contentId = dicPost[@"CONTENTID"];
        
        link = [NSString stringWithFormat:@"%@/%@/%@", DEEPLINK_WEB_URL, postType, contentId];
    }
    
    NSString * linkMsg = [dicPost[@"TEXT"] stringByAppendingString:@"\n\n"];
    linkMsg = [linkMsg stringByAppendingString:link];
    
    
    [request setPostValue:linkMsg forKey:@"message"];
    [request setPostValue:dicPost[@"TOKEN"] forKey:@"access_token"];
    [request setDidFinishSelector:@selector(sendToPhotosFinished:)];
    
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)sendToPhotosFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    
    NSMutableDictionary *responseJSON = [responseString JSONValue];
    NSString *postId = [responseJSON objectForKey:@"id"];
    NSLog(@"Post id is: %@", postId);
    
    
    NSString * msg = [NSString stringWithFormat:@"Syndicated to %@ page!", m_strFBPageName];
    if (!m_bDraft) {
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@""
                           message:msg
                           delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
        [av show];
    }
    else {
        [self facebookPostDone:msg];
    }
    
}


-(void) onFacebook:(NSMutableDictionary*) dicPost
{
//    if ([Global getUserType] != FAN) {
//        [self showMessage:@"" message:@"Mobile admin can not use this function" delegate:nil firstBtn:@"OK" secondBtn:nil];
//        return;
//    }
    
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    BOOL bFacebook = [[userInfo objectForKey:@"enable_facebook"] boolValue];
    if (!bFacebook) {
        [self showMessage:@"" message:@"Please Enable Social Sharing in Settings" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
 

    NSString * postType = dicPost[@"POSTTYPE"];
    if ([postType isEqualToString:@"video"]) { // add play_icon
        NSString * imageUrl = dicPost[@"IMAGEURL"];
#ifdef DISABLE_BC_FB_WIN
        imageUrl = [imageUrl stringByAppendingString:@"&icon=1"];
#endif
        [dicPost setObject:imageUrl forKey:@"IMAGEURL"];
    }

            [self onFacebookAdmin:dicPost];

    
}





-(void) onTwitter:(NSDictionary*) dicPost
{
//    if ([Global getUserType] != FAN) {
//        [self showMessage:@"" message:@"Mobile admin can not use this function" delegate:nil firstBtn:@"OK" secondBtn:nil];
//        return;
//    }

    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    BOOL bTwitter  = [[userInfo objectForKey:@"enable_twitter"] boolValue];
    if (!bTwitter) {
        [self showMessage:@"" message:@"Please Enable Twitter Social Sharing in Settings" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        NSString * text = dicPost[@"TEXT"];
        NSUInteger maxlength = 68;
        NSLog (@"Twitter String length is %i", (int)text.length);
        if (text.length > maxlength) {
            text = [text substringToIndex:maxlength];
        }
        NSLog (@"Twitter String length is %i", (int)text.length);
        NSString * postType = dicPost[@"POSTTYPE"];
        NSString *urllink = dicPost[@"url_link"];
        text = [text stringByAppendingString:@"\n\n"];
        text = [text stringByAppendingString:dicPost[@"DEEPLINK"]];
        NSString *url = dicPost[@"DEEPLINK"];
        
        if (urllink.length > 0 && [postType isEqualToString: @"photo"]){
            url = urllink;
        }

        
        UIImage * image = dicPost[@"IMAGE"];

        if ([postType isEqualToString:@"video"]) { // add play_icon
            NSString * imageUrl = dicPost[@"IMAGEURL"];
            

            imageUrl = [imageUrl stringByAppendingString:@"&icon=1"];

            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            image = [UIImage imageWithData:data];
        }
        
        
        if (image == nil) {
            image = [UIImage imageNamed:@"starclub-logo.jpg"];
        }
        
        
//        if (image == nil) {
//            image = [UIImage imageNamed:SHARE_APP_LOGO];
//        }
        
        if (m_bIsCustomCaptionTw) {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            if (text != nil && text.length > 0) {
                [tweetSheet setInitialText:text];
            }
            
            if (url != nil && url.length > 0) {
                [tweetSheet addURL:[NSURL URLWithString:url]];
            }
            
            if (image != nil) {
                [tweetSheet addImage:image];
            }
            
            
            [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Post Canceled");
                        
                        if (m_bDraft) {
                            [StarTracker StarSendEvent:@"App Event" :@"Twitter Post Cancelled" :@"Fan Action"];
                            [self twitterPostDone:@"Twitter share cancelled!"];
                        }
                        
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Post Sucessful");
                        
                        if (!m_bDraft) {
                            UIAlertView *av = [[UIAlertView alloc]
                                               initWithTitle:@""
                                               message:@"Post to Twitter Successful!"
                                               delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
                            [av show];
                        }
                        else {
                            [self twitterPostDone:@"Post to Twitter Successful!"];
                        }
                        
                        break;
                        
                    default:
                        break;
                }
            }];
            
            [self presentViewController:tweetSheet animated:YES completion:^{
                
            }];
        }
        else {
            if ([postType isEqualToString:@"text"]) { // only text
                image = nil;
            }

                [self postTwitterDirect:image withStatus:text];
        }
        
        
        [StarTracker StarSendEvent:@"App Event" :@"Twitter Post" :@"Fan Action"];
    }
    else
    {

        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error!"
                                  message:@"You are not signed in to Twitter !/nTwitter App or Account /nin Phone - Settings->Twitter"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) postTwitterDirect:(UIImage *)image withStatus:(NSString *)status
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler =
        ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self sendmsgTwitterDone:@"Post to Twitter Successful!"];
                });
                
                
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self sendmsgTwitterDone:@"Twitter share cancelled!"];
                });
                
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
            
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self sendmsgTwitterDone:@"Twitter share cancelled!"];
            });
            
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
        ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                          @"/1.1/statuses/"];
            if (image == nil) {
             url = [url URLByAppendingPathComponent:@"update.json"];
            } else {
             url = [url URLByAppendingPathComponent:@"update_with_media.json"];
            }
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
            
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self sendmsgTwitterDone:@"Twitter authorization problem\nplease check\niPhone - Settings->Twitter"];
            });
            
        }
    };
    
    [accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}
-(void) sendmsgTwitterDone:(NSString*) msg
{
    if (!m_bDraft) {
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@""
                           message:msg
                           delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
        [av show];
    }
    else {
        
        [self twitterPostDone:msg];
    }
}

-(void)onInstagram:(NSDictionary*) dicPost
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        UIImage* image = dicPost[@"IMAGE"];
        NSString * postType = dicPost[@"POSTTYPE"];
        if ([postType isEqualToString:@"video"]) { // add play_icon
            NSString * imageUrl = dicPost[@"IMAGEURL"];
#ifdef DISABLE_BC_FB_WIN
            imageUrl = [imageUrl stringByAppendingString:@"&icon=1"];
#endif
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            image = [UIImage imageWithData:data];
        }
        
        

        if (image == nil) {
            [self instagramPostDone:@"Only images can be syndicated\nto Instagram"];
            return;
        }
        
        
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
//                                                             message:@"Only images can be syndicated\nto Instagram"
//                                                            delegate:nil
 //                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];


        
        NSString * savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.igo"];
        [UIImagePNGRepresentation(image) writeToFile:savePath atomically:YES];
        
        CGRect rect = CGRectMake(0, 0, 0, 0);
        NSString * jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.igo"];
        NSURL * igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath ]];

//        self.docFile.UTI = @"com.instagram.photo";
        self.docFile.UTI = @"com.instagram.exclusivegram";

        NSString *text = dicPost[@"TEXT"];
        text = [text stringByAppendingString:@"\n\n"];
        text = [text stringByAppendingString:dicPost[@"DEEPLINK"]];

        self.docFile = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
        self.docFile = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        self.docFile.annotation = [NSDictionary dictionaryWithObject:text forKey:@"InstagramCaption"];
        // OPEN THE HOOK
        [self.docFile presentOpenInMenuFromRect:rect inView:self.view animated:YES];
        
        [StarTracker StarSendEvent:@"App Event" :@"Instagram Post" :@"Fan Action"];
        
//        NSURL *myURL = [NSURL URLWithString:@"instagram://com.instagram.exclusivegram?file://Documents/Test.igo"];
//        [[UIApplication sharedApplication] openURL:myURL];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Instagram not installed on this device!\nTo share image please install Instagram."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}
- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}


#pragma mark -
#pragma basic player

-(void) playVideo:(NSString*) fileName
{
    NSURL *url=[[NSURL alloc] initWithString:fileName];
    moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:url];
    
    NSString *base64String = [ fileName base64EncodedString];
    
    [StarTracker StarSendEvent:@"App Event" :@"SC Hosted Video Requested" : base64String];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStarted:) name:MPMoviePlayerWillEnterFullscreenNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDonePressed:) name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
    
    moviePlayer.controlStyle=MPMovieControlStyleDefault;
//    moviePlayer.shouldAutoplay=NO;
    [moviePlayer play];
    [self.view addSubview:moviePlayer.view];
    [moviePlayer setFullscreen:YES animated:YES];
}

-(void)videoStarted:(NSNotification *)notification{
    
    
    // Entered Fullscreen code goes here..
    GHAppDelegate *appDelegate = APPDELEGATE;
    appDelegate.fullScreenVideoIsPlaying = YES;
    
}
-(void)videoFinished:(NSNotification *)notification{
    
    [StarTracker StarSendEvent:@"App Event" :@"SC Hosted Video" : @"Finished"];
    // Left fullscreen code goes here...
    GHAppDelegate *appDelegate = APPDELEGATE;
    appDelegate.fullScreenVideoIsPlaying = NO;
    
    //CODE BELOW FORCES APP BACK TO PORTRAIT ORIENTATION ONCE YOU LEAVE VIDEO.
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    //present/dismiss viewcontroller in order to activate rotating.
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentViewController:mVC animated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];

}

- (void) moviePlayBackDonePressed:(NSNotification*)notification
{
    [StarTracker StarSendEvent:@"App Event" :@"SC Hosted Video" : @"Stopped"];
    
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
    
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [moviePlayer.view removeFromSuperview];
    }
    moviePlayer=nil;
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [moviePlayer setFullscreen:NO animated:YES];
        [moviePlayer.view removeFromSuperview];
    }
}


#pragma mark -
#pragma CREDIT
-(void) gotoBuyCredit {
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                    message: @"Please choose a credit option"
                                                   delegate: self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Credit Card", @"In-app Purchase", nil];
    alert.tag = 105;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 105) {
        if (buttonIndex == 1) { // credit
            
        }
        else if (buttonIndex == 2) {
            BuyCreditController * pController = [[BuyCreditController alloc] init];
            [self onPush:pController];
            
        }
    }
}


#pragma mark -
#pragma mark Loading

- (void) showLoading : (NSString*) label
{
    if (self.navigationController.view == nil) {
        return;
    }

    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
    }
    HUD.labelText = label;

    HUD.delegate = self;
	
    [HUD show:YES];
    
	// Show the HUD while the provided method executes in a new thread
//	[HUD showWhileExecuting:@selector(myTask) onTarget:nil withObject:nil animated:YES];
}
-(void)  showChangeLabel:(NSString*) label
{
    HUD.labelText = label;
}

- (void) showFail {
    
    [self showFail:@"Network Communication Issue!"];

}
- (void) showFail:(NSString*) label {

    if (self.navigationController.view == nil) {
        return;
    }

    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        
        [HUD show:YES];
    }
    
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = label;
    
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    
}


- (void)showWithCustomView:(NSString * ) label {
    if (self.navigationController.view == nil) {
        return;
    }

    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
    }
	
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
	HUD.labelText = label;
	
	[HUD show:YES];
    
//	[HUD hide:YES afterDelay:3];
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    
}
-(void) myTask {
    sleep(2);
}

- (void) hideLoading
{
    [HUD hide:YES];
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}


// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    //    self.profilePictureView.profileID = nil;
    //    self.nameLabel.text = @"";
    //    self.statusLabel.text= @"You're not logged in!";
    NSLog(@"You're not logged in!");
 //   bLoggedIn = NO;
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        [StarTracker StarSendEvent:@"App Event" :@"Login" :@"FB Login Error"];
        alertTitle  = @"Facebook COmmunication Issues";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
