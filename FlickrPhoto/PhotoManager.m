
//
//  PhotoManager.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoManager.h"

@interface PhotoManager() 

@end

@implementation PhotoManager





+(void) fetchFlickrPhoto:(NSDictionary *)photo IntoDocument:(UIManagedDocument *)document
{
    [document.managedObjectContext performBlock:^{
        [Photo photoWithFlickrInfo:photo inManagedObjectContext:document.managedObjectContext]; 
        
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success) {                  
                NSLog(@"Document saved"); 
            } else {                       
                NSLog(@"Document was unable to save");
            }}
         ];
        
    }];         
}


+(void)useDocument:(NSString *)docName withPhoto:(NSDictionary *)photo 
{    
    [VacationHelper openVacation:docName usingBlock:^(UIManagedDocument *vacation) {
        [self fetchFlickrPhoto:photo IntoDocument:vacation];
    }];

}





@end


