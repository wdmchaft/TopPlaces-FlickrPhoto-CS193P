//
//  myTabBarVC.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 05/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "myTabBarVC.h"

@implementation myTabBarVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];
    [self.tabBar setBackgroundImage:tabBarBackground]; //se fossi in una VC contenuta da un tabbarVC dovrei usare self.tabBarController.tabbar
    //self.tabBar.tintColor=[UIColor blueColor];
    
    UITabBar *tabBar = self.tabBar;
    
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    
    [item0 setTitle:@"Top Places"]; //solo se è 'custom'
    [item1 setTitle:@"Recent Photos"];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end