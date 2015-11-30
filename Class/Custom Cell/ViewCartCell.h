//
//  ViewCartCell.h
//

#import <UIKit/UIKit.h>

@interface ViewCartCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lbLocation;
@property (strong, nonatomic) IBOutlet UILabel *lbTitle;
@property (strong, nonatomic) IBOutlet UILabel *lbPrice;
@property (strong, nonatomic) IBOutlet UIButton *btnX;
@property (strong, nonatomic) IBOutlet UITextField * tfQuantity;

@end
