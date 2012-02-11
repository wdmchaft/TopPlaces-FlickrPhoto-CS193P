//
//  LastViewedPhotosTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LastViewedPhotosTableViewController.h"

@implementation LastViewedPhotosTableViewController

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect bounds = [self.parentViewController.view bounds];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //[spinner setBackgroundColor:[UIColor redColor]];
    [spinner setCenter:centerPoint];
    self.tableView.hidden = YES;
    [self.parentViewController.view addSubview:spinner];
    [spinner startAnimating];

    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue,^{
        //block

     NSMutableOrderedSet *lastPhotos = [NSMutableOrderedSet orderedSetWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_VIEWED_PHOTOS_KEY]];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.hidden = NO;
            [spinner stopAnimating];
            [spinner hidesWhenStopped];
           self.recentPhotos = [[lastPhotos reversedOrderedSet] array]; //modifica la UI (tabella) per questo lo metto nella main queue
            
        });
        
    });
    dispatch_release(downloadQueue); //altrimenti c'è un memory leak


}

@end
