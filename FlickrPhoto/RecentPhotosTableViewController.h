//
//  RecentPhotosTableViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LAST_VIEWED_PHOTOS_KEY @"LAST_PHOTOS"

@interface RecentPhotosTableViewController : UITableViewController

@property (nonatomic,strong) NSDictionary *placeName;
@property (nonatomic,strong) NSArray* recentPhotos;
@property (nonatomic, strong) NSDictionary *flickrSelected; // dizionario di posti o foto

@end
