//
//  VacationHelper.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationHelper.h"

@interface VacationHelper()


@end

@implementation VacationHelper
//@synthesize vacations = _vacations;

/**
-(NSArray *)vacations
{
   return [self vacationsList]; // vacations è readonly e mi restituisce solo la lista di UIManagedDocument
}
 **/

+(NSArray *)vacationsList
{
    NSURL *documentDirectoryPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                                           inDomains:NSUserDomainMask] lastObject]; //document dir
    
    // get the contents of the directory
    NSArray *keys = [[NSArray alloc] initWithObjects:NSURLNameKey, nil];
    
    //recupero tutti i documenti nella 'document directory'
    NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentDirectoryPath 
                                                  includingPropertiesForKeys:keys 
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                                       error:nil];
    //creo una lista
    NSMutableArray *vacationsUrls = [[NSMutableArray alloc] init];
    
    for (NSURL *url in urls) {
        NSString *name =[url absoluteString];
        // and see if there are files that contain vacations
        if ([name rangeOfString:@"vacation"].location != NSNotFound) {
            // and add all these urls to an url array
            [vacationsUrls addObject:url];
        }
    }
    if ([vacationsUrls count] == 0) //se non ho nessun documento 'vacation'
    {
        //ne creo uno di default di nome "my default vacation"
        //osservazione: lo creo, ma non lo salvo: lo salvo quando lo aggancio al db? però in questo modo se esco dall'app prima non ho la "my defaul vacation salvata" per cui me la ricrea ogni volta (tanto, cmq sia, finchè non l'aggancio al db è vuota!)
        //risposta: nel tutorial si consiglia di salvare quando si modifica, quindi mi sono risposto :)
        [vacationsUrls addObject:[documentDirectoryPath URLByAppendingPathComponent:@"my default vacation"]]; //creo il path
        NSLog(@"my vacation default creato! %@", [vacationsUrls description]);
    }
    


    return vacationsUrls;
}

+ (UIManagedDocument *)sharedManagedDocumentForVacation:(NSString *)vacationName //dbName
{
    
    static UIManagedDocument *managedDocument = nil;
    static dispatch_once_t mngddoc;
    
    dispatch_once(&mngddoc, ^{ //dispatch_once() is absolutely synchronous
               
        //recupero la Document directory
    
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        //ci aggiungo il nome del DB
        url = [url URLByAppendingPathComponent:vacationName];
       
        
        
        //se il percorso non esiste (e quindi quel db non è stato creato)
        if (![[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:url create:NO error:nil])
        {
            //mi creo un percorso di defaul
          url = [url URLByAppendingPathComponent:@"my default vacation"]; 
         NSLog(@"my vacation default creato! %@", url);
        }
        
        //creo il managedDocument
        managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];    
    });
    
    //http://stackoverflow.com/questions/9430056/how-do-i-share-one-uimanageddocument-between-different-objects
    return managedDocument;
}

/**
+ (void)useDocument:(NSString *)docName usingBlock:(completion_block_t)completionBlock

{
    
    UIManagedDocument *managedDocument = [VacationManager sharedManagedDocumentForVacation:docName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[managedDocument.fileURL path]]) // se il db non esiste nel disco
    {
        
        //il db non esiste per cui non ha senso che esegua qualcosa per cancellare... eventualmente posso segnalare che non esiste    
        
    } else if (managedDocument.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
            
            // METODO PER DELETE
          
            NSLog(@"db chiuso");
            completionBlock(managedDocument);
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
        // METODO PER DELETE
    
        NSLog(@"db aperto");
        completionBlock(managedDocument);
    }
    
    
    
}
**/

@end
