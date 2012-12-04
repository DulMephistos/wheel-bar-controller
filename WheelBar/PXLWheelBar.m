//
//  PXLWheelBar.m
//  PXLWheelBar
//
//  Created by Fabio Teles on 7/22/12.
//  Copyright (c) 2012 pixel4. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PXLWheelBar.h"

#define kPXLWheelBarSpacer 10.f
#define kPXLWheelBarDefaultHeight 42.f

@interface PXLWheelBar () {
	CGFloat _selectionIndicatorOffset;
	NSUInteger _markedIndex;
}

@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *middles;
@property (strong, nonatomic) UIView *bottomBar;
@property (strong, nonatomic) UIImageView *selectionIndicator;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat position;

- (void)scrollViewDoPaging;
- (void)moveToCurrentIndex;

@end

@implementation PXLWheelBar

#pragma mark - Initializers
- (id)initWithFont:(UIFont *)font color:(UIColor *)color highlightedColor:(UIColor *)highlightedColor titles:(NSArray *)titles
{
	self = [super initWithFrame:CGRectZero];
	if (self) {
		_font = font;
		_color = color;
		_highlightedColor = highlightedColor;
		_selectedIndex = NSNotFound;
		_markedIndex = NSNotFound;
		
		[self setTitles:[titles mutableCopy]];
		
		UITapGestureRecognizer *labelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self addGestureRecognizer:labelTapGesture];
		
		[self setBackgroundColor:[UIColor blackColor]];
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] color:[UIColor blackColor] highlightedColor:[UIColor whiteColor] titles:nil];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (self.labels.count > 0) {
		UILabel *lbl = (UILabel *)[self.labels objectAtIndex:0];
		CGFloat leftSpace = self.scrollView.frame.size.width * .5f - lbl.frame.size.width * .5f;
		lbl = (UILabel *)[self.labels lastObject];
		CGFloat rightSpace = self.scrollView.frame.size.width * .5f - lbl.frame.size.width * .5f;
		self.scrollView.contentInset = UIEdgeInsetsMake(0.f, leftSpace, 0.f, rightSpace);
		self.scrollView.contentOffset = CGPointMake(-leftSpace, 0.f);
	}
	
	[self moveToCurrentIndex];
}

- (void)setFrame:(CGRect)frame
{
	BOOL shouldRedraw = (self.frame.size.height < 14.f && frame.size.height >= 14.f) ||
						(self.frame.size.height >= 14.f && frame.size.height < 14.f);
	[super setFrame:frame];
	
	if (shouldRedraw)
		[self redraw];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIApplication sharedApplication].statusBarFrame.size.width : [UIApplication sharedApplication].statusBarFrame.size.height), kPXLWheelBarDefaultHeight);
}

#pragma mark - Properties
- (UIView *)bottomBar
{
	if (!_bottomBar) {
		_bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.frame.size.height - 2.f, self.frame.size.width, 2.f)];
		[_bottomBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
		[_bottomBar setBackgroundColor:_highlightedColor];
		[_bottomBar setClipsToBounds:NO];
		
		[_bottomBar addSubview:self.selectionIndicator];
		
		[_bottomBar.layer setShadowColor:[UIColor darkGrayColor].CGColor];
		[_bottomBar.layer setShadowOffset:CGSizeZero];
		[_bottomBar.layer setShadowRadius:6.f];
		[_bottomBar.layer setShadowOpacity:1.f];
	}
	
	return _bottomBar;
}

- (UIImageView *)selectionIndicator
{
	if (!_selectionIndicator) {
		_selectionIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-bar-selection-indicator.png"]];
		_selectionIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		CGRect frame = _selectionIndicator.frame;
		frame.origin.x = (self.frame.size.width - frame.size.width) * .5f;
		frame.origin.y = -6.f;
		_selectionIndicator.frame = frame;
	}
	
	return _selectionIndicator;
}

- (UIScrollView *)scrollView
{
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
		[_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_scrollView setShowsHorizontalScrollIndicator:NO];
		[_scrollView setShowsVerticalScrollIndicator:NO];
		[_scrollView setBackgroundColor:[UIColor clearColor]];
		[_scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
		[_scrollView setAlwaysBounceHorizontal:YES];
		[_scrollView setDelegate:self];
	}
	return _scrollView;
}

