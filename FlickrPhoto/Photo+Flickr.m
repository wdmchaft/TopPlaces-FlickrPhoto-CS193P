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


+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if (!matches || ([matches count] >1)){ 
        //handle error
        NSLog(@"error");
        
    }else if ([matches count] == 0){ 
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
            if (aTag && ![aTag isEqualToString:@""] && ![aTag isEqualToString:@" "]){ 
                
                if ([aTag rangeOfString:@"."].location == NSNotFound &&
                    [aTag rangeOfString:@","].location == NSNotFound && 
                    [aTag rangeOfString:@";"].location == NSNotFound  &&
                    [aTag rangeOfString:@":"].location == NSNotFound)
                {
                    
                    
                    [tagset addObject:[Tag TagWithName:aTag inManagedObjectContext:context]];
                } 
                else NSLog(@"invalid tag");
            } 
            else NSLog(@"empty tag ");
        }
        
        photo.etichettataDa=tagset;
        
        photo.scattateDove = [Place placeWithID:[flickrInfo objectForKey:@"place_id"] andDescription:[flickrInfo objectForKey:@"derived_place"] inManagedObjectContext:context];
    } else { 
        photo = [matches lastObject];
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
    } else if ([matches count] == 1) {
        photo = [matches lastObject];
    }
    
    return photo;
}





 

@end
