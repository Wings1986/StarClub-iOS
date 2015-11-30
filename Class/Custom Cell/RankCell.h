//
//  RankCell
//

#import <UIKit/UIKit.h>

@interface RankCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lbFirstName;
@property (strong, nonatomic) IBOutlet UILabel *lbLastName;
@property (strong, nonatomic) IBOutlet UILabel *lbRank;
@property (strong, nonatomic) IBOutlet UILabel *lbPoint;

@end
