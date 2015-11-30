//
//  AddPhotoController.m
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//

#import "AddVideoController.h"

#import "ASIFormDataRequest.h"
#import "SBJsonParser.h"

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>

#import "StarTracker.h"


@interface AddVideoController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet UIImageView * imgAvatar;
    IBOutlet UITextView  * mTextView;
    IBOutlet UIImageView * imgPhoto;

}

@property (nonatomic, strong) NSData * chooseVideo;
//@property (nonatomic, strong) NSURL * chooseVideo;

@end

@implementation AddVideoController

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
    

    self.title = @"New Video";
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
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Choose Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Camera Roll", @"New Video", nil];
    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // camera roll
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, kUTTypeVideo, nil];
        [imagePicker setAllowsEditing:YES];
        
        [self presentViewController:imagePicker animated:YES completion:nil];

    }
    else if (buttonIndex == 1) {//new picture
        if( ![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            return;
        
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
        [imagePicker setAllowsEditing:YES];
        
        [self presentViewController:imagePicker animated:YES completion:nil];

    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];

//    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSLog(@"%@",videoURL);
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);

    [imgPhoto setImage:thumb];
    
//    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//    {
//        // Gets the thumbnail
//        UIImage *thumbnail = [UIImage imageWithCGImage:[myasset thumbnail]];
//        [imgPhoto setImage:thumbnail];
//    };
//    
//    
//    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
//    {
//        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
//    };
//    
//    if(videoURL)
//    {
//        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
//        [assetslibrary assetForURL:videoURL
//                       resultBlock:resultblock
//                      failureBlock:failureblock];
//    }


    
 //   self.chooseVideo = videoURL;
    
    
    self.chooseVideo = [NSData dataWithContentsOfURL:videoURL];

    
    [self dismissViewControllerAnimated:YES completion:nil];

         
         
}

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

    if (self.chooseVideo == nil) {
        [self showMessage:@"Warning!" message:@"Please choose video to upload!" delegate:nil firstBtn:nil secondBtn:@"OK"];
        return;
    }
    
    if ([mTextView isFirstResponder]) {
        [mTextView resignFirstResponder];
    }

    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *AdminType = [userInfo objectForKey:@"admin_type"];
    if ([AdminType  isEqual: @"1"]) {
        
        [super showLoading:@"Uploading to Video Server \n..."];
    } else {
        [super showLoading:@"Uploading..."];
    }
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
    
    NSString *url = [MyUrl getAddVideoUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:[NSString stringWithFormat:@"%d", CID] forKey:@"cid"];
    [request setPostValue:TOKEN forKey:@"token"];
    [request setPostValue:USERID forKey:@"user_id"];
    [request setPostValue:mTextView.text forKey:@"description"];
//    [request setShouldStreamPostDataFromDisk:YES];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    
    if (self.chooseVideo != nil) {
        
 //       NSString *chosenurl = [self.chooseVideo absoluteString];
        
        [request setData:self.chooseVideo withFileName:@"video.mp4" andContentType:@"video/*" forKey:@"video"];

//        [request setFile:chosenurl forKey:@"file"];

    }

    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request setTimeOutSeconds:1000];
    [request startAsynchronous];
    
}

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    NSLog(@"result = %@", responseString);
    
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:responseString];
    
    NSLog(@"result = %@", result);
    
    [super hideLoading];
    
    if ([Global getUserType] != FAN) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Cloud"
                message:@"Your video is being processed... \n It will be available for review shortly."
                delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
        [alert show];
    

    }
    
    BOOL status = [[result objectForKey:@"status"] boolValue];
    if (status == true) {
        
        [self performSelectorOnMainThread:@selector(doneServer) withObject:nil waitUntilDone:YES];

    }
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    [super showFail:@"Network Problems"];
    
}

-(void) doneServer
{
    [self onBack];
    
    if ([Global getUserType] == FAN) {
        [self.delegate addVideoPostDone];
    }
}
@end
