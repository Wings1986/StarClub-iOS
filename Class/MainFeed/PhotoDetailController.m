//
//  PhotoDetailController.m
//  StarClub
//
//  Created by MAYA on 1/3/14.
//
//

#import "PhotoDetailController.h"
#import "PhotoCell.h"
//#import "UIImageView+Cached.h"
#import "DLImageLoader.h"

#import "StarTracker.h"


@interface PhotoDetailController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * mTableView;
    
    NSMutableArray * arrPhotos;
}
@end

@implementation PhotoDetailController

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
    
    [StarTracker StarSendView:@"Photo Detail"];
    
    arrPhotos = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", nil];
    
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

-(void) onTouchPhoto:(UITapGestureRecognizer*) recognize
{
    
}
-(IBAction) onShare:(UIButton*) btn
{
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", nil];
    action.tag = 1800;
    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1800) {
        
        
    }
}




#pragma mark --------------- Table view ---------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"PhotoCell" bundle:nil];
        cell =(PhotoCell*) viewController.view;
    }
    
    
//    [cell.imgPhoto loadFromURL:[NSURL URLWithString:@"http://test01.montkiara-it.com/3e54e3d48b908102946d089e3a90cc06.1.jpg"]];
    NSString * imageUrl = @"http://test01.montkiara-it.com/3e54e3d48b908102946d089e3a90cc06.1.jpg";
    [DLImageLoader loadImageFromURL:imageUrl
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  cell.imgPhoto.image = [UIImage imageWithData:imgData];
                              } else {
                                  // if we got error when load image
                              }
                          }];

    
    cell.imgPhoto.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgPhoto.clipsToBounds = YES;
    cell.imgPhoto.userInteractionEnabled = YES;
    cell.imgPhoto.tag = BTN_PHOTO_ID + indexPath.row;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchPhoto:)];
    tapGesture.numberOfTapsRequired = 1;

    [cell.imgPhoto addGestureRecognizer:tapGesture];

    cell.lbDetail.text = [arrPhotos objectAtIndex:indexPath.row];
//    cell.lbComment.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_CAPTION];
    cell.lbComment.text = [NSString stringWithFormat:@"%@ Comments", [arrPhotos objectAtIndex:indexPath.row]];
    
    cell.btnComment.tag = BTN_COMMENT_ID + indexPath.row;
    [cell.btnComment addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];

//    cell.btnFacebook.tag = BTN_FACEBOOK_ID + indexPath.row;
//    [cell.btnFacebook addTarget:self action:@selector(onFacebook:) forControlEvents:UIControlEventTouchUpInside];
//
//    cell.btnTwitter.tag = BTN_TWITTER_ID + indexPath.row;
//    [cell.btnTwitter addTarget:self action:@selector(onTwitter:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
