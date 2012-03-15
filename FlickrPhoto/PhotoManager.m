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
    dispatch_queue_t fetchQ  = dispatch_queue_create("Flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        
        [document.managedObjectContext performBlock:^{ //in questo modo sono nel thread giusto (dove è stato creato NSManagedObject) e non nel "flickr fetcher" thread (34')
            
            //se sapessi che viene fatto nel main thread potrei fare il "ritorno" al main thread come quando lavoro sulla ui
            
            // perform in the NSMOC's safe thread (main thread)
            
            
            // start creating obj in doc's context
            
            // CREO UN OGGETTO FOTO NEL DB
            [Photo photoWithFlickrInfo:self.photo inManagedObjectContext:document.managedObjectContext]; 
            
            // should probably saveToURL:forSaveOperation:(UIDocumentSaveForOverwriting)completionHandler: here!
            // we could decide to rely on UIManagedDocument's autosaving, but explicit saving would be better
            // because if we quit the app before autosave happens, then it'll come up blank next time we run
            // this is what it would look like (ADDED AFTER LECTURE) ...
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            // note that we don't do anything in the completion handler this time
                 
        }]; 
        
    });
    dispatch_release(fetchQ);
}

-(void)useDocument:(NSString *)docName withPhoto:(NSDictionary *)photo
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
    dispatch_queue_t fetchQ  = dispatch_queue_create("delete", NULL);
    dispatch_async(fetchQ, ^{
        
        [document.managedObjectContext performBlock:^{             
            
           
            //[Photo photoWithFlickrInfo:self.photo inManagedObjectContext:document.managedObjectContext]; 
            
            //[Photo photoWithWebUrl:self.photo_url fromManagedObjectContext:document.managedObjectContext];
            [Photo deletePhoto:photo fromManagedObjectContext:document.managedObjectContext];
          
           [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            
        }]; 
        
    });
    dispatch_release(fetchQ);
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


