//
//  Place+Create.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@interface Place (Create)
+ (Place *)placeWithID:(NSString *)place_id
        andDescription:(NSString *)place_description
inManagedObjectContext:(NSManagedObjectContext *)context;
@end
