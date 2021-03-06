//
//  Place+Create.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Create.h"
#import "FlickrFetcher.h"
#import "Itinerary+Create.h"

@implementation Place (Create)



+ (Place *)placeWithID:(NSString *)place_id
        andDescription:(NSString *)place_description
inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    Place *place=nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"place_description = %@", place_description];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"place_description" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error]; //error prende come argomento un pointer to a pointer! per questo scrivo &errorm
    
    if (!places || ([places count] > 1)) {
        
        // handle error
        
    } else if (![places count]) { 
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                              inManagedObjectContext:context];
        place.place_id = place_id;
        place.place_description = place_description;
        place.inserted = [NSDate date];
        
        place.inItinerary = [Itinerary itineraryWithName:@"myItinerary" inManagedObjectContext:context];

        [place.inItinerary addPlaceToItinerary:place];

    } else {
        place = [places lastObject];
    }
    
    return place;
}
@end

