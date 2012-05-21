//
//  PhotoViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "Photo+Flickr.h"
#import "PhotoManager.h" 
#define LAST_VIEWED_PHOTOS_KEY @"LAST_PHOTOS" 
@class PhotoViewController;


@interface PhotoViewController :UIViewController <UISplitViewControllerDelegate, SplitViewBarButtonItemPresenter>

@property (nonatomic,strong) NSDictionary *photoToShow;  //flickr
@property (nonatomic, strong) Photo *photoFromVacation;  //db

@end
