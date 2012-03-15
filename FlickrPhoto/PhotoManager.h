//
//  PhotoManager.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo+Flickr.h"
#import "Photo+Delete.m"
#import "VacationManager.h"

@interface PhotoManager : NSObject
-(void)useDocument:(NSString *)docName withPhoto:(NSDictionary *)photo;

+(void)useDocument:(NSString *)docName toDeletePhoto:(Photo *) photo;
@end
