//
//  PhotoCaching.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 04/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoCaching : NSObject
- (BOOL)contains:(NSDictionary *)photo;
- (NSData *)retrieve:(NSDictionary *)photo;
- (void)put:(NSData *)photoData for:(NSDictionary *)photo;
@end
