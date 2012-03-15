//
//  Photo+Delete.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Delete.h"
#import "Tag.h"
#import "Place+Create.h"

@implementation Photo (Delete)
-(void)prepareForDeletion
{
       
    Place *place = self.scattateDove;
    if ([place.photos count] == 1) {
        NSLog(@"this places has no more photos associated with");
        [self.managedObjectContext deleteObject:place];
    }

    NSSet *tags = self.etichettataDa;
    for (Tag *tag in tags) {
        tag.used = [NSNumber numberWithInt:[tag.used intValue] - 1];
       
        if ([tag.taggedPhotos count] == 1) {
            [self.managedObjectContext deleteObject:tag];
        }
        
    }

    

}
@end
