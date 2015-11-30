//
//  AddPhotoController.m
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//

#import "AddPhotoController.h"

#import "ASIFormDataRequest.h"
#import "SBJsonParser.h"

#import <QuartzCore/QuartzCore.h>
#import "myurl.h"

#import "StarTracker.h"


#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <AviarySDK/AviarySDK.h>

#import <AssetsLibrary/AssetsLibrary.h>


static NSString * const kAFAviaryAPIKey = AVIARY_API_KEY;
static NSString * const kAFAviarySecret = AVIARY_SECRET_KEY;



@interface AddPhotoController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, AFPhotoEditorControllerDelegate>
{
    IBOutlet UIImageView * imgAvatar;
    IBOutlet UITextView  * mTextView;
    IBOutlet UIImageView * imgPhoto;

    NSMutableDictionary * m_shareDic;
    
}

@property (nonatomic, strong) UIImage * chooseImage;

@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;


@end

@implementation AddPhotoController

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
    
    

    self.title = @"New Photo";
    [ StarTracker StarSendView: self.title];
    
    UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnCancel setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_send.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickPost:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    
    
    mTextView.layer.borderWidth = 1.0f;
    mTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    
    NSString * imageUrl = [userInfo objectForKey:@"img_url"];
    if (imageUrl == nil || imageUrl.length < 1) {
        UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:imgAvatar.frame.size.width];
        [imgAvatar setImage:image];
    }
    else {
        [DLImageLoader loadImageFromURL:imageUrl
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:imgAvatar.frame.size.width];
                                      [imgAvatar setImage:image];
                                  }
                              }];
    }
    
    
    imgPhoto.contentMode = UIViewContentModeScaleAspectFill;
    [imgPhoto setClipsToBounds:YES];
    imgPhoto.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChoosePhoto:)];
    tapGestureUser.numberOfTapsRequired = 1;
    [imgPhoto addGestureRecognizer:tapGestureUser];
    
    
    // Allocate Asset Library
    ALAssetsLibrary * assetLibrary = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary];
    
    // Allocate Sessions Array
    NSMutableArray * sessions = [NSMutableArray new];
    [self setSessions:sessions];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Choose photo
-(void) onChoosePhoto:(UITapGestureRecognizer*) recognizer {
    
    if ([mTextView isFirstResponder]) {
        [mTextView resignFirstResponder];
    }
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Choose Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll", @"New Picture", nil];
    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // camera roll
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [imagePicker setAllowsEditing:YES];
        
        [self presentViewController:imagePicker animated:YES completion:nil];

    }
    else if (buttonIndex == 1) {//new picture
        if( ![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            return;
        
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [imagePicker setShowsCameraControls:YES];
        [imagePicker setAllowsEditing:YES];
        
        
        [self presentViewController:imagePicker animated:YES completion:nil];

    }
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
/*
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        // Do something with an image from the camera
//        UIImage* originalImage = nil;
//        originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
//        if(originalImage==nil)
//        {
//            originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//        }
//        if(originalImage==nil)
//        {
//            originalImage = [info objectForKey:UIImagePickerControllerCropRect];
//        }
//        
//        NSData * imageData = UIImagePNGRepresentation(originalImage);
//        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
//        [imageData writeToFile:savedImagePath atomically:NO];
//        
//        assetURL = [NSURL URLWithString:savedImagePath];

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        UIImage * image = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];

        [library writeImageToSavedPhotosAlbum: image.CGImage
                                  orientation:(ALAssetOrientation)image.imageOrientation
//                                     metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  
                                  [self gotoAviaraSDK:assetURL];
                                  
                              }];
    } else {
        // Do something with an image from another source
//        NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
//        
//        [self gotoAviaraSDK:assetURL];
        
    }
*/
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
//    UIImage * image = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];

    
    [library writeImageToSavedPhotosAlbum: image.CGImage
                              orientation:(ALAssetOrientation)image.imageOrientation
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              [super showLoading:@"Loading Photo Editor!"];
                              [self gotoAviaraSDK:assetURL];
                          }];
    
}
- (UIImage *)fixOrientationImage:(UIImage*) orgImage
{
    
    // No-op if the orientation is already correct
    if (orgImage.imageOrientation == UIImageOrientationUp) return orgImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orgImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.width, orgImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, orgImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (orgImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, orgImage.size.width, orgImage.size.height,
                                             CGImageGetBitsPerComponent(orgImage.CGImage), 0,
                                             CGImageGetColorSpace(orgImage.CGImage),
                                             CGImageGetBitmapInfo(orgImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orgImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,orgImage.size.height,orgImage.size.width), orgImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,orgImage.size.width,orgImage.size.height), orgImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    CGContextRelease(ctx);
    
    return img;
}


