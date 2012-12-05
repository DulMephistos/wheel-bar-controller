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
	NSUInteger _markedIndex;
}

@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *middles;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *selectionIndicatorView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat position;

- (void)scrollViewDoPaging;
- (void)moveToCurrentIndex;
- (void)redraw;

@end

@implementation PXLWheelBar

@synthesize delegate = _delegate;
@synthesize titles = _titles;
@synthesize position = _position;

@synthesize selectedIndex = _selectedIndex;
@synthesize titlesFont = _titlesFont;
@synthesize titlesColor = _titlesColor;
@synthesize titlesHighlightedColor = _titlesHighlightedColor;
@synthesize titlesShadowColor = _titlesShadowColor;
@synthesize titlesVerticalOffset = _titlesVerticalOffset;
@synthesize dividerImage = _dividerImage;
@synthesize selectionIndicatorImage = _selectionIndicatorImage;
@synthesize selectionIndicatorOffset = _selectionIndicatorOffset;
@synthesize backgroundImage = _backgroundImage;

@synthesize labels = _labels;
@synthesize middles = _middles;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize selectionIndicatorView = _selectionIndicatorView;
@synthesize scrollView = _scrollView;


#pragma mark - Initializers
- (id)initWithTitles:(NSArray *)titles
{
	self = [self initWithFrame:CGRectZero];
	if (self) {
		[self setTitles:[titles mutableCopy]];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    if (self) {
		
		_titlesFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
		_titlesColor = [UIColor lightGrayColor];
		_titlesHighlightedColor = [UIColor whiteColor];
		_titlesShadowColor = [UIColor colorWithWhite:.5f alpha:.7f];;
		_selectionIndicatorOffset = UIOffsetZero;
		_titlesVerticalOffset = 0.f;
				
		_selectedIndex = NSNotFound;
		_markedIndex = NSNotFound;
		
		UITapGestureRecognizer *labelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self addGestureRecognizer:labelTapGesture];
		
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
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
		
		[self.scrollView setContentInset:UIEdgeInsetsMake(0.f, leftSpace, 0.f, rightSpace)];
		[self.scrollView setContentOffset:CGPointMake(-leftSpace, 0.f)];
	}
	
	[self moveToCurrentIndex];
}

- (void)setFrame:(CGRect)frame
{
	BOOL shouldRedraw = NO;
	if (self.dividerImage) {
		CGFloat dividerHeight = self.dividerImage.size.height;
		CGFloat currentHeight = self.bounds.size.height;
		shouldRedraw = (frame.size.height < dividerHeight || (currentHeight < dividerHeight && frame.size.height >= dividerHeight));
	}
	
	[super setFrame:frame];
	
	if (shouldRedraw) {
		[self redraw];
	}
}

- (void)drawRect:(CGRect)rect
{
	if (self.backgroundImage || self.backgroundColor) {
		[super drawRect:rect];
	} else {
		
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		// Draw default gradient
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat locations[] = {0.f, .2f, .5f, .8f, 1.f};
		CGColorRef blackColor = [[UIColor blackColor] CGColor];
		CGColorRef darkGrayColor = [[UIColor colorWithWhite:0.33f alpha:1.f] CGColor];
		CGColorRef lightGrayColor = [[UIColor colorWithWhite:0.51f alpha:1.f] CGColor];
		CFArrayRef colors = (__bridge CFArrayRef)@[(__bridge id)blackColor, (__bridge id)darkGrayColor, (__bridge id)lightGrayColor, (__bridge id)darkGrayColor, (__bridge id)blackColor];
		
		CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
		CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(self.bounds.size.width, 0), 0);
		CGGradientRelease(gradient);
		
		// Draw top shadow
		CGFloat topLocations[] = {0.f, 1.f};
		colors = (__bridge CFArrayRef)@[(__bridge id)blackColor, (__bridge id)[[UIColor colorWithWhite:0.f alpha:0.f] CGColor]];
		gradient = CGGradientCreateWithColors(colorSpace, colors, topLocations);
		CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, 3.f), 0);
		CGGradientRelease(gradient);
		
		// Draw bottom line
		[[UIColor colorWithWhite:1.f alpha:.25f] set];
		CGContextFillRect(ctx, CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 1.f, rect.size.width, 1.f));
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIApplication sharedApplication].statusBarFrame.size.width : [UIApplication sharedApplication].statusBarFrame.size.height), kPXLWheelBarDefaultHeight);
}

