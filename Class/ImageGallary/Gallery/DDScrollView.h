//
//  DDScrollView.h
//  PhotoAlbum0.0.1
//
//  Created by Pa on 5/19/10.
//  Copyright 2010 CCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DDScrollViewDelegate.h"
#import "DDScrollViewDataSource.h"

@interface UIView (DDCategory)

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat height;

@end

#define DD_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define DD_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

@protocol DDScrollViewDelegate;
@protocol DDScrollViewDataSource;

@interface DDScrollView : UIView {
  NSInteger       _centerPageIndex;
  NSInteger       _visiblePageIndex;
  BOOL            _scrollEnabled;
  BOOL            _zoomEnabled;
  BOOL            _rotateEnabled;
  CGFloat         _pageSpacing;
  NSTimeInterval  _holdsAfterTouchingForInterval;

  UIInterfaceOrientation  _orientation;

  id<DDScrollViewDelegate>    _delegate;
  id<DDScrollViewDataSource>  _dataSource;

  NSMutableArray* _pages;
  NSMutableArray* _pageQueue;
  NSInteger       _maxPages;
  NSInteger       _pageArrayIndex;
  NSTimer*        _tapTimer;
  NSTimer*        _holdingTimer;
  NSTimer*        _animationTimer;
  NSDate*         _animationStartTime;
  NSTimeInterval  _animationDuration;
  UIEdgeInsets    _animateEdges;

  // The offset of the page edges from the edge of the screen.
  UIEdgeInsets    _pageEdges;

  // At the beginning of an animation, the page edges are cached within this member.
  UIEdgeInsets    _pageStartEdges;

  UIEdgeInsets    _touchEdges;
  UIEdgeInsets    _touchStartEdges;
  NSUInteger      _touchCount;
  CGFloat         _overshoot;

  // The first touch in this view.
  UITouch*        _touch1;

  // The second touch in this view.
  UITouch*        _touch2;

  BOOL            _dragging;
  BOOL            _zooming;
  BOOL            _holding;
	
	UIPageControl *pageControl;
	BOOL pageControlUsed;
}

/**
 * The current page index.
 */
@property (nonatomic) NSInteger centerPageIndex;

/**
 * Whether or not the current page is zoomed.
 */
@property (nonatomic, readonly) BOOL zoomed;

@property (nonatomic, readonly) BOOL holding;

/**
 * @default YES
 */
@property (nonatomic) BOOL scrollEnabled;

/**
 * @default YES
 */
@property (nonatomic) BOOL zoomEnabled;

/**
 * @default YES
 */
@property (nonatomic) BOOL rotateEnabled;

/**
 * @default 40
 */
@property (nonatomic) CGFloat pageSpacing;

@property (nonatomic)           UIInterfaceOrientation  orientation;
@property (nonatomic, readonly) NSInteger               numberOfPages;
@property (nonatomic, readonly) UIView*                 centerPage;

/**
 * The number of seconds to wait before initiating the "hold" action.
 *
 * @default 0
 */
@property (nonatomic) NSTimeInterval holdsAfterTouchingForInterval;


@property (nonatomic, assign) id<DDScrollViewDelegate>    delegate;
@property (nonatomic, assign) id<DDScrollViewDataSource>  dataSource;

/**
 * A dictionary of visible pages keyed by the index of the page.
 */
@property (nonatomic, readonly) NSDictionary* visiblePages;

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/**
 * Gets a previously created page view that has been moved off screen and recycled.
 */
- (UIView*)dequeueReusablePage;

- (void)reloadData;

- (UIView*)pageAtIndex:(NSInteger)pageIndex;

- (void)zoomToFit;

- (void)zoomToDistance:(CGFloat)distance;

/**
 * Cancels any active touches and resets everything to an untouched state.
 */
- (void)cancelTouches;
- (void)setCenterPageIndex:(NSInteger)pageIndex;

@end
