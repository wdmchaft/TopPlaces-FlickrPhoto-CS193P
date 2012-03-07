//
//  PlacesTableViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 05/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecentPhotosTableViewController.h"

@interface PlacesTableViewController : RecentPhotosTableViewController // l'ho impostato (più tardi nello sviluppo) come una subclass perchè in questo modo eredita la delegation del mapviewcontroller (che ho dato a RecentPhotosTableViewController) perchè in alcuni casi la classe col delegato non veniva inizializzata oppure veniva deallocata prima che arrivassi con lo storyboard al MapViewController :)
@property (nonatomic,strong) NSArray *places; //of Flickr photo dictionaries
@end
