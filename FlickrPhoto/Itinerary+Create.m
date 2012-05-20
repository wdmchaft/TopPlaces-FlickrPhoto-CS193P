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
    if (self.hasPlaces) {places = [self.hasPlaces mutableCopy];}
    //if (![places containsObject:place]){
      //  NSLog(@"il posto non è presente nell'itinerario");
    [places addObject:place]; // non faccio la verifica containsObject perchè inserisco il posto se e solo se il place non è mai stato salvato nel db
    //}
    self.hasPlaces = places;
    
}

+(void)updatePlacesOrder:(NSMutableOrderedSet *)places
inManagedObjectContext:(UIManagedDocument *)document
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Itinerary"]; //i have only 1 itinerary per vacation itinerary
    
    NSError *error = nil;
    NSArray *itineraries = [document.managedObjectContext executeFetchRequest:request error:&error]; 
    
    Itinerary *myItinerary = [itineraries lastObject];
    
  
    myItinerary.hasPlaces = places;
   /** 
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (success) NSLog(@"Overwrite completed");
    }];
    **/
    NSError *savingError = nil;
    
    if ([document.managedObjectContext save:&savingError]){
        NSLog(@"Successfully saved the context for reorder"); 
    } else {
        NSLog(@"Failed to save the context. Error = %@", savingError); }
}
@end
