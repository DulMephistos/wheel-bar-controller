//
//  PXLWheelBarController.m
//  PXLWheelBar
//
//  Created by Fabio Cerdeiral on 12/01/12.
//  Copyright (c) 2012 pixel4. All rights reserved.
//

#import "PXLWheelBarController.h"
#import <QuartzCore/QuartzCore.h>

@interface PXLWheelBarController ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong, readwrite) PXLWheelBar *wheelBar;

- (void)showSnapshotsWithWheelBarPosition:(CGFloat)position;

@end

@implementation PXLWheelBarController

- (id)initWithWheelBarClass:(Class)wheelBarClass
{
	self = [super init];
	if (self) {
		_wheelBarClass = wheelBarClass;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_selectedIndex = NSNotFound;
	
	[self setContainerView:[[UIView alloc] initWithFrame:self.view.bounds]];
	[self.containerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.view addSubview:self.containerView];
}

- (void)viewDidUnload
{
	[self setViewControllers:nil];
	
	[self.containerView removeFromSuperview];
	[self setContainerView:nil];
	
    [super viewDidUnload];
}

#pragma mark - Appearance
- (void)viewWillAppear:(BOOL)animated
{
	[self.selectedViewController beginAppearanceTransition:YES animated:animated];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self.selectedViewController endAppearanceTransition];
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.selectedViewController beginAppearanceTransition:NO animated:animated];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self.selectedViewController endAppearanceTransition];
	[super viewDidDisappear:animated];
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
	return NO;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
	return NO;
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL should = YES;
	for (UIViewController *viewController in self.viewControllers) {
		should = should && [viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	}
	return should;
}

