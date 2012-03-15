//
//  Photo+Delete.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Delete.h"
#import "Tag.h"

@implementation Photo (Delete)
-(void)prepareForDeletion
{
    NSLog(@"DELETE!!!");
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
@end
