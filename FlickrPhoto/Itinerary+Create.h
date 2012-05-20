//
//  Itinerary+Create.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Itinerary.h"

@interface Itinerary (Create)
- (void)addPlaceToItinerary:(Place *)place; 
+(void)updatePlacesOrder:(NSMutableOrderedSet *)places
  inManagedObjectContext:(UIManagedDocument *)document;
+ (Itinerary *)itineraryWithName:(NSString *)itinerary_name
          inManagedObjectContext:(NSManagedObjectContext *)context;

@end
