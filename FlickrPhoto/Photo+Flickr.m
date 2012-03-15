//
//  Photo+Flickr.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Place+Create.h"
#import "Tag+Create.h"
#import "FlickrFetcher.h"

@implementation Photo (Flickr)


//crea un elemento Foto nel DB: prima di crearlo bisogne verificare se esiste o meno :)
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    //query
    // voglio essere sicuro che unique attribe della foto nel db è uguale all'id della foto su flickr
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if (!matches || ([matches count] >1)){ 
        // deve essere unique!
        //gestire eventuali errori
        NSLog(@"errore");
        
    }else if ([matches count] == 0){ // se non esiste, lo inserisco
        NSLog(@"creo la riga di valori");
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.photo_id= [flickrInfo objectForKey:FLICKR_PHOTO_ID];
        photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];  
        photo.place_id = [flickrInfo objectForKey:@"place_id"];
        photo.photo_url = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.tags = [flickrInfo objectForKey:FLICKR_TAGS];
        photo.inserted = [NSDate date];
        
        NSMutableArray *photoTags= [[[flickrInfo objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "] mutableCopy];
        
        NSMutableSet *tagset =[[NSMutableSet alloc] init];
        
        for (NSString *aTag in photoTags) {
            if (aTag && ![aTag isEqualToString:@""] && ![aTag isEqualToString:@" "]){ //se esiste OR è diversa dallo spazio vuoto

               if ([aTag rangeOfString:@"."].location == NSNotFound &&
                   [aTag rangeOfString:@","].location == NSNotFound && 
                   [aTag rangeOfString:@";"].location == NSNotFound  &&
                   [aTag rangeOfString:@":"].location == NSNotFound)
               {
                
                
                [tagset addObject:[Tag TagWithName:aTag inManagedObjectContext:context]];
               } 
               else NSLog(@" c'è un segno di punteggiatura nel tag: non lo salvo");
               // NSLog(@" tag:%@",aTag);
            } 
            else NSLog(@" tag vuoto ");
        }
        
        photo.etichettataDa=tagset;
        
        photo.scattateDove = [Place placeWithID:[flickrInfo objectForKey:@"place_id"] andDescription:[flickrInfo objectForKey:@"derived_place"] inManagedObjectContext:context];
    } else { //se esiste ed è unique
        photo = [matches lastObject];
         NSLog(@"esiste già");
    }
    
    return photo;
}


+ (Photo *)photoInDocumentWithFlickrId:(NSString *)flickrId inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", flickrId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Multiple photos with same name");
    } else if ([matches count] == 1) {
        photo = [matches lastObject];
    }
    
    return photo;
}


+ (Photo *)deletePhoto:(Photo *)myPhoto
        fromManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    //query
    // voglio essere sicuro che unique attribe della foto nel db è uguale all'id della foto su flickr
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", myPhoto.photo_id];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if (!matches || ([matches count] >1)){ 
        // deve essere unique!
        //gestire eventuali errori
        NSLog(@"errore");
        
    }else if ([matches count] == 0){ // se non esiste, lo inserisco
       
        NSLog(@"la foto non c'è");
        
    } else { //se esiste ed è unique
        photo = [matches lastObject];
        NSLog(@"ho trovato la foto da cancellare");
        //LA CANCELLO QUI
        [context deleteObject:photo];

    }
    
    return photo;
}

/**
-(void)prepareForDeletion
{

    
    
    for (Tag *tag in self.etichettataDa) {
       // if ([tag.used count] == 1) {
         //   [self.managedObjectContext deleteObject:tag];
        //} else {
        NSLog(@" used pre modifica %d",[tag.used intValue]);
            tag.used = [NSNumber numberWithInt:[tag.used intValue]-1];
        NSLog(@" used post modifica %d",[tag.used intValue]);
        //}
    }
   
}
 **/
 

@end