#pragma mark - Appearance methods
- (void)setTitlesFont:(UIFont *)titlesFont
{
	if (![_titlesFont isEqual:titlesFont]) {
		_titlesFont = titlesFont;
		[self redraw];
	}
}

- (void)setTitlesColor:(UIColor *)titlesColor
{
	if (![_titlesColor isEqual:titlesColor]) {
		_titlesColor = titlesColor;
		[self redraw];
	}
}

- (void)setTitlesHighlightedColor:(UIColor *)titlesHighlightedColor
{
	if (![_titlesHighlightedColor isEqual:titlesHighlightedColor]) {
		_titlesHighlightedColor = titlesHighlightedColor;
		[self redraw];
	}
}

- (void)setTitlesShadowColor:(UIColor *)titlesShadowColor
{
	if (![_titlesShadowColor isEqual:titlesShadowColor]) {
		_titlesShadowColor = titlesShadowColor;
		[self redraw];
	}
}

- (void)setTitlesVerticalOffset:(CGFloat)titlesVerticalOffset
{
	if (!_titlesVerticalOffset != titlesVerticalOffset) {
		titlesVerticalOffset = _titlesVerticalOffset;
	}
	[self redraw];
}

- (void)setDividerImage:(UIImage *)dividerImage
{
	if (![_dividerImage isEqual:dividerImage]) {
		_dividerImage = dividerImage;
		[self redraw];
	}
}

- (void)setSelectionIndicatorImage:(UIImage *)selectionIndicatorImage
{
	if (![_selectionIndicatorImage isEqual:selectionIndicatorImage]) {
		_selectionIndicatorImage = selectionIndicatorImage;
		[self redraw];
	}
}

- (void)setSelectionIndicatorOffset:(UIOffset)selectionIndicatorOffset
{
	if (!UIOffsetEqualToOffset(_selectionIndicatorOffset, selectionIndicatorOffset)) {
		_selectionIndicatorOffset = selectionIndicatorOffset;
		
		if (self.selectionIndicatorImage) {
			CGRect frame = CGRectMake((self.frame.size.width - self.selectionIndicatorImage.size.width) * .5f + self.selectionIndicatorOffset.horizontal,
									  frame.origin.y = self.bounds.size.height - self.selectionIndicatorImage.size.height + self.selectionIndicatorOffset.vertical,
									  self.selectionIndicatorImage.size.width,
									  self.selectionIndicatorImage.size.height);
			[self.selectionIndicatorView setFrame:frame];
		}
	}
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
	if (![_backgroundImage isEqual:backgroundImage]) {
		_backgroundImage = backgroundImage;
		
		if (_backgroundImage == nil) {
			[_backgroundImageView removeFromSuperview];
			[self setBackgroundImageView:nil];
		} else {
			[self.backgroundImageView setImage:_backgroundImage];
			[self.backgroundImageView setFrame:self.bounds];
			[self insertSubview:self.backgroundImageView atIndex:0];
		}
		
		[self setNeedsDisplay];
	}
}

#pragma mark - Default Properties
- (UIImageView *)selectionIndicatorView
{
	if (!_selectionIndicatorView) {
		_selectionIndicatorView = [[UIImageView alloc] init];
		[_selectionIndicatorView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
	}
	
	return _selectionIndicatorView;
}

- (UIImageView *)backgroundImageView
{
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc] init];
		[_backgroundImageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	}
	
	return _backgroundImageView;
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

