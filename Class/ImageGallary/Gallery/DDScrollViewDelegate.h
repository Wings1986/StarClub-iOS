//
//  DDScrollViewDelegate.h
//  PhotoAlbum0.0.1
//
//  Created by Pa on 5/19/10.
//  Copyright 2010 CCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DDScrollView;

@protocol DDScrollViewDelegate <NSObject>

@required

- (void)scrollView:(DDScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

- (void)scrollViewWillRotate: (DDScrollView*)scrollView toOrientation: (UIInterfaceOrientation)orientation;

- (void)scrollViewDidRotate:(DDScrollView*)scrollView;

- (void)scrollViewWillBeginDragging:(DDScrollView*)scrollView;

- (void)scrollViewDidEndDragging:(DDScrollView*)scrollView willDecelerate:(BOOL)willDecelerate;

- (void)scrollViewDidEndDecelerating:(DDScrollView*)scrollView;

- (BOOL)scrollViewShouldZoom:(DDScrollView*)scrollView;

- (void)scrollViewDidBeginZooming:(DDScrollView*)scrollView;

- (void)scrollViewDidEndZooming:(DDScrollView*)scrollView;

- (void)scrollView:(DDScrollView*)scrollView touchedDown:(UITouch*)touch;

- (void)scrollView:(DDScrollView*)scrollView touchedUpInside:(UITouch*)touch;

- (void)scrollView:(DDScrollView*)scrollView tapped:(UITouch*)touch;

- (void)scrollViewDidBeginHolding:(DDScrollView*)scrollView;

- (void)scrollViewDidEndHolding:(DDScrollView*)scrollView;

- (BOOL)scrollView:(DDScrollView*)scrollView shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
