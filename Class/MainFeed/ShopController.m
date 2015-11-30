//
//  ShopController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/30/13.
//
//

#import "ShopController.h"
#import "DLImageLoader.h"
#import "ShopGridCell.h"
#import "ShopListCell.h"

#import "ViewCartController.h"

#import "RTFlyoutMenu.h"
#import "RTFlyoutItem.h"

#import "ProductDetailController.h"


typedef enum _TABLE_TYPE{
    TABLE_GRID,
    TABLE_LIST,
}TABLE_TYPE;

#define BTN_GRID_ID 100
#define BTN_LIST_ID 101
#define BTN_VIEWCART_ID 102

#define MAX_ITEM    4

@interface ShopController ()<RTFlyoutMenuDelegate, RTFlyoutMenuDataSource>
{
    
    IBOutlet UIScrollView * scrollTitle;
    IBOutlet UIView     * viewToolbar;
    
    int lastScrolledOffset;
    int m_nSelectBtn;
}

@property (nonatomic, assign) TABLE_TYPE    mType;
@property (nonatomic, strong) NSMutableArray * arrTitles;

@property (strong, nonatomic) RTFlyoutMenu *flyoutMenu;
@property (nonatomic) NSArray *mainItems;
@property (nonatomic) NSArray *subItems;

@end

