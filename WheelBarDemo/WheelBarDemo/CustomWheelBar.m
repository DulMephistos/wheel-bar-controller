//
//  CustomWheelBar.m
//  WheelBarDemo
//
//  Created by fabio teles on 12/4/12.
//  Copyright (c) 2012 pixel4. All rights reserved.
//

#import "CustomWheelBar.h"

@implementation CustomWheelBar

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIApplication sharedApplication].statusBarFrame.size.width : [UIApplication sharedApplication].statusBarFrame.size.height), 63.f);
}

@end