- (void)setTitles:(NSMutableArray *)titles
{
	_titles = titles;
		
	[self redraw];
	
	if (_titles == nil)
		_selectedIndex = NSNotFound;
	else if (self.selectedIndex == NSNotFound)
		[self setSelectedIndex:0];
	else if (self.selectedIndex >= _titles.count)
		[self setSelectedIndex:_titles.count - 1];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
	if (selectedIndex >= self.titles.count)
		[NSException raise:NSRangeException format:@"range invalid for length:%d", self.titles.count];
	
	_selectedIndex = selectedIndex;
	
	if (!_animating) {
		if ([self.delegate respondsToSelector:@selector(wheelBar:didSelectTitleAtIndex:)]) {
			[self.delegate wheelBar:self didSelectTitleAtIndex:selectedIndex];
		}
	}
	
	[self moveToCurrentIndex];
}

- (void)setDelegate:(id<PXLWheelBarDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		if (self.selectedIndex != NSNotFound && [self.delegate respondsToSelector:@selector(wheelBar:didSelectTitleAtIndex:)])
			[self.delegate wheelBar:self didSelectTitleAtIndex:self.selectedIndex];
	}
}

#pragma mark - PXLWheelBar Logic
- (void)customizeFont:(UIFont *)font color:(UIColor *)color highlightedColor:(UIColor *)highlightedColor
{
	_font = font;
	_color = color;
	_highlightedColor = highlightedColor;
	
	if (self.titles != nil)
		[self redraw];
}

- (void)moveToCurrentIndex
{
	if (self.selectedIndex != NSNotFound && !CGRectEqualToRect(self.frame, CGRectZero)) {
		
		UILabel *label = (UILabel *)[self.labels objectAtIndex:self.selectedIndex];
		label = [self.labels objectAtIndex:self.selectedIndex];
		UILabel *firstLabel = (UILabel *)[self.labels objectAtIndex:0];
		CGFloat firstLabelHalf = firstLabel.frame.size.width * .5f;
		CGFloat labelMiddle = label.frame.origin.x + label.frame.size.width * .5f;
		NSInteger destX = floorf(labelMiddle - self.scrollView.contentInset.left - firstLabelHalf);
		
		if (destX != self.scrollView.contentOffset.x) {
			[self.scrollView setContentOffset:CGPointMake(destX, 0) animated:YES];
			[self.scrollView setUserInteractionEnabled:NO];
			
		} else if (_animating) {
			_animating = NO;
			if ([self.delegate respondsToSelector:@selector(wheelBarDidEndAnimating:)]) {
				[self.delegate wheelBarDidEndAnimating:self];
			}
		}
	}
}

- (void)redraw
{
	for (UIView *sub in self.subviews)
		[sub removeFromSuperview];
	
	self.scrollView = nil;
	self.labels = [NSMutableArray array];
	self.middles = [NSMutableArray array];
	
	[self addSubview:self.scrollView];
	[self addSubview:self.bottomBar];
	
	UILabel *titleLabel = nil;
	CGFloat length = 0.f;
	CGRect frameHelper;
	UIImageView *separator;
	for (int i=0; i<self.titles.count; i++) {
		titleLabel = [[UILabel alloc] init];
		titleLabel.text = [self.titles objectAtIndex:i];
		titleLabel.font = _font;
		titleLabel.textColor = _color;
		titleLabel.highlightedTextColor = _highlightedColor;
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[titleLabel sizeToFit];
		
		frameHelper = titleLabel.frame;
		frameHelper.origin.x = length;
		frameHelper.origin.y = (self.frame.size.height - frameHelper.size.height) * .5f;
		titleLabel.frame = frameHelper;
		
		length += frameHelper.size.width;
		
		if (i < self.titles.count - 1) {
			length += kPXLWheelBarSpacer;
			
			if (self.frame.size.height >= 14.f) {
				separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-bar-separator.png"]];
				frameHelper = separator.frame;
				frameHelper.origin.x = length;
				frameHelper.origin.y = 7.f;
				separator.frame = frameHelper;
				separator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
				
				[self.middles addObject:[NSNumber numberWithFloat:length]];
				
				length += kPXLWheelBarSpacer;
				[self.scrollView addSubview:separator];
				
			} else {
				[self.middles addObject:[NSNumber numberWithFloat:length * .5f]];
			}
		}
		
		[self.scrollView addSubview:titleLabel];
		
		[self.labels addObject:titleLabel];
	}
	
	[self.scrollView setContentSize:CGSizeMake(length, self.scrollView.frame.size.height)];
	[self setNeedsLayout];
}

