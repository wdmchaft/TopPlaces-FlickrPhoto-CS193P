//
//  PhotosByPlace.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Place+Create.h"

@interface PhotosByPlace : CoreDataTableViewController

//Added public Model (the photographer whose photos we want to show)
@property (nonatomic,strong) Place *place;

@end
