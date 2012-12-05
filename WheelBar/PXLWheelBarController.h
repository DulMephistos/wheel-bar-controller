//
//  PXLWheelBarController.h
//  PXLWheelBar
//
//  Created by Fabio Cerdeiral on 12/01/12.
//  Copyright (c) 2012 pixel4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXLWheelBar.h"

@protocol PXLWheelBarControllerDelegate;
@interface PXLWheelBarController : UIViewController <PXLWheelBarDelegate> {
	@package
	Class _wheelBarClass;
}

@property (strong, readonly, nonatomic) PXLWheelBar *wheelBar;
@property (copy, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIViewController *selectedViewController;
@property (assign, nonatomic) NSUInteger selectedIndex;
@property (weak, nonatomic) id<PXLWheelBarControllerDelegate> delegate;

- (id)initWithWheelBarClass:(Class)wheelBarClass;
- (UIImage *)snapshotOfView:(UIView *)view;

@end


@protocol PXLWheelBarControllerDelegate <NSObject>
@optional
- (BOOL)wheelBarController:(PXLWheelBarController *)controller shouldSelectViewController:(UIViewController *)viewController;
- (void)wheelBarController:(PXLWheelBarController *)controller didSelectViewController:(UIViewController *)viewController;
@end

@interface UIViewController (PXLWheelBarControllerItem)

@property (strong, readonly, nonatomic) PXLWheelBarController *wheelBarController;

@end