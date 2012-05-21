//
//  MapViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 13/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "RecentPhotosTableViewController.h"
#import "PlacesTableViewController.h"
#import "PhotoViewController.h"
#import "FlickrPlaceAnnotation.h"
#import "FlickrPhotoAnnotation.h"


@interface MapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) id<MKAnnotation> latestAnnotation;

@end


@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize latestAnnotation = _latestAnnotation;

- (IBAction)segmentedControlPressed:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: // set map to normal
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1: // set map to satellite
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2: // set map to hybrid
            self.mapView.mapType = MKMapTypeHybrid;
            break;
    }
    
}

#pragma mark - Synchronize Model and View

- (void)updateMapView
{ 
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) 
    {[self.mapView addAnnotations:self.annotations];
        self.mapView.region = [self regionForAnnotations:self.annotations];
    }
    
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{  
    _annotations = annotations;
    [self updateMapView];
}

#define REGIONMARGIN 1.1
- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations
{
    CLLocationCoordinate2D mapCenter;
    MKCoordinateRegion mapRegion;
    MKCoordinateSpan mapSpan;
    
    if ([annotations count] > 0)
    {
        id <MKAnnotation> annotation = [annotations objectAtIndex:0];
        double minLongitude = annotation.coordinate.longitude;
        double maxLongitude = minLongitude;
        double minLatitude = annotation.coordinate.latitude;
        double maxLatitude = minLatitude;
        
        // loop over all annotations to find the min and max coordinates
        for (id <MKAnnotation> annotation in annotations) {
            if (annotation.coordinate.longitude > maxLongitude) {
                maxLongitude = annotation.coordinate.longitude;
            }
            if (annotation.coordinate.longitude < minLongitude) {
                minLongitude = annotation.coordinate.longitude;
            }
            if (annotation.coordinate.latitude > maxLatitude) {
                maxLatitude = annotation.coordinate.latitude;
            }
            if (annotation.coordinate.latitude < minLatitude) {
                minLatitude = annotation.coordinate.latitude;
            }
        }
        
        mapCenter.longitude = (maxLongitude - minLongitude)/2 + minLongitude;
        mapCenter.latitude = (maxLatitude - minLatitude)/2 + minLatitude;
        mapSpan.longitudeDelta = (maxLongitude - minLongitude) * REGIONMARGIN;
        mapSpan.latitudeDelta = (maxLatitude - minLatitude) * REGIONMARGIN;
        
        if (mapSpan.longitudeDelta > 360.0) {
            mapSpan.longitudeDelta = 360.0;
        }
        if (mapSpan.latitudeDelta > 180.0) {
            mapSpan.latitudeDelta = 180.0;
        }
        
        mapRegion.center = mapCenter;
        mapRegion.span = mapSpan;
    }
    else
    {
        mapCenter.longitude = 0.0;
        mapCenter.latitude = 0.0;
        mapRegion.center = mapCenter;
        mapSpan.longitudeDelta = 360.0;
        mapSpan.latitudeDelta = 180.0;
        mapRegion.span = mapSpan;
    }
    return mapRegion;
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) { 
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        
        // get the index of the visible VC on the stack
        int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
        // get a reference to the previous VC    
        id previousVC = [self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];
        
        if (![previousVC isKindOfClass:[PlacesTableViewController class]])         {
            aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)]; //inizializzo leftCalloutAccessoryView come una UIImageView
            
        }
        
        aView.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
    }
    
    aView.annotation = annotation;
      [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];    
    return aView;
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self.delegate mapViewController:self showDetailForAnnotation:view.annotation];
    
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)pinView
{
    self.latestAnnotation = pinView.annotation;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    [spinner startAnimating];
    
    if (pinView.leftCalloutAccessoryView) 
    {
        [(UIImageView *)pinView.leftCalloutAccessoryView addSubview:spinner];
        
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue,^{
            //block nel thread separato
            
            id<MKAnnotation> fetchedAnnotation = pinView.annotation;
            
            UIImage *image = [self.delegate mapViewController:self imageForAnnotation:pinView.annotation];
            dispatch_async(dispatch_get_main_queue(), ^{
                //main thread
                // If the latest annotation and the fetched annotation do not match
                // discard the fetched annotation image
                if (self.latestAnnotation == fetchedAnnotation) {
                    if (image != nil) {
                        [spinner stopAnimating]; 
                        [(UIImageView *)pinView.leftCalloutAccessoryView setImage:image];
                    }
                } else {
                    pinView.leftCalloutAccessoryView = nil;
                }
            });
            
        });
        dispatch_release(downloadQueue); //altrimenti c'è un memory leak
    } 
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self; 
}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
