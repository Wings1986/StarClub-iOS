//
//  InboxCell
//

#import <UIKit/UIKit.h>

@interface InboxCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView * ivUnread;
@property (strong, nonatomic) IBOutlet UILabel *lbUserName;
@property (strong, nonatomic) IBOutlet UILabel *lbTimeStamp;
@property (strong, nonatomic) IBOutlet UILabel *lbMessage;

@end
