//
//  InboxController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import "InboxController.h"
#import "InboxCell.h"
#import "MsgDetailController.h"
#import "SendMsgController.h"

#import "StarTracker.h"

@interface InboxController ()<MsgDetailControllerDelegate>
{
    int m_nSelect;
}

@end

@implementation InboxController

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
    
    self.title = @"Inbox";
    
    [StarTracker StarSendView:self.title];
    
    
    self.m_nNumOfSection = 1;
    self.m_nNumOfHeader = 0;

   [self.mTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
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
        
        [super showLoading:@"Loading..."];
        
        m_nPage = 0;
        [self getInbox];
    }

}

- (void) getInbox{
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}

-(void) postServer
{
    NSString * urlResult = [MyUrl getMessage:m_nPage];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            [super hideLoading];
            
            if (self.arrTableList == nil || m_nPage == 0) {
                self.arrTableList = [[result objectForKey:@"messages"] objectForKey:@"receiver_messages"];
            }
            else {
                [self.arrTableList addObjectsFromArray:[[result objectForKey:@"messages"] objectForKey:@"receiver_messages"]];
            }
            
            m_nPage ++;
            
        }
        else {
            NSString * ErrMessage = [result objectForKey:@"message"];
            [self showFail:ErrMessage];
        }
    }

    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];

}

- (void)startRefresh
{
    [super startRefresh];
    
    m_nPage = 0;
    [self getInbox];
}
- (void)startMoreLoad
{
    [super startMoreLoad];
    
    [self getInbox];
}

- (void) doneLoadingTableViewData {
    [super doneLoadingTableViewData];
}



#pragma mark -
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
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
    

    static NSString *CellIdentifier = @"InboxCell";
    
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"InboxCell" bundle:nil];
        cell =(InboxCell*) viewController.view;
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell.
    
    NSDictionary * rankUser = [self.arrTableList objectAtIndex:indexPath.row];
    
    int is_seen = [[rankUser objectForKey:@"is_seen"] intValue];
    if (is_seen == 0) {
        cell.ivUnread.hidden = NO;
    } else {
        cell.ivUnread.hidden = YES;
    }
    
    cell.lbUserName.text = [rankUser objectForKey:@"name"];
    NSDate *dateSent = [NSDate dateWithTimeIntervalSince1970:[[rankUser objectForKey:@"time_stamp"] doubleValue]];
    cell.lbTimeStamp.text = [dateSent timeAgo];

    cell.lbMessage.text = [rankUser objectForKey:@"message"];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    m_nSelect = indexPath.row;
    
    NSDictionary * message = [self.arrTableList objectAtIndex:m_nSelect];
    
    int is_seen = [[message objectForKey:@"is_seen"] intValue];
    if (is_seen == 0) {
        m_nSelect = indexPath.row;
    } else {
        m_nSelect = -1;
    }
    
    MsgDetailController * pController = [[MsgDetailController alloc] initWithMessageDetail:message];
    pController.delegate = self;
    [self onPush:pController];

}

- (void)msgDetailsDone {
    if (m_nSelect != -1) {
        NSMutableDictionary * message = [self.arrTableList objectAtIndex:m_nSelect];
        
        [message setObject:@"1" forKey:@"is_seen"];
        
        [self.arrTableList replaceObjectAtIndex:m_nSelect withObject:message];
        
        [self doneLoadingTableViewData];
    }
}


@end
