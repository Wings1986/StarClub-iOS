//
//  MenuCell.h
//
//  Created by MAYA on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lbDetail;
@property (strong, nonatomic) IBOutlet UIButton *btnComment;
@property (strong, nonatomic) IBOutlet UILabel *lbComment;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) IBOutlet UIButton *btnAddComment;

@property (strong, nonatomic) IBOutlet UILabel *lbLikeNum;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;


@property (strong, nonatomic) IBOutlet UIView *viewLock;
@property (strong, nonatomic) IBOutlet UILabel *lbLockNum;


@property (strong, nonatomic) IBOutlet UIImageView * ivVideoIcon;

@end