#pragma mark - PXLWheelBar Logic
- (void)setTitles:(NSMutableArray *)titles
{
	if (_titles != titles) {
		_titles = titles;
			
		[self redraw];
		
		if (_titles == nil)
			_selectedIndex = NSNotFound;
		else if (self.selectedIndex == NSNotFound)
			[self setSelectedIndex:0];
		else if (self.selectedIndex >= _titles.count)
			[self setSelectedIndex:_titles.count - 1];
	}
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
	if (selectedIndex >= self.titles.count) {
		[NSException raise:NSRangeException format:@"range invalid for length:%d", self.titles.count];
	}
	
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
		if (self.selectedIndex != NSNotFound && [self.delegate respondsToSelector:@selector(wheelBar:didSelectTitleAtIndex:)]) {
			[self.delegate wheelBar:self didSelectTitleAtIndex:self.selectedIndex];
		}
	}
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
	for (UIView *sub in self.subviews) {
		if (![sub isEqual:_backgroundImageView]) {
			[sub removeFromSuperview];
		}
	}
	
	self.scrollView = nil;
	self.labels = [NSMutableArray array];
	self.middles = [NSMutableArray array];
	
	[self addSubview:self.scrollView];
	
	// selection indicator image
	if (self.selectionIndicatorImage) {
		[self.selectionIndicatorView setImage:self.selectionIndicatorImage];
		CGRect frame = CGRectMake((self.frame.size.width - self.selectionIndicatorImage.size.width) * .5f + self.selectionIndicatorOffset.horizontal,
								  frame.origin.y = self.bounds.size.height - self.selectionIndicatorImage.size.height + self.selectionIndicatorOffset.vertical,
								  self.selectionIndicatorImage.size.width,
								  self.selectionIndicatorImage.size.height);
		[self.selectionIndicatorView setFrame:frame];
		[self addSubview:self.selectionIndicatorView];
	}
	
	UILabel *titleLabel = nil;
	CGFloat length = 0.f;
	CGFloat height = self.bounds.size.height;
	CGRect frameHelper;
	UIImageView *divider;
	for (int i=0; i<self.titles.count; i++) {
		titleLabel = [[UILabel alloc] init];
		[titleLabel setText:[self.titles objectAtIndex:i]];
		[titleLabel setFont:[self titlesFont]];
		[titleLabel setTextColor:[self titlesColor]];
		[titleLabel setHighlightedTextColor:[self titlesHighlightedColor]];
		[titleLabel setShadowColor:[self titlesShadowColor]];
		[titleLabel setShadowOffset:CGSizeMake(0.f, 1.f)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
		[titleLabel sizeToFit];
		
		frameHelper = titleLabel.frame;
		frameHelper.origin.x = length;
		frameHelper.origin.y = (height - frameHelper.size.height) * .5f + self.titlesVerticalOffset;
		titleLabel.frame = frameHelper;
		
		length += frameHelper.size.width;
		
		if (i < self.titles.count - 1) {
			length += kPXLWheelBarSpacer;
			
			if (self.dividerImage) {
				divider = [[UIImageView alloc] initWithImage:[self dividerImage]];
				frameHelper = divider.frame;
				frameHelper.origin.x = length - frameHelper.size.width * .5f;
				if (frameHelper.size.height > height) {
					frameHelper.size.height = height;
				} else {
					frameHelper.origin.y = (height - frameHelper.size.height) * .5f;
				}
				divider.frame = frameHelper;
				divider.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
				
				[self.middles addObject:[NSNumber numberWithFloat:length]];
				
				length += kPXLWheelBarSpacer;
				[self.scrollView addSubview:divider];
				
			} else {
				[self.middles addObject:[NSNumber numberWithFloat:length - kPXLWheelBarSpacer * .5f]];
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
