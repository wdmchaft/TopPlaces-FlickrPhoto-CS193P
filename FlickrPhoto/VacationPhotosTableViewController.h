//
//  VacationPhotosTableViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Tag+Create.h"
#import "Place+Create.h"

@interface VacationPhotosTableViewController : CoreDataTableViewController
@property (nonatomic,strong) Place *place;
@property (nonatomic,strong) Tag *mytag;
@property (nonatomic,strong) NSString *vacationName;
@end
