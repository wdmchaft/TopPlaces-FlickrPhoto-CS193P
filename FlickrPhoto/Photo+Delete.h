//
//  Photo+Delete.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (Delete)

+ (Photo *)deletePhoto:(Photo *)myPhoto
fromManagedObjectContext:(NSManagedObjectContext *)context;
-(void)prepareForDeletion; //called before deletion
@end
