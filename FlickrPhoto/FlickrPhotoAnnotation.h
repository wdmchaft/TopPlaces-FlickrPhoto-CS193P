//
//  FlickrPhotoAnnotation.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

//helper method :)
+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo; // Flickr photo dictionary

@property (nonatomic, strong) NSDictionary *photo; //model! annotation è un ponte tra model e la view (mapkit)
@property (nonatomic,strong) NSString *codice_id;
@end

