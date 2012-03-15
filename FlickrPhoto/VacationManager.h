//
//  VacationManager.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 09/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VacationManager : NSObject
//@property (nonatomic,strong,readonly) NSArray *vacations; //of UIManagedDocument

+(NSArray *)vacationsList; //array of UIManagedDocument
+ (UIManagedDocument *)sharedManagedDocumentForVacation:(NSString *)vacationName;
@end
