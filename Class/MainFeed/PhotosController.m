//
//  PhotosController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/30/13.
//
//

#import "PhotosController.h"
#import "PhotoDetailController.h"
#import "DLImageLoader.h"

#import "RTFlyoutMenu.h"
#import "RTFlyoutItem.h"

#import "PhotoListController.h"

#import "StarTracker.h"


#define frameWidth  60
#define frameHeight 36
#define MAX_ITEM  4

@interface PhotosController ()<UIScrollViewDelegate, RTFlyoutMenuDelegate, RTFlyoutMenuDataSource>
{
    IBOutlet UIView * viewToolBar;
    IBOutlet UIScrollView * scrollTitle;
    IBOutlet UIScrollView * scrollImage;
    int lastScrolledOffset;
    int m_nSelectBtn;
    
    BOOL    bLoaded;
    
    NSMutableArray * arrTitles;
    
    NSMutableArray * arrOrgImages;
    NSMutableArray * arrImages;
}

@property (strong, nonatomic) RTFlyoutMenu *flyoutMenu;

@property (nonatomic) NSArray *mainItems;
@property (nonatomic) NSArray *subItems;


@end

@implementation PhotosController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [StarTracker StarSendView:@"Photo Gallery"];
    
    scrollTitle.pagingEnabled = YES;
	scrollTitle.showsHorizontalScrollIndicator = NO;
    
    arrTitles = [[NSMutableArray alloc] init];
    
    m_nSelectBtn = 0;
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.automaticallyAdjustsScrollViewInsets = false;

    if (!bLoaded) {
        bLoaded = YES;

        [self getPhotoGallery];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getPhotoGallery{

    [self showLoading:@"Loading"];

    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
    NSString * urlString = [MyUrl getPhotoGallery];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        
        [self hideLoading];
        
        arrOrgImages = [result objectForKey:@"photos"];
        arrImages = [[NSMutableArray alloc] initWithArray:arrOrgImages];
    
        arrTitles = [result objectForKey:@"filters"];
        
    }
    else {
        NSString * ErrMessage = [result objectForKey:@"message"];
        [self showFail:ErrMessage];
    }
    
    [self performSelectorOnMainThread:@selector(refreshScrollView) withObject:nil waitUntilDone:YES];

}

- (void) refreshScrollView
{
//        [self setTitleScroll];
    [self setToolMenu];
    [self setImageScroll];
    
}
#pragma mark -
#pragma mark ToolMenu
-(void) setToolMenu
{
    [[viewToolBar subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.mainItems = [[NSArray alloc] initWithObjects:[arrTitles firstObject], nil];
    self.subItems = [[NSArray alloc] initWithObjects:arrTitles, nil];
    
    NSDictionary *options = @{
                              RTFlyoutMenuUIOptionInnerItemSize: [NSValue valueWithCGSize:CGSizeMake(22, 22)],
                              RTFlyoutMenuUIOptionSubItemPaddings: [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(10, 15, 10, 15)]
                              };
	RTFlyoutMenu *m = [[RTFlyoutMenu alloc] initWithDelegate:self dataSource:self position:kRTFlyoutMenuPositionTop options:options];
	m.canvasView = self.view;
    
	CGRect mf = CGRectMake(5, 0, 50, 36);
	m.frame = mf;
    
    //	m.backgroundColor = [UIColor redColor];

	[viewToolBar addSubview:m];
	self.flyoutMenu = m;
    
	//	look & feel
	[[RTFlyoutItem appearanceWhenContainedIn:[viewToolBar class], nil] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[[RTFlyoutItem appearanceWhenContainedIn:[viewToolBar class], nil] setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];

}


#pragma mark - RTFlyoutMenuDataSource

- (NSUInteger)numberOfMainItemsInFlyoutMenu:(RTFlyoutMenu *)flyoutMenu {
	return [self.mainItems count];
}

- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForMainItem:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return nil;
    
	return [self.mainItems objectAtIndex:mainItemIndex];
}

- (NSUInteger)flyoutMenu:(RTFlyoutMenu *)flyoutMenu numberOfItemsInSubmenu:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return 0;
    
    NSArray * array = [self.subItems objectAtIndex:mainItemIndex];
	return [array count];
}

- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForSubItem:(NSUInteger)subItemIndex inMainItem:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return nil;

    NSArray * array = [self.subItems objectAtIndex:mainItemIndex];
	if (subItemIndex >= [array count]) return nil;
    
	return [[self.subItems objectAtIndex:mainItemIndex] objectAtIndex:subItemIndex];
}


