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
    
   
    NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentDirectoryPath 
                                                  includingPropertiesForKeys:keys 
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                                       error:&error];
    
    NSMutableArray *vacationsUrls = [[NSMutableArray alloc] init];
    if (error == nil){
  
        
        for (NSURL *url in urls) {
                       [vacationsUrls addObject:url];
        }
    }
    
    if ([vacationsUrls count] == 0) 
    {
        
        [vacationsUrls addObject:[documentDirectoryPath URLByAppendingPathComponent:@"my default vacation"]]; 
        
    }
    
    
    
    return vacationsUrls;
}



static NSMutableDictionary *vacations;


// share a UIManagedDocument instance for each file
+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock
{
    if (vacationName && ![vacationName isEqualToString:@""]) {
        UIManagedDocument *vacationDocument = [vacations objectForKey:vacationName];
        
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

            [vacationDocument saveToURL:vacationDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                completionBlock(vacationDocument);
            }];
        } else if (vacationDocument.documentState == UIDocumentStateClosed) {

            [vacationDocument openWithCompletionHandler:^(BOOL success) {
                completionBlock(vacationDocument);
            }];
        } else if (vacationDocument.documentState == UIDocumentStateNormal) {

            completionBlock(vacationDocument);
        } else {
            NSLog(@"Unknown document state");
        }
    } else {
        completionBlock(nil);
    }
}


@end
