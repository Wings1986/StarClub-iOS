//
//  ProductDetailController.m
//  StarClub
//

#import "ProductDetailController.h"
#import "DLImageLoader.h"

#import "RTFlyoutMenu.h"
#import "RTFlyoutItem.h"


@interface ProductDetailController ()<RTFlyoutMenuDelegate, RTFlyoutMenuDataSource>
{
    IBOutlet UIImageView * ivPhoto;
    IBOutlet UIImageView * ivSub1;
    IBOutlet UIImageView * ivSub2;
    IBOutlet UIImageView * ivSub3;
    
    IBOutlet UILabel * lbTitle;
    IBOutlet UILabel * lbPrice;
    IBOutlet UIView  * viewCombo;
    
}

@property (nonatomic, strong) NSDictionary * m_product;

@property (strong, nonatomic) RTFlyoutMenu *flyoutMenu;
@property (nonatomic) NSArray *mainItems;
@property (nonatomic) NSArray *subItems;

@end

@implementation ProductDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithProduct:(NSDictionary *) _product
{
    self = [super init];
    if (self) {
        self.m_product = [[NSDictionary alloc] initWithDictionary:_product];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    self.title = @"Product";
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   

    lbTitle.text = [self.m_product objectForKey:@"title"];
    lbPrice.text = [NSString stringWithFormat:@"$%@", [self.m_product objectForKey:@"price"]];
    
    ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
    [ivPhoto setClipsToBounds:YES];
    ivSub1.contentMode = UIViewContentModeScaleAspectFill;
    [ivSub1 setClipsToBounds:YES];
    ivSub2.contentMode = UIViewContentModeScaleAspectFill;
    [ivSub2 setClipsToBounds:YES];
    ivSub3.contentMode = UIViewContentModeScaleAspectFill;
    [ivSub3 setClipsToBounds:YES];
    
    NSArray * images = [self.m_product objectForKey:@"images"];
    if (images != nil) {
        for (int i = 0; i < (int)[images count]; i ++) {
            if (i == 0) {
                NSString * imageUrl1 = [[images objectAtIndex:0] objectForKey:@"image"];
                [DLImageLoader loadImageFromURL:imageUrl1
                                      completed:^(NSError *error, NSData *imgData) {
                                          if (error == nil) {
                                              // if we have no errors
                                              UIImage * image = [UIImage imageWithData:imgData];
                                              [ivPhoto setImage:image];
                                              [ivSub1 setImage:image];
                                          }
                                      }];
            }
            else if (i == 1) {
                NSString * imageUrl2 = [[images objectAtIndex:1] objectForKey:@"image"];
                [DLImageLoader loadImageFromURL:imageUrl2
                                      completed:^(NSError *error, NSData *imgData) {
                                          if (error == nil) {
                                              // if we have no errors
                                              UIImage * image = [UIImage imageWithData:imgData];
                                              [ivSub2 setImage:image];
                                          }
                                      }];
            }
            else if (i == 2) {
                NSString * imageUrl3 = [[images objectAtIndex:2] objectForKey:@"image"];
                [DLImageLoader loadImageFromURL:imageUrl3
                                      completed:^(NSError *error, NSData *imgData) {
                                          if (error == nil) {
                                              // if we have no errors
                                              UIImage * image = [UIImage imageWithData:imgData];
                                              [ivSub3 setImage:image];
                                          }
                                      }];
            }
        }
    }
    
    [self setComboBox];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) onClickBack:(id)sender
{
    [self onBack];
}
-(IBAction) onAddtoCart:(id)sender
{
    BOOL bAdded = NO;
    for (NSDictionary * item in GLOBAL.g_arrShopItem) {
        if ([[item objectForKey:@"id"] intValue] == [[self.m_product objectForKey:@"id"] intValue]) {
            bAdded = YES;
            break;
        }
    }
    
    if (bAdded == NO) {
        [GLOBAL.g_arrShopItem addObject:self.m_product];
        [self showMessage:@"Added" message:@"That item is added successfully!" delegate:nil firstBtn:@"OK" secondBtn:nil];
    } else {
        [self showMessage:@"Note" message:@"That item already is added!" delegate:nil firstBtn:@"OK" secondBtn:nil];
    }

}

-(void) setComboBox
{
//    self.mainItems = [[NSArray alloc] initWithObjects:[self.arrTitles firstObject], nil];
//    self.subItems = [[NSArray alloc] initWithObjects:self.arrTitles, nil];

    self.mainItems = @[@"Small"
                       ];
	self.subItems = @[
                      @[@"Small", @"Middle", @"Big"],
                      ];

    
    NSDictionary *options = @{
                              RTFlyoutMenuUIOptionInnerItemSize: [NSValue valueWithCGSize:CGSizeMake(22, 22)],
                              RTFlyoutMenuUIOptionSubItemPaddings: [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(10, 15, 10, 15)]
                              };
	RTFlyoutMenu *m = [[RTFlyoutMenu alloc] initWithDelegate:self dataSource:self position:kRTFlyoutMenuPositionTop options:options];
	m.canvasView = self.view;
    
	CGRect mf = CGRectMake(20, 0, 50, 36);
	m.frame = mf;
    
    //	m.backgroundColor = [UIColor redColor];
	[viewCombo addSubview:m];
	self.flyoutMenu = m;
    
	//	look & feel
	[[RTFlyoutItem appearanceWhenContainedIn:[viewCombo class], nil] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[[RTFlyoutItem appearanceWhenContainedIn:[viewCombo class], nil] setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectSubItemWithIndex:(NSInteger)subIndex mainMenuItemIndex:(NSInteger)mainIndex
{
//    NSLog(@"Tap on main/sub index: %d / %d", mainIndex, subIndex);
    
    if (subIndex >= 0) {

    }
    
}
@end
