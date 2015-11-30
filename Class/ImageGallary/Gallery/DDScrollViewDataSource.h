//
//  TTScrollViewDataSource.h
//  PhotoAlbum0.0.1
//
//  Created by Pa on 5/19/10.
//  Copyright 2010 CCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DDScrollView;

@protocol DDScrollViewDataSource <NSObject>

- (NSInteger)numberOfPagesInScrollView:(DDScrollView*)scrollView;

/**
 * Gets a view to display for the page at the given index.
 *
 * You do not need to position or size the view as that is done for you later.  You should
 * call dequeueReusablePage first, and only create a new view if it returns nil.
 */
- (UIView*)scrollView:(DDScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex;

/**
 * Gets the natural size of the page.
 *
 * The actual width and height are not as important as the ratio between width and height.
 *
 * If the size is not specified, then the size of the page is used.
 */
- (CGSize)scrollView:(DDScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex;

@end
