//
//  PhotoCaching.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 04/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoCaching.h"
#import "FlickrFetcher.h"

#define FILETYPE @".jpg"
#define FILEPREFIX @"Fl1ckr_"
#define MAXIMUM_CACHE_SIZE 10485760  // in Bytes (10Mb): 10 MB = 10*1024 KB = 10*1024*1024 Bytes = 10485760 Bytes

@interface PhotoCaching()
@property (nonatomic,strong) NSString *cachePath; 
@end


@implementation PhotoCaching
@synthesize  cachePath =_cachePath;


- (NSString *)cachePath
{
    if (!_cachePath){
    
     NSArray *cachePaths = [[NSArray alloc] initWithArray:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)];    
      _cachePath =[NSString stringWithFormat:@"%@",[cachePaths objectAtIndex:0]];   
    }
    return _cachePath;
}

- (NSString *)pathForPhoto:(NSDictionary *)photo 
{

    NSString *photoIdentifier = [[photo valueForKey:FLICKR_PHOTO_ID] stringByAppendingString:FILETYPE];  //es. 12345.jpg
    photoIdentifier = [FILEPREFIX stringByAppendingString:photoIdentifier];  //es. Fl1ckr_12345.jpg

    return [self.cachePath stringByAppendingPathComponent:photoIdentifier];
}

- (BOOL)contains:(NSDictionary *)photo;
{
    BOOL photoExists = NO;
    NSArray *cachePaths = [[NSArray alloc] initWithArray:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)];
    

    if ([cachePaths count] >= 1) {
        photoExists = [[NSFileManager defaultManager] isReadableFileAtPath:[self pathForPhoto:photo]];
    } else
    {
   //handle this...
    }
    return photoExists;
}

- (NSData *)retrieve:(NSDictionary *)photo
{
    NSData *photoData = [[NSData alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:[self pathForPhoto:photo]]];
    return photoData;
}

- (NSDictionary *)fileAttributesForCacheFile:(NSString *)fileName
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cachePath stringByAppendingPathComponent:fileName] error:nil];
}

- (int)directorySizeForPath:(NSString *)directoryPath
{
    int directorySize = 0;                                                              
    NSString *fileName;
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.cachePath error:nil]; // get the files in the directory
    
    NSEnumerator *filesEnumator = [filesArray objectEnumerator];

    while (fileName = [filesEnumator nextObject]) {
        if ([fileName hasPrefix:FILEPREFIX])   
        { 
        directorySize += [[self fileAttributesForCacheFile:fileName] fileSize];
        }
    }
    
    return directorySize;
}

- (void)pruneCacheForPhoto:(NSData *)photoData
{
    int dataSize = [photoData length];                                                 
    
    int currentDirectorySize = [self directorySizeForPath:self.cachePath];             

    if ((currentDirectorySize + dataSize) > MAXIMUM_CACHE_SIZE)                         
    {
        NSString *fileName;
        
        NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.cachePath error:nil]; 
        NSMutableArray *filesWithProperties = [[NSMutableArray alloc] initWithCapacity:[filesArray count]]; 
        
        NSEnumerator *filesEnumator = [filesArray objectEnumerator];

        while (fileName = [filesEnumator nextObject]) {
            
            if ([fileName hasSuffix:FILETYPE])                                             
            {
                [filesWithProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:fileName, @"filePath",[[self fileAttributesForCacheFile:fileName] fileModificationDate], @"lastModDate", nil]];
            }
        }

        NSArray *invertedSortedFiles = [[NSArray alloc] initWithArray:[filesWithProperties sortedArrayUsingComparator:^(id path1, id path2)
                                                                       {                               
                                                                           return [[path1 objectForKey:@"lastModDate"] compare:[path2 objectForKey:@"lastModDate"]];                          
                                                                       }]];
        NSDictionary *fileObject;
        for (fileObject in invertedSortedFiles)                                   
        {
            
            if ((currentDirectorySize + dataSize) > MAXIMUM_CACHE_SIZE)                      
            {
                                
                [[NSFileManager defaultManager] removeItemAtPath:[self.cachePath stringByAppendingPathComponent:[fileObject valueForKey:@"filePath"]] error:nil];
                currentDirectorySize = [self directorySizeForPath:self.cachePath];
            }
        }
      
    }
}

- (void)put:(NSData *)photoData for:(NSDictionary *)photo
{ 
if (![self contains:photo])                                                 
{
    [self pruneCacheForPhoto:photoData];                                           
    
    [photoData writeToFile:[self pathForPhoto:photo] atomically:YES];              
}
}

@end
