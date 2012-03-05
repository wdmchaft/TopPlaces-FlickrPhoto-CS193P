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
#import "PhotoVC.h"
#import "FlickrPlaceAnnotation.h"
#import "FlickrPhotoAnnotation.h"


@interface MapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end


@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;

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
    
    // are there annotations for which one can calculate a region
    if ([annotations count] > 0)
    {
        id <MKAnnotation> annotation = [annotations objectAtIndex:0];
        //        NSLog(@"%@",annotation.title);
        //       NSLog(@"%@",annotation.subtitle);
        //        NSLog(@"%f",annotation.coordinate.longitude);
        //        NSLog(@"%f",annotation.coordinate.latitude);
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
        
        // I should set the map region based on the annotations
        mapCenter.longitude = (maxLongitude - minLongitude)/2 + minLongitude;
        mapCenter.latitude = (maxLatitude - minLatitude)/2 + minLatitude;
        mapSpan.longitudeDelta = (maxLongitude - minLongitude) * REGIONMARGIN;
        mapSpan.latitudeDelta = (maxLatitude - minLatitude) * REGIONMARGIN;
        
        // check if the REGIONMARGIN did not create unrealistic values
        if (mapSpan.longitudeDelta > 360.0) {
            mapSpan.longitudeDelta = 360.0;
        }
        if (mapSpan.latitudeDelta > 180.0) {
            mapSpan.latitudeDelta = 180.0;
        }
        //  does not quite work for the entire world.
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


//Returns the view associated with the specified annotation object.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) { // se non c'è niente da riusare....
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        
        //NOTA: faccio comparire nella MKAnnotationView la leftCalloutAccessoryView solo se la mappa appare da RecentPhotosTVC o LastViewedPhotosTVC
        // get the index of the visible VC on the stack
        int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
        // get a reference to the previous VC    
        id previousVC = [self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];
        
        if (![previousVC isKindOfClass:[PlacesTableViewController class]]) //se la previous vc non è placestvc (e quindi è o recentphotostvc o lastviewedphotostvc), inizializzo la leftcalloutaccessoryview
        {
            aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)]; //inizializzo leftCalloutAccessoryView come una UIImageView

        }


        
  
        // could put a rightCalloutAccessoryView here
        aView.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    }
    
    aView.annotation = annotation;
    //if ([aView.leftCalloutAccessoryView  isKindOfClass:[UIImageView class]]) {NSLog(@"è una image view!");}
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];//1.05' prima di fare il cast potrei fare introspection, senza il cast non potrei usare setImage; lo metto a nil perchè siccome lo riuso non voglio che venga riusato con un immagine random!
    
    //If (Class *)myClass occurs in other code, it's a cast. Basically it says to reinterpret myClass as a pointer to an object of type Class, regardless of what its type really is.
    
    return aView;
}


//viene eseguito quando clicco uibutton nella rightCalloutAccessoryView
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    

    // tell the delegate that the disclosure button has been tapped.
    [self.delegate mapViewController:self showDetailForAnnotation:view.annotation];
    
}



//Tells the delegate that one of its annotation views was selected.
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //[spinner setBackgroundColor:[UIColor redColor]];
    [spinner startAnimating];
    // NOTA: leftCalloutAccessoryView viene inizializzata con un framerect di cui setto il thumb, le subview sono automaticamente sopra
    
    //[(UIImageView *)aView.leftCalloutAccessoryView insertSubview:spinner atIndex:0];
    //con questo codice aggiunge una subview (sopra l'immagine thumb!!)
    
    if (aView.leftCalloutAccessoryView) // se la leftCalloutAccessoryView ESISTE allora faccio il loading della thumb etc etc
    {
    [(UIImageView *)aView.leftCalloutAccessoryView addSubview:spinner];
    
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue,^{
        //block nel thread separato
        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            //main thread
            [spinner stopAnimating]; 
            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
            
        });
        
    });
    dispatch_release(downloadQueue); //altrimenti c'è un memory leak
    } // fine if
    
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
    self.mapView.delegate = self; //delegate per callout
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
