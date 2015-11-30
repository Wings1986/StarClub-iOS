//
//  AvatarController.m
//  StarClub
//
//  Created by MAYA on 12/31/13.
//
//

#import "AvatarController.h"
#import "SignupController.h"


@interface AvatarController ()

@property (nonatomic, strong) UIImage * chooseImage;

@end


@implementation AvatarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.m_bGotoNext = YES;
    }
    return self;
}

-(id) initWithGotoReturn
{
    self = [super init];
    if (self) {
        self.m_bGotoNext = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
    
    [ivChoose setClipsToBounds:YES];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Avatar";
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_next.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickNext:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -------- button event ------

-(IBAction) onClickBack:(id)sender
{
    [self onBack];
}
-(IBAction) onClickNext:(id)sender
{
//    if (self.chooseImage == nil) {
//        [self showMessage:@"" message:@"Please choose image" delegate:nil firstBtn:@"OK" secondBtn:nil];
//        return;
//    }
    
    if (self.m_bGotoNext) {
        SignupController * pController = [[SignupController alloc] initWithImageName:self.chooseImage];
        [self onPush:pController];
    }
    else { //return
        [self.delegate setAvatarImage:self.chooseImage];
        [self onBack];
    }
}
-(IBAction) onClickCameraRoll:(id)sender
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [imagePicker setAllowsEditing:YES];
    
    [self presentViewController:imagePicker animated:YES completion:nil];

    
}
-(IBAction) onClickTakePhoto:(id)sender
{
    if( ![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
        return;
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [imagePicker setAllowsEditing:YES];
    
    [self presentViewController:imagePicker animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.chooseImage = [image copy];
    [ivChoose setImage:self.chooseImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
