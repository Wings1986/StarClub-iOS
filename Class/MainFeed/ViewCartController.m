//
//  ViewCartController.m
//  StarClub
//

#import "ViewCartController.h"
#import "DLImageLoader.h"
#import "ViewCartCell.h"

@interface ViewCartController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * mTableView;
    
    int nSelItem ;
    int nSelTextField;
    
    BOOL    keyboardVisible;
}
@end

@implementation ViewCartController

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
    
    
    self.title = @"Shopping Cart";
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_next.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickNext:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    

    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [mTableView addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
    
    nSelTextField = -1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    if (!bLoaded) {
        bLoaded = YES;
        
        
    }
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
-(IBAction) onClickNext:(id)sender
{
    
}

-(void) onRemove:(UIButton*) sender {
    
    nSelItem = sender.tag - BTN_COMMENT_ID;
    
    [self showMessage:@"Note" message:@"Do you want to remove that item on Cart?" delegate:self firstBtn:@"YES" secondBtn:@"NO"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) { // YES
        [GLOBAL.g_arrShopItem removeObjectAtIndex:nSelItem];
        
        [mTableView reloadData];
    }
}

#pragma mark --------------- Table view ---------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [GLOBAL.g_arrShopItem count];
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 93;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ViewCartCell";
    
    ViewCartCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"ViewCartCell" bundle:nil];
        cell =(ViewCartCell*) viewController.view;
    }
    
    cell.tag = indexPath.row;
    
    NSDictionary * shopItem = [GLOBAL.g_arrShopItem objectAtIndex:indexPath.row];
    
    NSArray * arrImages = [shopItem objectForKey:@"images"];
    if (arrImages != nil) {
        NSString * imageUrl = [[arrImages firstObject] objectForKey:@"image"];
        [DLImageLoader loadImageFromURL:imageUrl
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      cell.imgPhoto.image = [UIImage imageWithData:imgData];
                                  } else {
                                      // if we got error when load image
                                  }
                              }];
    }

    cell.imgPhoto.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgPhoto.clipsToBounds = YES;

    cell.lbLocation.text = @"Enrique lglesias"; // [shopItem objectForKey:@"position"];
    
    cell.lbTitle.text = [shopItem objectForKey:@"title"];
    cell.lbPrice.text =[NSString stringWithFormat:@"$%@", [shopItem objectForKey:@"price"]];
    
    
    cell.btnX.tag = BTN_COMMENT_ID + indexPath.row;
    [cell.btnX addTarget:self action:@selector(onRemove:) forControlEvents:UIControlEventTouchUpInside];

    [cell.tfQuantity addTarget:self action:@selector(myNumberValueBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    cell.tfQuantity.tag = 100 + indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)hideKeyboard{
    if (nSelTextField == -1) {
        return;
    }
    
    ViewCartCell * cell = (ViewCartCell*)[mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nSelTextField inSection:0]];
    [cell.tfQuantity resignFirstResponder];
}

-(void)myNumberValueBeginEditing:(UITextField *)sender
{
//    ViewCartCell * cell = (ViewCartCell*) sender.superview;
    nSelTextField = sender.tag - 100;
    
//    nSelTextField = [sender.superview.superview tag];
//    UITextField *cellTemp = (UITextField*)[(UITableViewCell *)sender.superview viewWithTag:200+row];
//    cellTemp.delegate = self;
//    [cellTemp becomeFirstResponder];
}

#pragma mark ---------- Key board
-(void) keyboardDidShow: (NSNotification *)notif
{
    if (keyboardVisible)
	{
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
    mTableView.frame = CGRectMake(mTableView.frame.origin.x, mTableView.frame.origin.y, mTableView.frame.size.width, mTableView.frame.size.height-keyboardSize.height +TOOLBAR_HEIGHT);
    
	// Keyboard is now visible
	keyboardVisible = YES;
    
    if (nSelTextField != 0) {
        [mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:nSelTextField inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void) keyboardDidHide: (NSNotification *)notif
{
	// Is the keyboard already shown
	if (!keyboardVisible)
	{
		return;
	}
    
    NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
    
    mTableView.frame = CGRectMake(mTableView.frame.origin.x, mTableView.frame.origin.y, mTableView.frame.size.width, mTableView.frame.size.height+keyboardSize.height-TOOLBAR_HEIGHT);
    
	// Keyboard is no longer visible
	keyboardVisible = NO;
}



@end
