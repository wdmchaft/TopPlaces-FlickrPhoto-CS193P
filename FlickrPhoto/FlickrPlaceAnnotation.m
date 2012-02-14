//
//  FlickrPlaceAnnotation.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//




#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation

@synthesize place = _place;

+ (FlickrPlaceAnnotation *)annotationForPhoto:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}  

#pragma mark - MKAnnotation

-(NSArray *)infoOnAPlace
{
    NSString *flickrPlaceName= [self.place objectForKey:FLICKR_PLACE_NAME];
    NSMutableArray *placeDetails= [[flickrPlaceName componentsSeparatedByString:@","] mutableCopy];
    
    
    return placeDetails;

}

- (NSString *)title
{
    NSString *town=@"";
    if ([[self infoOnAPlace] count] != 0){
        town = [[self infoOnAPlace]  objectAtIndex:0]; 

    } else town=@"sconosciuta";
    
    return town;
}
/**
- (NSString *)subtitle
{
 
    return [self.place valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}
**/
- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}



@end