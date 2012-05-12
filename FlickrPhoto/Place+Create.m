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


// place_description è l'identificatore che mi permette di valutare se un posto esiste già o meno
// es.  "place_description" = "London, England, United Kingdom";
//place_id è univoco o quasi per ogni foto (non so perchè, dipende da flickr credo)

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
        
        //ho solo un itinerario per vacation e lo chiamo myItinerary (per chiamarlo come la vacanza avrei dovuto passare al metodo il UIManagedDocument anzichè NSManagedObjectContext)
        
        //creo un eventuale itinerario se il posto non è presente, se è presente assumo che un itinerario sia stato precedentemente creato!
        place.inItinerary = [Itinerary itineraryWithName:@"myItinerary" inManagedObjectContext:context];
        
        //aggiungo il posto all'itinerario
        [place.inItinerary addPlaceToItinerary:place];
        
        //NSLog(@"place non esiste");
        //NSLog(@":::::::%@",place.inItinerary);
        
        
        //
    } else {
        place = [places lastObject];
        //NSLog(@"place esiste già");
    }
    
    return place;
}
@end

