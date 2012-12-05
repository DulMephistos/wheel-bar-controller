//
//  Demo2ViewController.m
//  WheelBarDemo
//
//  Created by fabio teles on 12/4/12.
//  Copyright (c) 2012 pixel4. All rights reserved.
//

#import "Demo2ViewController.h"

@interface Demo2ViewController ()

@end

@implementation Demo2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIViewController *v1 = [[UIViewController alloc] init];
	UIViewController *v2 = [[UIViewController alloc] init];
	UIViewController *v3 = [[UIViewController alloc] init];
	UIViewController *v4 = [[UIViewController alloc] init];
	
	[v1 setTitle:@"Health & Fitness"];
	[v2 setTitle:@"Navigation"];
	[v3 setTitle:@"Social Networking"];
	[v4 setTitle:@"Weather"];
	
	[v1.view setBackgroundColor:[UIColor brownColor]];
	[v2.view setBackgroundColor:[UIColor cyanColor]];
	[v3.view setBackgroundColor:[UIColor orangeColor]];
	[v4.view setBackgroundColor:[UIColor purpleColor]];
	
	[self setViewControllers:@[v1, v2, v3, v4]];
	[self.wheelBar setBackgroundImage:[UIImage imageNamed:@"wheelBar-background.png"]];
	[self.wheelBar setDividerImage:[UIImage imageNamed:@"wheelBar-divider.png"]];
	[self.wheelBar setSelectionIndicatorImage:[UIImage imageNamed:@"wheelBar-bullet.png"]];
	
	[self.wheelBar setSelectionIndicatorOffset:UIOffsetMake(0, -5.f)];
	[self.wheelBar setTitlesColor:[UIColor whiteColor]];
	[self.wheelBar setTitlesHighlightedColor:[UIColor colorWithRed:.52f green:.75f blue:0.f alpha:1.f]];
	[self.wheelBar setTitlesShadowColor:[UIColor colorWithWhite:0.f alpha:.6f]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
