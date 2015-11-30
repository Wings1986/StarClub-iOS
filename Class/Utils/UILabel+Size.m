
#import "UILabel+Size.h"

@implementation UILabel (Size)

+(CGSize) GetSizeOfLabelForGivenText:(UILabel*)label Font:(UIFont*)fontForLabel Size:  (CGSize) constraintSize{
    label.numberOfLines = 0;
    CGRect labelSize = [label.text boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:fontForLabel} context:nil];
    return labelSize.size;
}

@end