#pragma mark - RTFlyoutMenuDelegate

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectMainItemWithIndex:(NSInteger)index {
//    NSLog(@"Tap on main item: %d", index);
}

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectSubItemWithIndex:(NSInteger)subIndex mainMenuItemIndex:(NSInteger)mainIndex {
//    NSLog(@"Tap on main/sub index: %d / %d", mainIndex, subIndex);
    
    if (subIndex >= 0) {
        m_nSelectBtn = (int)subIndex;
        [self change];
    }
    
}

- (void)didReloadFlyoutMenu:(RTFlyoutMenu *)flyoutMenu {
//	[self recenterFlyoutMenu];
}


#pragma mark -

-(void) setTitleScroll
{
    
    int count = (int)[arrTitles count];
    
	for (int i = 0; i < count; i ++) {
        CGRect frame = CGRectMake(frameWidth * i, 0, frameWidth, frameHeight);

        UIButton * lbTitle = [[UIButton alloc] initWithFrame:frame];
        lbTitle.titleLabel.font = [UIFont fontWithName:FONT_NAME size:14.0f];
        [lbTitle setTitle:[arrTitles objectAtIndex:i] forState:UIControlStateNormal];
        [lbTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        lbTitle.tag = i;
        [lbTitle addTarget:self
    				action:@selector(didPushButton:)
    	  forControlEvents:UIControlEventTouchUpInside];

        if (i == m_nSelectBtn){
//            [lbTitle setTransform:CGAffineTransformMakeScale(2, 2)];
            lbTitle.titleLabel.font = [UIFont fontWithName:FONT_NAME_BOLD size:16.0f];
        }
        else {
//            [lbTitle setAlpha:0.5];
            lbTitle.titleLabel.font = [UIFont fontWithName:FONT_NAME size:14.0f];
        }
        
        [scrollTitle addSubview:lbTitle];
    }
    
    [scrollTitle setContentSize:CGSizeMake(frameWidth * count, scrollTitle.frame.size.height)];
    
    lastScrolledOffset = 0;
    
    if (m_nSelectBtn / MAX_ITEM == 0) {
        lastScrolledOffset = 0;
    }
    else {
        lastScrolledOffset = scrollTitle.frame.size.width * (m_nSelectBtn/MAX_ITEM);
    }
    [scrollTitle setContentOffset:CGPointMake(lastScrolledOffset, 0) animated:NO];
    
}
#define INTERVAL    5
#define WIDTH       100

-(void) setImageScroll
{
    [[scrollImage subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int nPosX = INTERVAL, nPosY = INTERVAL;
    
    for( int i = 0; i < (int)[arrImages count]; i++ ){
        
        if( i % 3 == 0 ){
            
            nPosX = INTERVAL;
            if( i / 3 != 0 )
                nPosY   += ( INTERVAL + WIDTH );

            BOOL bBanner = NO;
            if (i % 9 == 0 && i != 0) {
                bBanner = YES;
            }
            
            if (bBanner) {
#ifdef GOOGLE_DFP
                DFPBannerView *bannerView = [[DFPSwipeableBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
                
#elif defined(GOOGLE_DFP_SWIPE)
                DFPSwipeableBannerView *bannerView = [[DFPSwipeableBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
#else
                GADBannerView * bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
#endif
                bannerView.frame = CGRectMake(0, nPosY, 320, 50);
                // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
                
                int nId = i/9;
                if (nId % 3 == 0) {
                    bannerView.adUnitID = ADMOB_PHOTO_GRID_ID_1;
                } else if (nId % 3 == 1) {
                    bannerView.adUnitID = ADMOB_PHOTO_GRID_ID_2;
                } else {
                    bannerView.adUnitID = ADMOB_PHOTO_GRID_ID_3;
                }
                bannerView.rootViewController = self;
                
                GADRequest *request = [GADRequest request];
                [bannerView loadRequest:request];
                
                [scrollImage addSubview:bannerView];
                
                nPosY += 50 + INTERVAL;
            }

        }
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.color = [UIColor blackColor];
		spinner.frame = CGRectMake(nPosX + round(WIDTH/2 - spinner.frame.size.width/2),
                                   nPosY + round(WIDTH/2 - spinner.frame.size.height/2),
                                   spinner.frame.size.width,
                                   spinner.frame.size.height);
        
        [spinner startAnimating];
        [scrollImage addSubview:spinner];

        
        UIImageView * imgTexture = [[UIImageView alloc] initWithFrame:CGRectMake( nPosX, nPosY, WIDTH, WIDTH ) ];
        [imgTexture setContentMode:UIViewContentModeScaleAspectFill];
        [imgTexture setClipsToBounds:YES];
//        [ imgTexture setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpeg", i+1]]];
//        [imgTexture loadFromURL:[NSURL URLWithString:[arrImages objectAtIndex:i]]];
        
        NSDictionary * dic = [arrImages objectAtIndex:i];
        
        NSString * urlString = [dic objectForKey:@"img_small_thumb"];
        [DLImageLoader loadImageFromURL:urlString
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      imgTexture.image = [UIImage imageWithData:imgData];
                                  } else {
                                      // if we got error when load image
                                  }
                              }];

        
        imgTexture.tag  =   i + BTN_PHOTO_ID;
        imgTexture.userInteractionEnabled = YES;
        
        [scrollImage addSubview: imgTexture ];

        int nCreditWant = [[dic objectForKey:@"credit"] intValue];
        BOOL bUnlocked = [[dic objectForKey:@"unlock"] boolValue];
        
        if (nCreditWant == 0 || bUnlocked) {
        } else {
            UIImageView * imgLock = [[UIImageView alloc] initWithFrame:CGRectMake( nPosX, nPosY, WIDTH, WIDTH ) ];
            [imgLock setImage:[UIImage imageNamed:@"lock_thumb.png"]];
            [scrollImage addSubview: imgLock];
        }

        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
//        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        [imgTexture addGestureRecognizer:tapGesture];
        
        nPosX += ( INTERVAL + WIDTH );
    }
    
    nPosY += WIDTH + INTERVAL;
    
    if (([arrImages count]) % 9 == 0 && [arrImages count] != 0) {
#ifdef GOOGLE_DFP
        DFPBannerView *bannerView = [[DFPSwipeableBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        
#elif defined(GOOGLE_DFP_SWIPE)
        DFPSwipeableBannerView *bannerView = [[DFPSwipeableBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
#else
        GADBannerView * bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
#endif
        bannerView.frame = CGRectMake(0, nPosY, 320, 50);
        // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
        bannerView.adUnitID = ADMOB_PHOTO_GRID_ID_1;
        bannerView.rootViewController = self;
        
        GADRequest *request = [GADRequest request];
        [bannerView loadRequest:request];
        
        [scrollImage addSubview:bannerView];
        
        nPosY += 50;
    }

    scrollImage.contentSize = CGSizeMake(scrollImage.frame.size.width, nPosY);
}

- (void) tapDetected:(UITapGestureRecognizer*) gesture
{
    UIImageView * view = (UIImageView*) gesture.view;
    int nSelIndex = (int)view.tag - BTN_PHOTO_ID;

    PhotoListController * pController = [[PhotoListController alloc] initWithIndexAndDatas:nSelIndex :arrImages];
    [super onPush:pController];
    
//    NSMutableDictionary * dic = [arrImages objectAtIndex:nSelIndex];
//    
//    
//    NSMutableDictionary * dicPhoto = [NSMutableDictionary new];
//    [dicPhoto setObject:[dic objectForKey:@"id"] forKey:CONTENTID];
//    [dicPhoto setObject:@"PhotoGallary" forKey:POSTTYPE];
//    [dicPhoto setObject:[dic objectForKey:@"description"] forKey:ID_PHOTO_CAPTION];
//    [dicPhoto setObject:[dic objectForKey:@"destination"] forKey:ID_PHOTO_URL];
//    
//    [super gotoPhotoDetail:dicPhoto];
}



-(IBAction)onClickPrev
{
    m_nSelectBtn = m_nSelectBtn == 0 ? 0 : m_nSelectBtn -1;
    
    if (m_nSelectBtn / MAX_ITEM == 0) {
        lastScrolledOffset = 0;
    }
    else {
        lastScrolledOffset = scrollTitle.frame.size.width * (m_nSelectBtn/MAX_ITEM);
    }
    [scrollTitle setContentOffset:CGPointMake(lastScrolledOffset, 0) animated:YES];

    [self changeButton];

}
-(IBAction) onClickNext
{
    int count = (int) [arrTitles count] - 1;
    m_nSelectBtn = (m_nSelectBtn == count) ? count : m_nSelectBtn +1;
    
    if (m_nSelectBtn / MAX_ITEM == 0) {
        lastScrolledOffset = 0;
    }
    else {
        lastScrolledOffset = scrollTitle.frame.size.width * (m_nSelectBtn/MAX_ITEM);
    }
    [scrollTitle setContentOffset:CGPointMake(lastScrolledOffset, 0) animated:YES];
    
    [self changeButton];

}
-(void) didPushButton:(UIButton*) sender
{
    int selTag = (int)sender.tag;
    
    m_nSelectBtn = selTag;
    
    [self changeButton];
}
-(void) changeButton{
    for (UIView *sub in [scrollTitle subviews])
    {
        if([sub isKindOfClass:[UIButton class]])
        {
            UIButton * btn = (UIButton*) sub;
            if (btn.tag == m_nSelectBtn) {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME_BOLD size:16.0f];
            }else {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME size:14.0f];
            }
            
        }
    }
    
    [self change];
}
-(void) change {
    
    [arrImages removeAllObjects];
    
    NSString * filter = [[arrTitles objectAtIndex:m_nSelectBtn] lowercaseString];
    if ([filter rangeOfString:@"all"].location != NSNotFound) {
        arrImages = [[NSMutableArray alloc] initWithArray:arrOrgImages];
    }
    else {
        for (NSDictionary * dic in arrOrgImages) {
            NSString * tag = [[dic objectForKey:@"tags"] lowercaseString];
            
            if ([filter rangeOfString:tag].location != NSNotFound) {
                [arrImages addObject:dic];
            }
        }
    }
    
    [self setImageScroll];
}

#pragma mark -
#pragma mark ScrollView delegate

//- (void)scrollViewDidScroll:(UIScrollView *)scroll_
//{
//	float width_ = scroll_.frame.size.width;

//    [Share shareInstance].nNoteBook = floor((scroll_.contentOffset.x - width_ / 3) / width_) + 1;
//    [mTitle setText:[NSString stringWithFormat:@"My Notebooks (%d of %d)", [Share shareInstance].nNoteBook + 1, [[Share shareInstance].arrNotebooks count]]];
    
//	CGFloat modulo = fmodf([scroll_ contentOffset].x, width_);
//	CGFloat x = modulo * 100 / width_;
//	CGFloat percent = 1 + 1 * x / 100;
//	int index = 0;
//	for (UIImageView *button_ in scroll_.subviews)
//	{
//		if (percent > 1.02)
//		{
//			if (index == floor([scroll_ contentOffset].x / width_)+1)
//			{
//				[button_ setTransform:CGAffineTransformMakeScale(percent, percent)];
//				[button_ setAlpha:percent/2];
//			}
//			else if (index == floor([scroll_ contentOffset].x / width_))
//			{
//				[button_ setTransform:CGAffineTransformMakeScale(2 - percent + 1,2 - percent + 1)];
//				[button_ setAlpha:(2-percent + 1)/2];
//			}
//		}
//		index++;
//		
//		CGRect frame_ = button_.frame;
//		frame_.origin.x += (scroll_.contentOffset.x - lastScrolledOffset)/2;
//		[button_ setFrame:frame_];
//	}
//	lastScrolledOffset = scroll_.contentOffset.x;
//}

@end
