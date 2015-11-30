//
//  RankingController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import "RankingController.h"
#import "RankTopCell.h"
#import "RankCell.h"

#import "FanDetailController.h"

#import "StarTracker.h"
@interface RankingController ()

@end

@implementation RankingController

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
    m_bMoreLoad = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [StarTracker StarSendView:@"Ranking"];
    
    self.m_nNumOfSection = 2;
    self.m_nNumOfHeader = 0;
    
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

        [super showLoading:@"Loading..."];
        
        m_nPage = 0;
        [self getRankingList];

    }
}

- (void) getRankingList{
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
    
}
-(void) postServer
{
    NSString * resultString = [MyUrl getRanking:m_nPage];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:resultString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            if (self.arrTableList == nil || m_nPage == 0) {
                self.arrTableList = [result objectForKey:@"rankings"];
            }
            else {
                [self.arrTableList addObjectsFromArray:[result objectForKey:@"rankings"]];
            }

            m_nPage ++;
            
            [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
        }
        else {
            NSString * ErrMessage = [result objectForKey:@"message"];
            [self showFail:ErrMessage];
            return;
        }
    }
    
    [super hideLoading];
}

- (void)startRefresh
{
    [super startRefresh];
    
    m_nPage = 0;
    [self getRankingList];
}
- (void)startMoreLoad
{
    [super startMoreLoad];
    
    [self getRankingList];
}

- (void) doneLoadingTableViewData {
    [super doneLoadingTableViewData];
}



#pragma mark -
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 161;
    }
    else if (indexPath.section == 1){
        return 80;
    }
    
    return 0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    

    if (section == 0) {
        if ([self.arrTableList count] != 0) {
            return 1;
        }
        else {
            return 0;
        }
    } else {
        return [self.arrTableList count]-1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"RankTopCell";
        
        RankTopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"RankTopCell" bundle:nil];
            cell =(RankTopCell*) viewController.view;
        }
        
        // Configure the cell.
        
        NSDictionary * rankUser = [self.arrTableList objectAtIndex:0];
        
        cell.imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
        [cell.imgAvatar setClipsToBounds:YES];
        
        [cell.imgAvatar setImage:nil];
        NSString * imageUrl = [rankUser objectForKey:@"img_url"];
        if (imageUrl == nil || imageUrl.length < 1) {
            UIImage * image = [UIImage imageNamed:@"demo-avatar.png"] ;
            [cell.imgAvatar setImage:[image circleImageWithSize:cell.imgAvatar.frame.size.width]];
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
        
        cell.lbFirstName.text = [rankUser objectForKey:@"userName"];
        cell.lbLastName.text = @"";
        
        int point = [[rankUser objectForKey:@"point"] intValue];
        cell.lbPoint.text = [NSString stringWithFormat:@"%d", point];
        
        return cell;
    }
    else if (indexPath.section == 1){
        
        static NSString *CellIdentifier = @"RankCell";
        
        RankCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"RankCell" bundle:nil];
            cell =(RankCell*) viewController.view;
        }
        
        // Configure the cell.
        
        
        NSDictionary * rankUser = [self.arrTableList objectAtIndex:indexPath.row + 1];
        
        cell.imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
        [cell.imgAvatar setClipsToBounds:YES];
        
        [cell.imgAvatar setImage:nil];
        
        NSString * imageUrl = [rankUser objectForKey:@"img_url"];
        if (imageUrl == nil || imageUrl.length < 1) {
            UIImage * image = [[UIImage imageNamed:@"demo-avatar"]  circleImageWithSize:cell.imgAvatar.frame.size.width];
            [cell.imgAvatar setImage:image];
        }
        else {
            [DLImageLoader loadImageFromURL:imageUrl
                                  completed:^(NSError *error, NSData *imgData) {
                                      if (error == nil) {
                                          // if we have no errors
                                          UIImage * image = [[UIImage imageWithData:imgData]  circleImageWithSize:cell.imgAvatar.frame.size.width];
                                          [cell.imgAvatar setImage:image];
                                      }
                                      else {
                                          UIImage * image = [[UIImage imageNamed:@"demo-avatar"]  circleImageWithSize:cell.imgAvatar.frame.size.width];
                                          [cell.imgAvatar setImage:image];
                                      }
                                  }];
        }
        
        cell.lbFirstName.text = [rankUser objectForKey:@"userName"];
        cell.lbLastName.text = @"";
        
        int point = [[rankUser objectForKey:@"point"] intValue];
        cell.lbPoint.text = [NSString stringWithFormat:@"%d", point];
        
        
        cell.lbRank.text = [NSString stringWithFormat:@"%d", (int)indexPath.row + 2];
        
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * userID = @"";
    
    if (indexPath.section == 0) {
        userID = [[self.arrTableList objectAtIndex:0] objectForKey:@"user_id"];
    }
    else {
        userID = [[self.arrTableList objectAtIndex:indexPath.row +1] objectForKey:@"user_id"];
    }

    FanDetailController * pController = [[FanDetailController alloc] initWithUserID:userID];
    [self onPush:pController];
}

@end
