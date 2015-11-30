//
//  ShopListCell.h
//

#import <UIKit/UIKit.h>

@interface ShopListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lbLocation;
@property (strong, nonatomic) IBOutlet UILabel *lbTitle;
@property (strong, nonatomic) IBOutlet UILabel *lbPrice;
@property (strong, nonatomic) IBOutlet UIButton *btnAddCart;

@end
