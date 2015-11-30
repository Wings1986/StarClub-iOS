//
//  BasePostViewController.h
//  StarClub
//
//  Created by SilverStar on 7/23/14.
//
//

#import "BaseViewController.h"

@interface BasePostViewController : BaseViewController
{
    NSMutableDictionary*    m_postObj;

    BOOL m_bIsPublished;
}

- (void) setResultDic:(NSDictionary* ) result image:(UIImage*) imagePhoto;
- (void) onShare;

- (void) changeCaptionText:(NSString *)textCaption;

@end
