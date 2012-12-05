//
//  DemoViewController.m
//  WheelBarDemo
//
//  Created by fabio teles on 12/4/12.
//  Copyright (c) 2012 pixel4. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIViewController *v1 = [[UIViewController alloc] init];
	UIViewController *v2 = [[UIViewController alloc] init];
	UIViewController *v3 = [[UIViewController alloc] init];
	
	[v1 setTitle:@"Books"];
	[v2 setTitle:@"Entertainment"];
	[v3 setTitle:@"Medical"];
	
	[v1.view setBackgroundColor:[UIColor redColor]];
	[v2.view setBackgroundColor:[UIColor blueColor]];
	[v3.view setBackgroundColor:[UIColor greenColor]];
	
	[self setViewControllers:@[v1, v2, v3]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
