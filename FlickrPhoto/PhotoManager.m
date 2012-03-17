
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




-(void) fetchFlickrPhotoIntoDocument:(UIManagedDocument *)document
{
        [document.managedObjectContext performBlock:^{
            [Photo photoWithFlickrInfo:self.photo inManagedObjectContext:document.managedObjectContext]; 
            
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                if (success) {                  
                    NSLog(@"Document saved"); 
                } else {                       
                    NSLog(@"Document was unable to save");
                }}
             ];
                 
        }];         
}


-(void)useDocument:(NSString *)docName withPhoto:(NSDictionary *)photo //le foto che visualizzo dalle vacations non sono più dictionaries
{
    self.photo = photo;
    UIManagedDocument *managedDocument = [VacationHelper sharedManagedDocumentForVacation:docName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[managedDocument.fileURL path]]) // se il db non esiste nel disco
    {
        [managedDocument saveToURL:managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            // [self setupFetchedResultsController];  
            [self fetchFlickrPhotoIntoDocument:managedDocument]; //inserisco nel db
            NSLog(@"il db non esisteva ed è stato creato");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];  
            [self fetchFlickrPhotoIntoDocument:managedDocument]; //inserisco nel db
            NSLog(@"il db era chiuso ma è stato aperto");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
        //[self setupFetchedResultsController];  
        [self fetchFlickrPhotoIntoDocument:managedDocument]; //inserisco nel db
        NSLog(@"il db era già aperto");
    }
}

/**

+(void) deletePhoto:(Photo *) photo fromDocument:(UIManagedDocument *)document
{
    if ([Photo photoInDocumentWithFlickrId:photo.photo_id inManagedObjectContext:document.managedObjectContext]) 
    {
    
        [document.managedObjectContext performBlock:^{             
            
           [Photo deletePhoto:photo fromManagedObjectContext:document.managedObjectContext];
          
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                if (success) {                  
                    NSLog(@"Document saved"); 
                } else {                       
                    NSLog(@"Document was unable to save");
                }}
             ];
            
        }]; 
    }
    else {NSLog(@"la foto non è presente nel db");
        
    }
        
}



+(void)useDocumentName:(NSString *)docName toDeletePhoto:(Photo *) photo

{

  UIManagedDocument *managedDocument = [VacationManager sharedManagedDocumentForVacation:docName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[managedDocument.fileURL path]]) // se il db non esiste nel disco
    {

    //il db non esiste per cui non ha senso che esegua il metodo per il delete: eventualmente posso segnalare che non esiste 
        NSLog(@"il db non esiste!!");
        
    } else if (managedDocument.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
           
            [self deletePhoto:photo fromDocument:managedDocument];
             NSLog(@"il db era chiuso ma è stato aperto");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
      [self deletePhoto:photo fromDocument:managedDocument];
         NSLog(@"il db era già aperto");
    }
    
}
**/


@end


