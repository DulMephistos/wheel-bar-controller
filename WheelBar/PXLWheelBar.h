//
//  PXLWheelBar.h
//  PXLWheelBar
//
//  Created by Fabio Teles on 7/22/12.
//  Copyright (c) 2012 pixel4. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PXLWheelBarDelegate;
@interface PXLWheelBar : UIView <UIScrollViewDelegate> {
	UIFont *_font;
	UIColor *_color;
	UIColor *_highlightedColor;
	BOOL _animating;
}

@property (weak, nonatomic) id<PXLWheelBarDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *titles;
@property (nonatomic, readonly) CGFloat position;
@property (nonatomic) NSUInteger selectedIndex;

- (id)initWithFont:(UIFont *)font color:(UIColor *)color highlightedColor:(UIColor *)highlightedColor titles:(NSArray *)titles; // default initializer

- (void)customizeFont:(UIFont *)font color:(UIColor *)color highlightedColor:(UIColor *)highlightedColor;
- (void)redraw;

@end

@protocol PXLWheelBarDelegate <NSObject>
@optional
- (void)wheelBar:(PXLWheelBar *)wheelBar didSelectTitleAtIndex:(NSUInteger)index;
- (void)wheelBarWillBeginAnimating:(PXLWheelBar *)wheelBar;
- (void)wheelBarDidEndAnimating:(PXLWheelBar *)wheelBar;
- (void)wheelBarDidScroll:(PXLWheelBar *)wheelBar;
@end