- (NSUInteger)supportedInterfaceOrientations
{
	NSUInteger supported = UIInterfaceOrientationMaskAll;
	for (UIViewController *viewController in self.viewControllers) {
		supported = supported & [viewController supportedInterfaceOrientations];
	}
	return supported;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.selectedViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Managing view controllers
- (void)setViewControllers:(NSArray *)viewControllers
{
	[self.wheelBar setDelegate:nil];
	[self.wheelBar removeFromSuperview];
	[self setWheelBar:nil];
	
	if (viewControllers.count > 0) {
		
		NSMutableArray *tempViewControllers = [NSMutableArray array];
		NSMutableArray *titles = [NSMutableArray array];
		
		for (UIViewController *viewController in viewControllers) {
			[tempViewControllers addObject:viewController];
			[titles addObject:(viewController.title ? viewController.title : @"<null>")];
		}
		
		_viewControllers = [NSArray arrayWithArray:tempViewControllers];
		
		//create wheel bar
		PXLWheelBar *wheelBar = nil;
		if (_wheelBarClass != NULL && [_wheelBarClass isSubclassOfClass:[PXLWheelBar class]]) {
			wheelBar = [[_wheelBarClass alloc] init];
		} else {
			wheelBar = [[PXLWheelBar alloc] init];
		}
		
		CGRect wheelBarFrame = CGRectZero;
		wheelBarFrame.size = [wheelBar sizeThatFits:CGSizeZero];
		
		[wheelBar setFrame:wheelBarFrame];
		[wheelBar setDelegate:self];
		[wheelBar setTitles:titles];
		[self setWheelBar:wheelBar];
		
		CGRect containerViewFrame = self.view.bounds;
		containerViewFrame.origin.y = wheelBarFrame.size.height;
		containerViewFrame.size.height -= wheelBarFrame.size.height;
		
		[self.containerView setFrame:containerViewFrame];
		[self.view addSubview:self.wheelBar];
	} else {
		
		_viewControllers = nil;
	}
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
	UIViewController *viewControllerToSelect = [self.viewControllers objectAtIndex:selectedIndex];
	[self setSelectedViewController:viewControllerToSelect];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
	NSUInteger indexToSelect = [self.viewControllers indexOfObject:selectedViewController];
	if (indexToSelect == NSNotFound || indexToSelect == self.selectedIndex)
		return;
	
	if ([self.delegate respondsToSelector:@selector(wheelBarController:shouldSelectViewController:)] &&
		![self.delegate wheelBarController:self shouldSelectViewController:selectedViewController]) {
		return;
	}
	
	CGRect viewToAddFrame = self.containerView.bounds;
	UIView *viewToAdd = selectedViewController.view;
	
	[viewToAdd setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[viewToAdd setFrame:viewToAddFrame];
	
	BOOL hasCurrentViewController = self.selectedViewController != nil;
	
	[self addChildViewController:selectedViewController];
	[selectedViewController beginAppearanceTransition:YES animated:hasCurrentViewController];
	
	if (hasCurrentViewController) {
		
		UIViewController *oldViewController = self.selectedViewController;
		UIView *oldView = oldViewController.view;
		
		UIImageView *oldViewSnapshot = [[UIImageView alloc] initWithImage:[self snapshotOfView:oldView]];
		UIImageView *viewToAddSnapshot = [[UIImageView alloc] initWithImage:[self snapshotOfView:viewToAdd]];
		
		CGFloat offset = (indexToSelect > self.selectedIndex ? viewToAddFrame.size.width : -viewToAddFrame.size.width);
		
		__block CGRect snapshotFrame = viewToAddSnapshot.frame;
		snapshotFrame.origin = viewToAddFrame.origin;
		snapshotFrame.origin.x += offset;
		viewToAddSnapshot.frame = snapshotFrame;
		
		snapshotFrame = oldViewSnapshot.frame;
		snapshotFrame.origin = viewToAddFrame.origin;
		oldViewSnapshot.frame = snapshotFrame;
		
		[self.containerView addSubview:oldViewSnapshot];
		[self.containerView addSubview:viewToAddSnapshot];
		
		[oldViewController willMoveToParentViewController:nil];
		[oldViewController beginAppearanceTransition:NO animated:YES];
		if ([oldViewController isViewLoaded] && oldView.superview == self.containerView)
			[oldView removeFromSuperview];
		
		[self.view setUserInteractionEnabled:NO];
		
		[UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
			
			viewToAddSnapshot.frame = snapshotFrame;
			snapshotFrame.origin.x -= offset;
			oldViewSnapshot.frame = snapshotFrame;
			
		} completion:^(BOOL finished) {
			
			[oldViewSnapshot removeFromSuperview];
			[viewToAddSnapshot removeFromSuperview];
			
			[oldViewController endAppearanceTransition];
			[oldViewController removeFromParentViewController];
			
			[self.containerView addSubview:viewToAdd];
			[selectedViewController endAppearanceTransition];
			[selectedViewController didMoveToParentViewController:self];
			
			[self.view setUserInteractionEnabled:YES];
			
		}];

	} else {
		
		[self.containerView addSubview:viewToAdd];
		[selectedViewController endAppearanceTransition];
		[selectedViewController didMoveToParentViewController:self];
	}
	
	_selectedViewController = selectedViewController;
	_selectedIndex = indexToSelect;
	
	if ([self.delegate respondsToSelector:@selector(wheelBarController:shouldSelectViewController:)]) {
		[self.delegate wheelBarController:self didSelectViewController:_selectedViewController];
	}
}

- (UIImage *)snapshotOfView:(UIView *)view
{

	// Create a graphics context with the target size
	// On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
	// On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
	CGSize imageSize = [view bounds].size;
	if (NULL != UIGraphicsBeginImageContextWithOptions)
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	else
		UIGraphicsBeginImageContext(imageSize);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Check to see if this is an instance of UIScrollView, if it's translate the offset of the UIScrollView
	if ([view isKindOfClass:[UIScrollView class]]) {
		UIScrollView *scrollView = (UIScrollView *)view;
		CGContextTranslateCTM(context, -scrollView.contentOffset.x, -scrollView.contentOffset.y);
	}
	
	// -renderInContext: renders in the coordinate space of the layer,
	// so we must first apply the layer's geometry to the graphics context
	CGContextSaveGState(context);
	// Center the context around the window's anchor point
	CGContextTranslateCTM(context, [view center].x, [view center].y);
	// Apply the window's transform about the anchor point
	CGContextConcatCTM(context, [view transform]);
	// Offset by the portion of the bounds left of and above the anchor point
	CGContextTranslateCTM(context,
						  -[view bounds].size.width * [[view layer] anchorPoint].x,
						  -[view bounds].size.height * [[view layer] anchorPoint].y);
	
	// Render the layer hierarchy to the current context
	[[view layer] renderInContext:context];
	
	// Restore the context
	//	CGContextRestoreGState(context);
	
	// Retrieve the screenshot image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return image;
}

- (void)showSnapshotForAnimationWithIndex:(NSUInteger)index position:(CGFloat)position
{
	UIViewController *viewController = (index >= self.viewControllers.count ? nil : [self.viewControllers objectAtIndex:index]);
	UIView *snapshot = viewController.view;
	CGRect rect = CGRectNull;
	
	if (snapshot != nil) {
		if (![snapshot superview]) {
			[self addChildViewController:viewController];
			[viewController beginAppearanceTransition:YES animated:NO];
			[self.containerView addSubview:snapshot];
			[viewController endAppearanceTransition];
			[viewController didMoveToParentViewController:self];
		}
		
		rect = self.containerView.bounds;
		rect.origin.x = (-position + index) * self.view.frame.size.width;
		snapshot.frame = rect;
	}
}

- (void)showSnapshotsWithWheelBarPosition:(CGFloat)position
{
	NSUInteger leftIndex = (position < 0 ? NSNotFound : (int)position);
	NSUInteger rightIndex = (position < 0 ? 0 : (position - leftIndex == 0.0f ? NSNotFound : leftIndex + 1));
	
//	NSLog(@"leftIndex:%d, rightIndex:%d", leftIndex, rightIndex);
	
	[self showSnapshotForAnimationWithIndex:leftIndex position:position];
	[self showSnapshotForAnimationWithIndex:rightIndex position:position];
	
	for (int i=0; i<self.viewControllers.count; i++) {
		if (i != leftIndex && i != rightIndex) {
			UIViewController *viewController = [self.viewControllers objectAtIndex:i];
			if ([viewController.parentViewController isEqual:self]) {
				[viewController willMoveToParentViewController:nil];
				[viewController beginAppearanceTransition:NO animated:NO];
				if ([viewController isViewLoaded] && viewController.view.superview == self.containerView)
					[viewController.view removeFromSuperview];
				[viewController endAppearanceTransition];
				[viewController removeFromParentViewController];
			}			
		}
	}
}

#pragma mark - PXLWheelBarDelegate Methods
- (void)wheelBar:(PXLWheelBar *)wheelBar didSelectTitleAtIndex:(NSUInteger)index
{
//	NSLog(@"did select title at index");
	[self setSelectedViewController:[self.viewControllers objectAtIndex:index]];
}

- (void)wheelBarWillBeginAnimating:(PXLWheelBar *)wheelBar
{
//	NSLog(@"will begin animating");
	[self.containerView setUserInteractionEnabled:NO];

	[self showSnapshotsWithWheelBarPosition:wheelBar.position];
}

- (void)wheelBarDidScroll:(PXLWheelBar *)wheelBar
{
//	NSLog(@"did scroll");
	[self showSnapshotsWithWheelBarPosition:wheelBar.position];
}

- (void)wheelBarDidEndAnimating:(PXLWheelBar *)wheelBar
{
//	NSLog(@"did end animating at position: %f", wheelBar.position);
	_selectedViewController = nil;
	_selectedIndex = (int)roundf(wheelBar.position);
	_selectedViewController = [self.viewControllers objectAtIndex:self.selectedIndex];
	
	for (UIViewController *viewController in self.viewControllers) {
		if (![viewController isEqual:self.selectedViewController] && [viewController.parentViewController isEqual:self]) {
			[viewController willMoveToParentViewController:nil];
			[viewController.view removeFromSuperview];
			[viewController removeFromParentViewController];
		}
	}
	
	UIView *viewAdded = self.selectedViewController.view;
	CGRect rect = viewAdded.frame;
	rect.origin.x = 0;
	viewAdded.frame = rect;
	
	[self.containerView setUserInteractionEnabled:YES];
}

@end

@implementation UIViewController (PXLWheelBarControllerItem)

- (PXLWheelBarController *)wheelBarController
{
	UIViewController *parent = self.parentViewController;
	while (parent != nil) {
		if ([parent isKindOfClass:[PXLWheelBarController class]]) {
			return (PXLWheelBarController *)parent;
		}
		parent = parent.parentViewController;
	}
	
	return nil;
}

@end