-(void) gotoAviaraSDK:(NSURL *) assetURL
{
    void(^completion)(void)  = ^(void){
        [super hideLoading];
        [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (asset){
                [self launchEditorWithAsset:asset];
            }
        } failureBlock:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    };
    
    
    [self dismissViewControllerAnimated:YES completion:completion];
}
/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.chooseImage = [image copy];
    
    int width = self.chooseImage.size.width;
    int height = self.chooseImage.size.height;
//    int minValue = MIN(width, height);
    
    float newWidth = POST_IMAGE_SIZE; //minValue > POST_IMAGE_SIZE ? POST_IMAGE_SIZE : minValue;
    float newHeight = height * newWidth/width;
    
    CGSize size = CGSizeMake(newWidth, newHeight);
    
    self.chooseImage = [self.chooseImage imageResize:self.chooseImage andResizeTo:size];
    
    
    [imgPhoto setImage:self.chooseImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
*/

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
- (IBAction) onClickCancel:(id)sender {
    [self onBack];
}
- (IBAction) onClickPost:(id)sender {
 
    if (mTextView.text.length < 1) {
        [self showMessage:@"Warning!" message:@"Please input caption text!" delegate:nil firstBtn:nil secondBtn:@"OK"];
        return;
    }
    
    if (self.chooseImage == nil) {
        [self showMessage:@"Warning!" message:@"Please take photo!" delegate:nil firstBtn:nil secondBtn:@"OK"];
        return;
    }
    
    
    if ([mTextView isFirstResponder]) {
        [mTextView resignFirstResponder];
    }

    [super showLoading:@"Uploading..."];
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
    
    NSString *url = [MyUrl getAddImageUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:[NSString stringWithFormat:@"%d", CID] forKey:@"cid"];
    [request setPostValue:TOKEN forKey:@"token"];
    NSLog(@"USER_ID = %@", USERID);
    [request setPostValue:USERID forKey:@"user_id"];
    [request setPostValue:mTextView.text forKey:@"description"];

    NSData *imgData = [[NSData alloc] initWithData: UIImageJPEGRepresentation(self.chooseImage, 1.0)];
    if (imgData != nil) {
        [request setData:imgData withFileName:@"picture.jpeg" andContentType:@"image/*" forKey:@"image"];
    }
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request setTimeOutSeconds:300];
    [request startAsynchronous];
    
}

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:responseString];
    
    NSLog(@"result = %@", result);

    [super hideLoading];
    
    BOOL status = [[result objectForKey:@"status"] boolValue];
    if (status == true) {
        
        if ([Global getUserType] != FAN) {
//            NSString * imageUrl = result[@"post"][0][@"image_path"];
//            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
//            UIImage *image = [UIImage imageWithData:data];
//            [super setResultDic:result[@"post"][0] image:image];
            m_shareDic = result[@"post"][0];
        }
        
        [self performSelectorOnMainThread:@selector(doneServer) withObject:nil waitUntilDone:YES];
    }
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    [super showFail:@"Network Communication Problems"];
}

