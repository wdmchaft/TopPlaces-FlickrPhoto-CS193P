
//
//  PhotoManager.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoManager.h"

@interface PhotoManager() 
@property (nonatomic,strong) NSDictionary *photo;
@end

@implementation PhotoManager
@synthesize photo = _photo;




-(void) fetchFlickrPhoto:(NSDictionary *)photo IntoDocument:(UIManagedDocument *)document
{
    [document.managedObjectContext performBlock:^{
        [Photo photoWithFlickrInfo:photo inManagedObjectContext:document.managedObjectContext]; 
        
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success) {                  
                NSLog(@"Document saved"); 
            } else {                       
                NSLog(@"***** Document was unable to save *****");
            }}
         ];
        
    }];         
}


-(void)useDocument:(NSString *)docName withPhoto:(NSDictionary *)photo //le foto che visualizzo dalle vacations non sono più dictionaries
{
    //self.photo = photo;
    
    [VacationHelper openVacation:docName usingBlock:^(UIManagedDocument *vacation) {
        [self fetchFlickrPhoto:photo IntoDocument:vacation];
    }];

}





@end


