//
//  PhotosByTag.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "CoreDataTableViewController.h"

@interface PhotosByTag : CoreDataTableViewController
@property (nonatomic,strong,setter=setMyTag:) Tag *tag;
@end
