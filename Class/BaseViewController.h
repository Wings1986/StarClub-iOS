//
//  BaseViewController.h
//  StarClub
//
//  Created by maya on 11/20/11.
//


#import "MBProgressHUD.h"


@interface BaseViewController : UIViewController<MBProgressHUDDelegate, UIActionSheetDelegate>
{

    MBProgressHUD *HUD;
    
    BOOL bLoaded;
    int m_nIndexShare;

    BOOL m_bDraft;
    BOOL m_bIsCustomCaptionFb;
    BOOL m_bIsCustomCaptionTw;
    BOOL m_bIsCustomCaptionInst;
}

- (void) onBack;
- (void) onPush:(UIViewController*) pController;


-(void) showMessage:(NSString*) title message:(NSString*) message delegate:(id) delegate firstBtn:(NSString*) first secondBtn:(NSString*) second;



-(void) onCommentFeed:(NSDictionary*) dic index:(int) index Delegate:(id) delegate;
-(void) onAddCommentFeed:(NSDictionary*) dic index:(int) index Delegate:(id) delegate;

-(void) onFacebook:(NSMutableDictionary*) dicPost;
-(void) onTwitter:(NSDictionary*) dicPost;
-(void) onInstagram:(NSDictionary*) dicPost;


-(void) onReportEmail:(NSArray*) emails content:(NSString*) body image:(UIImage*) image;

-(void) playVideo:(NSString*) fileName;


-(void) gotoBuyCredit;


//- (void) showLoading;
- (void) showLoading : (NSString*) label;
-(void)  showChangeLabel:(NSString*) label;
- (void) hideLoading;
- (void) showFail;
- (void) showFail:(NSString*) label;
- (void)showWithCustomView:(NSString * ) label;


-(void) facebookPostDone:(NSString*) msg;
//-(void) facebookPostFail:(NSString*) msg;
-(void) twitterPostDone:(NSString*) msg;
//-(void) twitterPostFail:(NSString*) msg;
-(void) instagramPostDone:(NSString*) msg;
//-(void) instagramPostFail:(NSString*) msg;

@end
