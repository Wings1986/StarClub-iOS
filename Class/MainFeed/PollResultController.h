//
//  PollResultController.h
//  StarClub
//

#import "BaseViewController.h"

@interface PollResultController : BaseViewController


- (id) initWithData:(NSMutableDictionary *) dic : (NSString*) answerId question: (NSString*) questionId done:(BOOL) bFinish;
    
@end
