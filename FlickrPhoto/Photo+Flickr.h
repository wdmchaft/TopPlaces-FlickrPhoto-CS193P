//
//  Photo+Flickr.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Photo *)deletePhoto:(Photo *)myPhoto
fromManagedObjectContext:(NSManagedObjectContext *)context;

+ (Photo *)photoInDocumentWithFlickrId:(NSString *)flickrId inManagedObjectContext:(NSManagedObjectContext *)context;

@end
