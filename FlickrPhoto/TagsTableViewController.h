//
//  TagsTableViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface TagsTableViewController : CoreDataTableViewController <UISearchBarDelegate> //PlacesByVacation
@property (nonatomic,strong) NSString *vacation;

@end
