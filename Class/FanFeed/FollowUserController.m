//
//  FollowUserController.m
//  StarClub

#import "FollowUserController.h"
#import "MainMenuCell.h"
#import "FanDetailController.h"

#import "StarTracker.h"

@interface FollowUserController ()
{
}

@property(nonatomic, strong) NSArray* m_arrUsers;
@property(nonatomic, assign) NSString * m_title;

@end

@implementation FollowUserController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithUserList:(NSString *) title {
    self = [super init];
    if (self) {
        self.m_title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    m_bMoreLoad = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.m_nNumOfSection = 1;
    self.m_nNumOfHeader = 0;
    
    self.title = self.m_title;
    
    [StarTracker StarSendView: self.title];
    
//    [self.mTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!bLoaded) {
        bLoaded = YES;
        
        m_nPage = 0;
        [self getFollowerUserList];
    }
}

-(IBAction) onClickBack:(id)sender
{
    [super onBack];
}

- (void) getFollowerUserList{
    
//    self.arrTableList = [[NSMutableArray alloc] initWithArray:self.m_arrUsers];;
//    [self doneLoadingTableViewData];
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
    
}
-(void) postServer
{
    NSString * resultString = @"";
    
    if ([self.m_title isEqual:@"Followers"]) {
        resultString = [MyUrl getFollowUsersFollowedMe:m_nPage];
    } else {
        resultString = [MyUrl getFollowUsersByMe:m_nPage];
    }
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:resultString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            if (self.arrTableList == nil || m_nPage == 0) {
                self.arrTableList = [result objectForKey:@"users"];
            }
            else {
                [self.arrTableList addObjectsFromArray:[result objectForKey:@"users"]];
            }
            
            m_nPage ++;
            
            [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
//            [self doneLoadingTableViewData];
        }
    }
}

- (void)startRefresh
{
    [super startRefresh];
    
    m_nPage = 0;
    [self getFollowerUserList];
}
- (void) startMoreLoad
{
    [super startMoreLoad];
    
    [self getFollowerUserList];
}

- (void) doneLoadingTableViewData {
    [super doneLoadingTableViewData];
}




#pragma mark -
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 50;
    }
    
    return 0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.arrTableList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

        static NSString* identifier = @"MainMenuCell";
        MainMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"MainMenuCell" bundle:nil];
            cell =(MainMenuCell*) viewController.view;
        }

        // Configure the cell.
    
        NSDictionary * rankUser = [self.arrTableList objectAtIndex:indexPath.row];
        
        cell.imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
        [cell.imgAvatar setClipsToBounds:YES];
    
        [cell.imgAvatar setImage:nil];
    
        NSString * imageUrl = [rankUser objectForKey:@"img_url"];
        if (imageUrl == nil || imageUrl.length < 1) {
            UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:cell.imgAvatar.frame.size.width];
            [cell.imgAvatar setImage:image];
        }
        else {
            [DLImageLoader loadImageFromURL:imageUrl
                                  completed:^(NSError *error, NSData *imgData) {
                                      if (error == nil) {
                                          // if we have no errors
                                          UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:cell.imgAvatar.frame.size.width];
                                          [cell.imgAvatar setImage:image];
                                      }
                                  }];
        }

    
        cell.lbUserName.text = [rankUser objectForKey:@"name"];

    
        return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * userID = @"";
    
    userID = [[self.arrTableList objectAtIndex:indexPath.row] objectForKey:@"id"];

    FanDetailController * pController = [[FanDetailController alloc] initWithUserID:userID];
    [self onPush:pController];
}

@end