- (void)scrollViewDoPaging
{
	if (self.middles.count > 0) {
		NSUInteger nextIndex = self.labels.count-1;
		UILabel *label = (UILabel *)[self.labels objectAtIndex:0];
		CGFloat firstLabelHalf = label.frame.size.width * .5f;
		CGFloat offX = self.scrollView.contentOffset.x + self.scrollView.contentInset.left + firstLabelHalf;
		CGFloat middle = 0.f;
		for (int i=0; i<self.middles.count; i++) {
			middle = [[self.middles objectAtIndex:i] floatValue];
			if (offX < middle) {
				nextIndex = i;
				break;
			}
		}
		
		[self setSelectedIndex:nextIndex];
	}
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
	NSUInteger indexTapped = NSUIntegerMax;
	
	CGPoint tapLocation = [gesture locationInView:gesture.view];
	tapLocation.x += self.scrollView.contentOffset.x;
	
	for (int i=0; i<self.middles.count; i++) {
		if ([[self.middles objectAtIndex:i] floatValue] > tapLocation.x) {
			indexTapped = i;
			break;
		}
	}
	
	if (indexTapped == NSUIntegerMax)
		indexTapped = self.middles.count;
	
	if (indexTapped != self.selectedIndex)
		[self setSelectedIndex:indexTapped];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)theScrollView
{
	// setting position property
	NSUInteger nextIndex = NSNotFound;
	UILabel *label = (UILabel *)[self.labels objectAtIndex:0];
	CGFloat firstLabelHalf = label.frame.size.width * .5f;
	CGFloat offX = floorf(self.scrollView.contentOffset.x + self.scrollView.contentInset.left + firstLabelHalf);
	label = (UILabel *)[self.labels lastObject];
	CGFloat middle = 0;
	for (int i=0; i<self.middles.count; i++) {
		middle = [[self.middles objectAtIndex:i] floatValue];
		if (offX < middle) {
			nextIndex = i;
			break;
		}
	}
	
	if (nextIndex == NSNotFound) {
		nextIndex = self.labels.count-1;
		middle = label.frame.origin.x + label.frame.size.width + kPXLWheelBarSpacer;
	}

	label = (UILabel *)[self.labels objectAtIndex:nextIndex];
	CGFloat nextPoint = floorf(label.frame.origin.x + label.frame.size.width * .5f);
	CGFloat len = middle - nextPoint;
	self.position = (CGFloat)nextIndex - (nextPoint - offX) / len * .5f;
	
	// marking centered label
	if (_markedIndex != nextIndex) {
		if (_markedIndex != NSNotFound && _markedIndex < self.titles.count) {
			UILabel *oldLabel = (UILabel *)[self.labels objectAtIndex:_markedIndex];
			oldLabel.highlighted = NO;
		}
		label.highlighted = YES;
		_markedIndex = nextIndex;
	}
	
	if (_animating && [self.delegate respondsToSelector:@selector(wheelBarDidScroll:)]) {
		[self.delegate wheelBarDidScroll:self];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
	if (!_animating) {
		if ([self.delegate respondsToSelector:@selector(wheelBarWillBeginAnimating:)]) {
			[self.delegate wheelBarWillBeginAnimating:self];
		}
		_animating = YES;
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	[aScrollView setUserInteractionEnabled:YES];
	if (_animating && !aScrollView.tracking) {
		if (self.position - (int)self.position != 0.f) {
			[self scrollViewDoPaging];
		} else {
			_animating = NO;
			if ([self.delegate respondsToSelector:@selector(wheelBarDidEndAnimating:)]) {
				[self.delegate wheelBarDidEndAnimating:self];
			}
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
	if (!aScrollView.tracking)
		[self scrollViewDoPaging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
		[self scrollViewDoPaging];
}

@end
