//
//  FanFeedImageCell.m
//  StarClub
//
//  Created by MAYA on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FanFeedTextCell.h"

@implementation FanFeedTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask)
    {
//        if (!IS_IOS_7)
//        {
//            for (UIView *subview in self.subviews)
//            {
//                NSLog(@"delete = %@", NSStringFromClass([subview class]));
//                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"])
//                {
//                    // hide original button
//                    [[subview.subviews objectAtIndex:0] setHidden:YES];
//                    // show my custom button
//                    [self.deleteButton setHidden:NO];
//                }
//            }
//            
//        }
//        else
        {
            for (UIView *subview in self.subviews) {
                NSLog(@"delete = %@", NSStringFromClass([subview class]));
                for (UIView *subview2 in subview.subviews) {
                    NSLog(@"delete = %@", NSStringFromClass([subview2 class]));
                    if ([NSStringFromClass([subview2 class]) rangeOfString:@"Delete"].location != NSNotFound) {
                        // hide original button
                        [subview2 setHidden:YES];
                        // show my custom button
                        [self.deleteButton setHidden:NO];
                    }
                }
            }
        }
    } else {
        // hide my custom button otherwise
        [self.deleteButton setHidden:YES];
    }
}
*/
-(void)willTransitionToState:(UITableViewCellStateMask)state{
    NSLog(@"EventTableCell willTransitionToState");
    [super willTransitionToState:state];
    if((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask){
        [self recurseAndReplaceSubViewIfDeleteConfirmationControl:self.subviews];
        [self performSelector:@selector(recurseAndReplaceSubViewIfDeleteConfirmationControl:) withObject:self.subviews afterDelay:0];
    }
}
-(void)recurseAndReplaceSubViewIfDeleteConfirmationControl:(NSArray*)subviews{
    NSString *delete_button_name = @"cell_del";
    for (UIView *subview in subviews)
    {
        //handles ios6 and earlier
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"])
        {
            //we'll add a view to cover the default control as the image used has a transparent BG
            UIView *backgroundCoverDefaultControl = [[UIView alloc] initWithFrame:CGRectMake(0,0, 64, 33)];
            [backgroundCoverDefaultControl setBackgroundColor:[UIColor whiteColor]];//assuming your view has a white BG
            [[subview.subviews objectAtIndex:0] addSubview:backgroundCoverDefaultControl];
            UIImage *deleteImage = [UIImage imageNamed:delete_button_name];
            UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,deleteImage.size.width, deleteImage.size.height)];
            [deleteBtn setImage:[UIImage imageNamed:delete_button_name]];
            [[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
        }
        //the rest handles ios7
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationButton"])
        {
//            UIButton *deleteButton = (UIButton *)subview;
//            [deleteButton setImage:[UIImage imageNamed:delete_button_name] forState:UIControlStateNormal];
//            [deleteButton setTitle:@"" forState:UIControlStateNormal];
//            [deleteButton setBackgroundColor:[UIColor clearColor]];
//            for(UIView* view in subview.subviews){
//                if([view isKindOfClass:[UILabel class]]){
//                    [view removeFromSuperview];
//                }
//            }
            
            UIView *deleteButtonView = subview;
            CGRect f = deleteButtonView.frame;
            f.origin.x += 38;
            f.size.width -= 38;
            deleteButtonView.frame = f;
            
            for(UIView* view in subview.subviews){
                if([view isKindOfClass:[UILabel class]]){
                    UILabel * label = (UILabel*)view;
                    label.text = @"Del";
                }
            }

            
        }
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"])
        {
            for(UIView* innerSubView in subview.subviews){
                if(![innerSubView isKindOfClass:[UIButton class]]){
                    [innerSubView removeFromSuperview];
                }
            }
        }
        if([subview.subviews count]>0){
            [self recurseAndReplaceSubViewIfDeleteConfirmationControl:subview.subviews];
        }
        
    }
}
@end
