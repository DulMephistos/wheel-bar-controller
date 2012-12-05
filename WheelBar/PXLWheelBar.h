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
	BOOL _animating;
}

@property (weak, nonatomic) id<PXLWheelBarDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *titles;
@property (assign, nonatomic, readonly) CGFloat position;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (strong, nonatomic) UIFont *titlesFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *titlesColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *titlesHighlightedColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *titlesShadowColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat titlesVerticalOffset UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIImage *dividerImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIImage *selectionIndicatorImage UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) UIOffset selectionIndicatorOffset UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

- (id)initWithTitles:(NSArray *)titles;

@end

@protocol PXLWheelBarDelegate <NSObject>
@optional
- (void)wheelBar:(PXLWheelBar *)wheelBar didSelectTitleAtIndex:(NSUInteger)index;
- (void)wheelBarWillBeginAnimating:(PXLWheelBar *)wheelBar;
- (void)wheelBarDidEndAnimating:(PXLWheelBar *)wheelBar;
- (void)wheelBarDidScroll:(PXLWheelBar *)wheelBar;
@end
