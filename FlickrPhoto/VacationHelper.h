//
//  VacationHelper.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef void (^completion_block_t)(UIManagedDocument *vacation);

@interface VacationHelper : NSObject
//@property (nonatomic,strong,readonly) NSArray *vacations; //of UIManagedDocument

+(NSArray *)vacationsList; //array of UIManagedDocument
+ (UIManagedDocument *)sharedManagedDocumentForVacation:(NSString *)vacationName;

//+ (void)useDocument:(NSString *)docName usingBlock:(completion_block_t)completionBlock;
@end