@implementation ShopController

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
    
    scrollTitle.pagingEnabled = YES;
	scrollTitle.showsHorizontalScrollIndicator = NO;

    [self.mTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

    self.mType = TABLE_LIST;
    
    lastScrolledOffset = 0;
    m_nSelectBtn = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!bLoaded) {
        bLoaded = YES;

//        UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
//        [btnEdit setImage:[UIImage imageNamed:@"btn_checkout"] forState:UIControlStateNormal];
//        [btnEdit addTarget:self action:@selector(onCheckOut) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
//        self.navigationItem.rightBarButtonItem = btnItemEdit;
    }
    
    [self getShopList];

}
-(void)getShopList{
    
//    [super showLoading];

    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{

    NSString * urlString = [MyUrl getShop];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        
//        [super hideLoading];
        
        self.arrAllTableList = [result objectForKey:@"shops"];
        self.arrTitles = [result objectForKey:@"filters"];
        
        //[self setTitleScroll];
        [self setToolMenu];
        
        [self filtershop];
        
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
    
    [self getShopList];
}

- (void) doneLoadingTableViewData {
    [super doneLoadingTableViewData];
}


#pragma mark -
#pragma mark ToolMenu
-(void) setToolMenu
{
    self.mainItems = [[NSArray alloc] initWithObjects:[self.arrTitles firstObject], nil];
    self.subItems = [[NSArray alloc] initWithObjects:self.arrTitles, nil];
    
    NSDictionary *options = @{
                              RTFlyoutMenuUIOptionInnerItemSize: [NSValue valueWithCGSize:CGSizeMake(22, 22)],
                              RTFlyoutMenuUIOptionSubItemPaddings: [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(10, 15, 10, 15)]
                              };
	RTFlyoutMenu *m = [[RTFlyoutMenu alloc] initWithDelegate:self dataSource:self position:kRTFlyoutMenuPositionTop options:options];
	m.canvasView = self.view;
    
	CGRect mf = CGRectMake(20, 0, 50, 36);
	m.frame = mf;
    
    //	m.backgroundColor = [UIColor redColor];
	[viewToolbar addSubview:m];
	self.flyoutMenu = m;
    
	//	look & feel
	[[RTFlyoutItem appearanceWhenContainedIn:[viewToolbar class], nil] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[[RTFlyoutItem appearanceWhenContainedIn:[viewToolbar class], nil] setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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

}

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectSubItemWithIndex:(NSInteger)subIndex mainMenuItemIndex:(NSInteger)mainIndex {
    
    if (subIndex >= 0) {
        m_nSelectBtn = subIndex;
        [self filtershop];
        [self doneLoadingTableViewData];
    }
    
}

- (void)didReloadFlyoutMenu:(RTFlyoutMenu *)flyoutMenu {
    //	[self recenterFlyoutMenu];
}


-(void) setTitleScroll
{
#define frameWidth  60
#define frameHeight 36
    
    int count = [self.arrTitles count];
    
	for (int i = 0; i < count; i ++) {
        CGRect frame = CGRectMake(frameWidth * i, 0, frameWidth, frameHeight);
        
        UIButton * lbTitle = [[UIButton alloc] initWithFrame:frame];
        lbTitle.titleLabel.font = [UIFont fontWithName:FONT_NAME size:14.0f];
        [lbTitle setTitle:[self.arrTitles objectAtIndex:i] forState:UIControlStateNormal];
        [lbTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        lbTitle.tag = i;
        [lbTitle addTarget:self
    				action:@selector(didPushButton:)
    	  forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0){
            lbTitle.titleLabel.font = [UIFont fontWithName:FONT_NAME_BOLD size:16.0f];
        }
        else {
            lbTitle.titleLabel.font = [UIFont fontWithName:FONT_NAME size:14.0f];
        }
        
        [scrollTitle addSubview:lbTitle];
    }
    
    [scrollTitle setContentSize:CGSizeMake(frameWidth * count, scrollTitle.frame.size.height)];
    
    lastScrolledOffset = 0;
    
    //    if ([Share shareInstance].nNoteBook >= 0 && [Share shareInstance].nNoteBook <= [[Share shareInstance].arrNotebooks count]-1) {
    //        [mScrollView setContentOffset:CGPointMake(self.view.frame.size.width * [Share shareInstance].nNoteBook, 0) animated:YES];
    //    }
    
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
    int count = (int) [self.arrTitles count] - 1;
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
    int selTag = sender.tag;
    
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
    
}

-(void) onHeaderButton:(UIButton*) sender
{
    
    int selTag = sender.tag;
    
    UIView * parentView = sender.superview;
    
    for (UIView *sub in [parentView subviews])
    {
        if([sub isKindOfClass:[UIButton class]])
        {
            UIButton * btn = (UIButton*) sub;
            if (btn.tag == selTag) {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME_BOLD size:13.0f];
            }else {
                btn.titleLabel.font = [UIFont fontWithName:FONT_NAME size:12.0f];
            }
            
        }
    }

/*
    int oldType = self.mFeedType;

    switch (selTag-BTN_HEADER_ID) {
        case 0:
            self.mFeedType = TYPE_ALL;
            break;
        case 1:
            self.mFeedType = TYPE_TEXT;
            break;
        case 2:
            self.mFeedType = TYPE_PHOTO;
            break;
        case 3:
            self.mFeedType = TYPE_VIDEO;
            break;
        case 4:
            self.mFeedType = TYPE_QUIZ;
            break;
    }
    
    if (oldType != self.mFeedType) {
        
        [self filterFeed];
        
        [self.mTableView reloadData];
    }
*/
}
-(void) filtershop {
    
    [self.arrTableList removeAllObjects];
    
    NSString * filter = [[self.arrTitles objectAtIndex:m_nSelectBtn] lowercaseString];
    if ([filter rangeOfString:@"all"].location != NSNotFound) {
        self.arrTableList = [[NSMutableArray alloc] initWithArray:self.arrAllTableList];
    }
    else {
        for (NSDictionary * dic in self.arrAllTableList) {
            NSString * tag = [[dic objectForKey:@"tags"] lowercaseString];
            
            if ([filter rangeOfString:tag].location != NSNotFound) {
                [self.arrTableList addObject:dic];
            }
        }
    }
}

-(void) onToolButton:(UIButton*) sender
{
    
    int selTag = sender.tag;
    
    UIView * parentView = sender.superview;
    
    for (UIView *sub in [parentView subviews])
    {
        if([sub isKindOfClass:[UIButton class]])
        {
            UIButton * btn = (UIButton*) sub;
            if (btn.tag == selTag) {
                [btn setSelected:YES];
            }else {
                [btn setSelected:NO];
            }
            
        }
    }
    
    if (selTag == BTN_GRID_ID) {
        self.mType = TABLE_GRID;
        [self.mTableView reloadData];
    }
    else if (selTag == BTN_LIST_ID) {
        self.mType = TABLE_LIST;
        [self.mTableView reloadData];
    }
    else if (selTag == BTN_VIEWCART_ID) {
        
        ViewCartController * pController = [[ViewCartController alloc] init];
        [self onPush:pController];
    }
    
}
-(void) onCheckOut {
    
}
-(void) onAddtoCartButton:(UIButton*) sender {
 
    int nIndex = sender.tag - BTN_DETAIL_ID;
    
    NSDictionary * shopItem = [self.arrTableList objectAtIndex:nIndex];
    
    BOOL bAdded = NO;
    for (NSDictionary * item in GLOBAL.g_arrShopItem) {
        if ([[item objectForKey:@"id"] intValue] == [[shopItem objectForKey:@"id"] intValue]) {
            bAdded = YES;
            break;
        }
    }
    
    if (bAdded == NO) {
        [GLOBAL.g_arrShopItem addObject:shopItem];
        [self showMessage:@"Added" message:@"That item is added successfully!" delegate:nil firstBtn:@"OK" secondBtn:nil];
    } else {
        [self showMessage:@"Note" message:@"That item already is added!" delegate:nil firstBtn:@"OK" secondBtn:nil];
    }
    
}
-(void) onShopDetail:(UITapGestureRecognizer*) recognizer {
    UIImageView * view = (UIImageView*) recognizer.view;
    int nSelIndex = view.tag - BTN_PHOTO_ID;

    NSDictionary * shopItem = [self.arrTableList objectAtIndex:nSelIndex];
    
    ProductDetailController * pController = [[ProductDetailController alloc] initWithProduct:shopItem];
    [super onPush:pController];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.arrTableList count];
    if (self.mType == TABLE_LIST) {
        return count;
    }
    else {
        count = count == 0 ? 0 : round(count/2.0);
        return count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEADER_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, HEADER_HEIGHT)];
    view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
    
        /* Create custom view to display section header... */
    
    int btnWidth = 32;
    int btnHeight = 32;
    int posX = 15;
    int posY = 0;
    
    // List Button
    CGRect frame = CGRectMake(posX , posY, btnWidth, btnHeight);
    UIButton * btnList = [[UIButton alloc] initWithFrame:frame];
    btnList.tag = BTN_LIST_ID;
    [btnList setBackgroundImage:[UIImage imageNamed:@"btn_list_nor"] forState:UIControlStateNormal];
    [btnList setBackgroundImage:[UIImage imageNamed:@"btn_list_sel"] forState:UIControlStateHighlighted];
    [btnList setBackgroundImage:[UIImage imageNamed:@"btn_list_sel"] forState:UIControlStateSelected];
    [btnList addTarget:self
            action:@selector(onToolButton:)
  forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnList];

    
    // Grid Button
    posX = 55;
    posY = 0;
    frame = CGRectMake(posX , posY, btnWidth, btnHeight);
    UIButton * btnGrid = [[UIButton alloc] initWithFrame:frame];
    btnGrid.tag = BTN_GRID_ID;
    [btnGrid setBackgroundImage:[UIImage imageNamed:@"btn_grid_nor"] forState:UIControlStateNormal];
    [btnGrid setBackgroundImage:[UIImage imageNamed:@"btn_grid_sel"] forState:UIControlStateHighlighted];
    [btnGrid setBackgroundImage:[UIImage imageNamed:@"btn_grid_sel"] forState:UIControlStateSelected];
    [btnGrid addTarget:self
                action:@selector(onToolButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnGrid];
   
    // View Cart
    posX = 210;
    posY = 0;
    btnWidth = 99;
    btnHeight = 35;
    frame = CGRectMake(posX , posY, btnWidth, btnHeight);
    UIButton * btnCart = [[UIButton alloc] initWithFrame:frame];
    btnCart.tag = BTN_VIEWCART_ID;
    [btnCart setBackgroundImage:[UIImage imageNamed:@"btn_viewCart"] forState:UIControlStateNormal];
    [btnCart addTarget:self
                action:@selector(onToolButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnCart];
    
        
    UIImageView * imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT-1, tableView.frame.size.width, 1)];
    [imv setImage:[UIImage imageNamed:@"line"]];
    [view addSubview:imv];
    
    
    if (self.mType == TABLE_LIST) {
        [btnList setSelected:YES];
        [btnGrid setSelected:NO];
    } else {
        [btnList setSelected:NO];
        [btnGrid setSelected:YES];
    }

    
    return view;
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if (self.mType == TABLE_LIST) {
        
        static NSString *CellIdentifier = @"ShopListCell";
        
        ShopListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"ShopListCell" bundle:nil];
            cell =(ShopListCell*) viewController.view;
        }

        NSDictionary * shopItem = [self.arrTableList objectAtIndex:indexPath.row];

        cell.imgPhoto.contentMode = UIViewContentModeScaleAspectFit;
        NSArray * images = [shopItem objectForKey:@"images"];
        if (images != nil) {
            NSString * imageUrl = [[images objectAtIndex:0] objectForKey:@"image"];
            [DLImageLoader loadImageFromURL:imageUrl
                                  completed:^(NSError *error, NSData *imgData) {
                                      if (error == nil) {
                                          // if we have no errors
                                          UIImage * image = [UIImage imageWithData:imgData];
                                          [cell.imgPhoto setImage:image];
                                      }
                                  }];
        }
        
//        NSString * location = [tour objectForKey:@"location"];
//        cell.lbLocation.text = location;
        
        NSString * title = [shopItem objectForKey:@"title"];
        cell.lbTitle.text = title;

        NSString * price = [shopItem objectForKey:@"price"];
        cell.lbPrice.text = [NSString stringWithFormat:@"$%@", price];

        cell.btnAddCart.tag = BTN_DETAIL_ID + indexPath.row;
        [cell.btnAddCart addTarget:self action:@selector(onAddtoCartButton:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }
    else {
        static NSString *CellIdentifier = @"ShopGridCell";
        
        ShopGridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"ShopGridCell" bundle:nil];
            cell =(ShopGridCell*) viewController.view;
        }
        
        int nIndex1 = indexPath.row * 2;
        int nIndex2 = indexPath.row * 2 + 1;
        
        NSDictionary * shopItem = [self.arrTableList objectAtIndex:nIndex1];
        if (shopItem != nil) {
            cell.imgPhoto1.contentMode = UIViewContentModeScaleAspectFit;
            
            NSArray * images = [shopItem objectForKey:@"images"];
            if (images != nil) {
                NSString * imageUrl = [[images objectAtIndex:0] objectForKey:@"image"];
                [DLImageLoader loadImageFromURL:imageUrl
                                      completed:^(NSError *error, NSData *imgData) {
                                          if (error == nil) {
                                              // if we have no errors
                                              UIImage * image = [UIImage imageWithData:imgData];
                                              [cell.imgPhoto1 setImage:image];
                                          }
                                      }];
            }
            
            cell.imgPhoto1.tag = BTN_PHOTO_ID + nIndex1;
            cell.imgPhoto1.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShopDetail:)];
            tapGestureLock.numberOfTapsRequired = 1;
            [cell.imgPhoto1 addGestureRecognizer:tapGestureLock];
        }

        if (nIndex2 < (int)[self.arrTableList count]) {
            NSDictionary * shopItem2 = [self.arrTableList objectAtIndex:nIndex2];

            cell.imgPhoto2.contentMode = UIViewContentModeScaleAspectFit;
            NSArray * images = [shopItem2 objectForKey:@"images"];
            if (images != nil) {
                NSString * imageUrl = [[images objectAtIndex:0] objectForKey:@"image"];
                [DLImageLoader loadImageFromURL:imageUrl
                                      completed:^(NSError *error, NSData *imgData) {
                                          if (error == nil) {
                                              // if we have no errors
                                              UIImage * image = [UIImage imageWithData:imgData];
                                              [cell.imgPhoto2 setImage:image];
                                          }
                                      }];
            }
            
            cell.imgPhoto2.tag = BTN_PHOTO_ID + nIndex2;
            cell.imgPhoto2.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGestureLock2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShopDetail:)];
            tapGestureLock2.numberOfTapsRequired = 1;
            [cell.imgPhoto2 addGestureRecognizer:tapGestureLock2];
        }
        else {
            cell.imgPhoto2.hidden = YES;
        }

        return cell;
        
    }
    
    return nil;
}


@end
