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



+(NSArray *)vacationsList
{
    NSURL *documentDirectoryPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                                           inDomains:NSUserDomainMask] lastObject]; //document dir
    
    NSError *error;
    // get the contents of the directory
    NSArray *keys = [[NSArray alloc] initWithObjects:NSURLNameKey, nil];
    
    //recupero tutti i documenti nella 'document directory'
    NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentDirectoryPath 
                                                  includingPropertiesForKeys:keys 
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                                       error:&error];
    
     NSMutableArray *vacationsUrls = [[NSMutableArray alloc] init];
    if (error == nil){
    //creo una lista
    
    for (NSURL *url in urls) {
        //NSString *name =[url absoluteString];
        // and see if there are files that contain vacations
       // if ([name rangeOfString:@"vacation"].location != NSNotFound) {
            // and add all these urls to an url array
            [vacationsUrls addObject:url];
        //}
    }
    }
    
    if ([vacationsUrls count] == 0) //se non ho nessun documento 'vacation'
    {
        //ne creo uno di default di nome "my default vacation"
        //ATTENZIONE!!! lo creo, ma non lo salvo: lo salvo quando lo aggancio al db? però in questo modo se esco dall'app prima, non ho la "my defaul vacation salvata" per cui me la ricrea ogni volta (tanto, cmq sia, finchè non l'aggancio al db è vuota!)
        //OSSERVAZIONE: nel tutorial si consiglia di salvare quando si modifica, quindi mi sono risposto :)
        [vacationsUrls addObject:[documentDirectoryPath URLByAppendingPathComponent:@"my default vacation"]]; //creo il path
        
    }
    


    return vacationsUrls;
}


// This is a dictionary where the keys are "Vacations" and the objects are URLs to UIManagedDocuments
static NSMutableDictionary *vacations;

// This typedef has been defined in .h file: 
// typedef void (^completion_block_t)(UIManagedDocument *vacation);
// The idea is that this class method will run the block when its UIManagedObject has opened


// share a UIManagedDocument instance for each file
+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock
{
    if (vacationName && ![vacationName isEqualToString:@""]) {
        UIManagedDocument *vacationDocument = [vacations objectForKey:vacationName];
        //NSLog(@"Opening vacation document: %@", vacationDocument);
        
        if (vacationDocument == nil) {
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            url = [url URLByAppendingPathComponent:vacationName];
            vacationDocument = [[UIManagedDocument alloc] initWithFileURL:url];
            if (vacations == nil) {
                vacations = [[NSMutableDictionary alloc] init];
            }
            [vacations setObject:vacationDocument forKey:vacationName];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[vacationDocument.fileURL path]]) {
            // Document does not exist on disk, so create it
            [vacationDocument saveToURL:vacationDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                completionBlock(vacationDocument);
            }];
        } else if (vacationDocument.documentState == UIDocumentStateClosed) {
            // Document exists on disk, but we need to open it
            [vacationDocument openWithCompletionHandler:^(BOOL success) {
                completionBlock(vacationDocument);
            }];
        } else if (vacationDocument.documentState == UIDocumentStateNormal) {
            // Document is already open and ready to use
            completionBlock(vacationDocument);
        } else {
            NSLog(@"Unknown document state");
        }
    } else {
        completionBlock(nil);
    }
}


@end
