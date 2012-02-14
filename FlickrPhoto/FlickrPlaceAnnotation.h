//
//  FlickrPlaceAnnotation.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPlaceAnnotation : NSObject <MKAnnotation>

//helper method :)
+ (FlickrPlaceAnnotation *)annotationForPhoto:(NSDictionary *)place; // Flickr place dictionary

@property (nonatomic, strong) NSDictionary *place; //model! annotation è un ponte tra model e la view (mapkit)

@end
