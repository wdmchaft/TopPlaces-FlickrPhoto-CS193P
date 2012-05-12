//
//  Itinerary+Create.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Itinerary+Create.h"

@implementation Itinerary (Create)
+ (Itinerary *)itineraryWithName:(NSString *)itinerary_name
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    Itinerary *itinerary = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Itinerary"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"itinerary_name" ascending:YES];
    
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *itineraries = [context executeFetchRequest:request error:&error]; 
    
    if (!itineraries || ([itineraries count] > 1)) {
        
        // handle error
        
    } else if (![itineraries count]) {
        
        
        itinerary = [NSEntityDescription insertNewObjectForEntityForName:@"Itinerary"
                                                  inManagedObjectContext:context];
        
        itinerary.itinerary_name = itinerary_name;
        
        NSLog(@":::::itinerary non esiste:::::");
        
        //
    } else {
        itinerary = [itineraries lastObject];
        NSLog(@":::::itinerary esiste già:::::");
    }
    
    
    return itinerary;
}

- (void)addPlaceToItinerary:(Place *)place {
    NSMutableOrderedSet *places = [[NSMutableOrderedSet alloc] init];
    if (self.hasPlaces) places = [self.hasPlaces mutableCopy];
    [places addObject:place];
    self.hasPlaces = places;
    
}
@end
