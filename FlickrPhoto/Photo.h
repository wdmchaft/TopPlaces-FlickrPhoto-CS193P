//
//  Photo.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photo_id;
@property (nonatomic, retain) NSString * photo_url;
@property (nonatomic, retain) NSString * place_id;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * inserted;
@property (nonatomic, retain) NSSet *etichettataDa;
@property (nonatomic, retain) Place *scattateDove;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addEtichettataDaObject:(Tag *)value;
- (void)removeEtichettataDaObject:(Tag *)value;
- (void)addEtichettataDa:(NSSet *)values;
- (void)removeEtichettataDa:(NSSet *)values;

@end
