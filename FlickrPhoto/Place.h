//
//  Place.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Itinerary, Photo;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSDate * inserted;
@property (nonatomic, retain) NSString * place_description;
@property (nonatomic, retain) NSString * place_id;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *inItineraries;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addInItinerariesObject:(Itinerary *)value;
- (void)removeInItinerariesObject:(Itinerary *)value;
- (void)addInItineraries:(NSSet *)values;
- (void)removeInItineraries:(NSSet *)values;

@end
