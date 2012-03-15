
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
//@property (nonatomic,strong) NSString *photo_url;
@end

@implementation PhotoManager
@synthesize photo = _photo;
//@synthesize photo_url = _photo_url;




-(void) fetchFlickrDataIntoDocument:(UIManagedDocument *)document
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
    UIManagedDocument *managedDocument = [VacationManager sharedManagedDocumentForVacation:docName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[managedDocument.fileURL path]]) // se il db non esiste nel disco
    {
        [managedDocument saveToURL:managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            // [self setupFetchedResultsController];  
            [self fetchFlickrDataIntoDocument:managedDocument]; //inserisco nel db
            NSLog(@"db creato");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];  
            [self fetchFlickrDataIntoDocument:managedDocument]; //inserisco nel db
            NSLog(@"db chiuso");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
        //[self setupFetchedResultsController];  
        [self fetchFlickrDataIntoDocument:managedDocument]; //inserisco nel db
        NSLog(@"db aperto");
    }
}


-(void) deletePhoto:(Photo *) photo fromDocument:(UIManagedDocument *)document
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


-(void)useDocument:(NSString *)docName toDeletePhoto:(Photo *) photo

{
    
  UIManagedDocument *managedDocument = [VacationManager sharedManagedDocumentForVacation:docName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[managedDocument.fileURL path]]) // se il db non esiste nel disco
    {

    //il db non esiste per cui non ha senzo che esegua qualcosa per cancellare... eventualmente posso segnalare che non esiste    
        
    } else if (managedDocument.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
           
            // METODO PER DELETE
            [self deletePhoto:photo fromDocument:managedDocument];
            NSLog(@"db chiuso");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
        // METODO PER DELETE
      [self deletePhoto:photo fromDocument:managedDocument];
        NSLog(@"db aperto");
    }

    
    
}

@end


