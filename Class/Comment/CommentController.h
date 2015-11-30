//
//  CommentController.h
//  StarClub
//
//  Created by MAYA on 1/3/14.
//
//

#import "BaseViewController.h"

@protocol CommentControllerDelegate

- (void) commentDone:(int) index comments:(NSArray*) arrComment;

@end


@interface CommentController : BaseViewController<UITextViewDelegate>
{
    IBOutlet UIView * viewSend;
    IBOutlet UITextView * txtPost;
    IBOutlet UIImageView * imgAvatar;
    
    BOOL    keyboardVisible;

}

@property (nonatomic, strong) id<CommentControllerDelegate> delegate;


-(id) initWithData:(NSDictionary*) dic index:(int) index;
-(id) initWithAddComment:(NSDictionary*) dic index:(int) index;


@end
