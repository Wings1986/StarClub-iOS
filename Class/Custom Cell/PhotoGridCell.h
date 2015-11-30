//
//  PhotoGridCell.h
//  StarClub
//
//  Created by MAYA on 4/22/14.
//
//

#import <UIKit/UIKit.h>

@interface PhotoGridCell : UICollectionViewCell


@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *mSpinner;
@property (nonatomic, strong) IBOutlet UIImageView * imgPhoto;
@property (nonatomic, strong) IBOutlet UIImageView * imgLock;

@end
