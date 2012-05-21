//
//  MapViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 13/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;
@protocol MapViewControllerDelegate <NSObject>

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>) annotation;
- (void)mapViewController:(MapViewController *)sender showDetailForAnnotation:(id <MKAnnotation>)annotation;

@end

@interface MapViewController : UIViewController
@property (nonatomic,strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic,weak) id <MapViewControllerDelegate> delegate;


@end
