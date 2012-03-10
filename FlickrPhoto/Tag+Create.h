//
//  Tag+Create.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)
+(Tag *)TagWithName:(NSString *)tag_name
inManagedObjectContext:(NSManagedObjectContext *)context;
@end
