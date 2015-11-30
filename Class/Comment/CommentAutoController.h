//
//  CommentAutoController.h
//  StarClub
//

#import "BaseViewController.h"

@protocol CommentAutoControllerDelegate

- (void) commentDone:(int) index comments:(NSArray*) arrComment count:(int) totalComment;

@end


@interface CommentAutoController : ParentTableViewController<UITextViewDelegate>
{
    IBOutlet UIView * viewSend;
    IBOutlet UITextView * txtPost;
    IBOutlet UIImageView * imgAvatar;
    
    BOOL    keyboardVisible;

}

@property (nonatomic, strong) id<CommentAutoControllerDelegate> delegate;


-(id) initWithData:(NSDictionary*) dic index:(int) index;
-(id) initWithAddComment:(NSDictionary*) dic index:(int) index;


@end
