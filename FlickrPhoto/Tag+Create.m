//
//  Tag+Create.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+(Tag *)TagWithName:(NSString *)tag_name
inManagedObjectContext:(NSManagedObjectContext *)context;
{
    Tag *tag =nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"tag_name = %@", tag_name];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tag_name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *tags = [context executeFetchRequest:request error:&error]; //error prende come argomento un pointer to a pointer! per questo scrivo &errorm
    
    if (!tags || ([tags count] > 1)) {
        // handle error
    } else if (![tags count]) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                              inManagedObjectContext:context];
        tag.tag_name=tag_name;
        tag.used = [NSNumber numberWithInt:1];
                
        //
    } else {
        //NSLog(@"il tag è già presente nel db");
        tag = [tags lastObject];
        tag.used = [NSNumber numberWithInt:[tag.used intValue] + 1];
    }
    
    return tag;
}

/**
+(Tag *)TagWithName:(NSString *)tag_name
fromManagedObjectContext:(NSManagedObjectContext *)context;
{
    Tag *tag =nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"tag_name = %@", tag_name];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tag_name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *tags = [context executeFetchRequest:request error:&error]; //error prende come argomento un pointer to a pointer! per questo scrivo &errorm
    
    if ([tags count] > 1) { 
        // handle error
             NSLog(@"errore nei tag");
    } else if ([tags count] == 0) {
               //delete tag
        //[context deleteObject:tag];
        NSLog(@"tag eliminato");
    } else {
        tag= [tags lastObject];
        NSLog(@"tag ridotto di 1");
        tag.used = [NSNumber numberWithInt:[tag.used intValue] - 1];
    }
    
    return tag;
}
 **/

@end
