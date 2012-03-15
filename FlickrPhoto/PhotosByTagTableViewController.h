//
//  PhotosByPlaceTableViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "PhotosByPlaceTableViewController.h" //


@interface PhotosByTagTableViewController : PhotosByPlaceTableViewController
@property (nonatomic,strong,setter=setMyTag:) Tag *tag;
@end
