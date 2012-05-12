//
//  Itinerary.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Itinerary : NSManagedObject

@property (nonatomic, retain) NSString * itinerary_name;
@property (nonatomic, retain) NSOrderedSet *hasPlaces;
@end

@interface Itinerary (CoreDataGeneratedAccessors)

- (void)insertObject:(Place *)value inHasPlacesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasPlacesAtIndex:(NSUInteger)idx;
- (void)insertHasPlaces:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasPlacesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasPlacesAtIndex:(NSUInteger)idx withObject:(Place *)value;
- (void)replaceHasPlacesAtIndexes:(NSIndexSet *)indexes withHasPlaces:(NSArray *)values;
- (void)addHasPlacesObject:(Place *)value;
- (void)removeHasPlacesObject:(Place *)value;
- (void)addHasPlaces:(NSOrderedSet *)values;
- (void)removeHasPlaces:(NSOrderedSet *)values;
@end