-(void) doneServer
{
    [self.delegate addPhotoPostDone];

    if ([Global getUserType] == FAN) {
        [self onBack];
    }
    else {
        
        UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
        [btnEdit setImage:[UIImage imageNamed:@"btn_post"] forState:UIControlStateNormal];
        [btnEdit addTarget:self action:@selector(onShareDic) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
        self.navigationItem.rightBarButtonItem = btnItemEdit;
        
        NSString * message = [NSString stringWithFormat:@"%@\nSyndicate to Social Media?", @"Published Successfully."];
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@""
                           message:message
                           delegate:self
                           cancelButtonTitle:@"Yes"
                           otherButtonTitles:@"No", nil];
        av.tag = 20000;
        [av show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //OK
        
        if (alertView.tag == 20000) {
            [self onShareDic];
            return;
        }
    }
}
- (void) onShareDic
{
    PublishFeedController * pController = [[PublishFeedController alloc] initWithShare:m_shareDic];
    [super onPush:pController];
}


#pragma mark - Photo Editor Launch Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    
    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
}

- (void) launchEditorWithSampleImage
{
    UIImage * sampleImage = [UIImage imageNamed:@"Demo.png"];
    
    [self launchPhotoEditorWithImage:sampleImage highResolutionImage:nil];
}

#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    

    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    if (highResImage) {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:YES completion:nil];
}

- (void) setupHighResContextForPhotoEditor:(AFPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    // Capture a reference to the editor's session, which internally tracks user actions on a photo.
    __block AFPhotoEditorSession *session = [photoEditor session];
    
    // Add the session to our sessions array. We need to retain the session until all contexts we create from it are finished rendering.
    [[self sessions] addObject:session];
    
    // Create a context from the session with the high res image.
    AFPhotoEditorContext *context = [session createContextWithImage:highResImage];
    
    __block AddPhotoController * blockSelf = self;
    
    // Call render on the context. The render will asynchronously apply all changes made in the session (and therefore editor)
    // to the context's image. It will not complete until some point after the session closes (i.e. the editor hits done or
    // cancel in the editor). When rendering does complete, the completion block will be called with the result image if changes
    // were made to it, or `nil` if no changes were made. In this case, we write the image to the user's photo album, and release
    // our reference to the session.
    [context render:^(UIImage *result) {
        if (result) {
            UIImageWriteToSavedPhotosAlbum(result, nil, nil, NULL);
        }
        
        [[blockSelf sessions] removeObject:session];
        
        blockSelf = nil;
        session = nil;
        
    }];
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
//    [[self imagePreviewView] setImage:image];
//    [[self imagePreviewView] setContentMode:UIViewContentModeScaleAspectFit];

    
    self.chooseImage = [image copy];
    
    int width = self.chooseImage.size.width;
    int height = self.chooseImage.size.height;
    //    int minValue = MIN(width, height);
    
    float newWidth = POST_IMAGE_SIZE; //minValue > POST_IMAGE_SIZE ? POST_IMAGE_SIZE : minValue;
    float newHeight = height * newWidth/width;
    
    CGSize size = CGSizeMake(newWidth, newHeight);
    
    self.chooseImage = [self.chooseImage imageResize:self.chooseImage andResizeTo:size];
    
    
    [imgPhoto setImage:self.chooseImage];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{

    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@""
                       message:@"Photo has been saved \nto Camera Roll."
                       delegate:self
                       cancelButtonTitle:@"Ok"
                       otherButtonTitles:nil];
    [av show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    [AFPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
//    [AFPhotoEditorController setPremiumAddOns:(AFPhotoEditorPremiumAddOnWhiteLabel)];
    
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];

    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}


#pragma mark - ALAssets Helper Methods

- (UIImage *)editingResImageForAsset:(ALAsset*)asset
{
    CGImageRef image = [[asset defaultRepresentation] fullScreenImage];
    
    return [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
}

- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientation = [representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientation];
}

@end
