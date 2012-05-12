//
//  VacationHelper.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *vacation);

@interface VacationHelper : NSObject

+(NSArray *)vacationsList; //array of UIManagedDocument


+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock;

@end
