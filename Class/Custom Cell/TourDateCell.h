//
//  TourDateCell.h

#import <UIKit/UIKit.h>

@interface TourDateCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lbShortDate;
@property (strong, nonatomic) IBOutlet UILabel *lbLocation;
@property (strong, nonatomic) IBOutlet UILabel *lbTitle;
@property (strong, nonatomic) IBOutlet UILabel *lbLongDate;
@property (strong, nonatomic) IBOutlet UIButton *btnDetail;

@end
