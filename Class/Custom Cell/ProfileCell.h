//
//  ProfileCell.h
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lbFollowers;
@property (strong, nonatomic) IBOutlet UILabel *lbFollowing;
@property (strong, nonatomic) IBOutlet UILabel *lbPoints;
@property (strong, nonatomic) IBOutlet UIButton *btnAddPost;
@property (strong, nonatomic) IBOutlet UIButton *btnIndex;

@property (strong, nonatomic) IBOutlet UIButton * btnFollowers;
@property (strong, nonatomic) IBOutlet UIButton * btnFollowings;

@end
