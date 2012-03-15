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
#import "PhotoManager.h" //////
#define LAST_VIEWED_PHOTOS_KEY @"LAST_PHOTOS" //aggiunto da me

@class PhotoViewController;


@interface PhotoViewController :UIViewController <UISplitViewControllerDelegate, SplitViewBarButtonItemPresenter>
@property (nonatomic,strong) NSDictionary *photoToShow;
//@property (nonatomic, strong) NSURL *imageURL; //se arrvivo dal db interno, carico la foto da qui
@property (nonatomic, strong) Photo *photoFromVacation;

@end
