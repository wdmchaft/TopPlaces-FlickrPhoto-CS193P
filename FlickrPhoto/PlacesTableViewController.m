//
//  PlacesTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 05/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotosTableViewController.h"
#import "FlickrPlaceAnnotation.h"
#import "MapViewController.h"

@interface PlacesTableViewController() <MapViewControllerDelegate>
@property (nonatomic,strong) NSDictionary *selectedPlace; //riga selezionata della tabella
@property (strong,nonatomic) NSDictionary *placesByCountry;
@property (strong,nonatomic) UIActivityIndicatorView *spinner; //in questo modo la posso ridisegnare quando cambio la modalità dello schermo
@property (nonatomic, strong) NSDictionary *flickrSelected; // dizionario di posti o foto
@end

@implementation PlacesTableViewController
@synthesize places = _places;
@synthesize selectedPlace = _selectedPlace;
@synthesize placesByCountry = _placesByCountry;
@synthesize spinner = _spinner;
@synthesize flickrSelected = _flickrSelected;

-(UIActivityIndicatorView *)spinner{
    if (!_spinner)  {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];     
    }
    
    CGRect bounds = [self.parentViewController.view bounds];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [_spinner setCenter:centerPoint];
    return _spinner;   
}

- (void)updatePlacesByCountry
{
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    for (NSDictionary *place in self.places) {
        NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
        NSString *country = [[placeName componentsSeparatedByString:@","] lastObject];
        NSMutableArray *places = [placesByCountry objectForKey:country];
        if (!places) {
            places = [NSMutableArray array];
            [placesByCountry setObject:places forKey:country];
        }
        [places addObject:place];
    }
    self.placesByCountry = placesByCountry;
}

-(void)setSelectedPlace:(NSDictionary *)selectedPlace
{
    if (_selectedPlace != selectedPlace ) _selectedPlace = selectedPlace;
}

-(void)setPlaces:(NSArray *)places
{   
    if (_places != places){
        _places = places;
        if (self.tableView.window) { 
            [self updatePlacesByCountry];
            [self.tableView reloadData];
        }
    }    
}

// recupera una lista di posti da flickr
-(NSArray *)getListOfPlaces{
return [FlickrFetcher topPlaces];
} 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{  
    [super viewWillAppear:animated];

    
    self.tableView.hidden = YES;
    [self.parentViewController.view addSubview:self.spinner];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [self.spinner startAnimating];
  
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue,^{
        //block
        NSArray *listOfPlaces =[self getListOfPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.hidden = NO;
            [self.spinner stopAnimating];
            [self.spinner hidesWhenStopped];
            self.places = listOfPlaces; //modifica la UI (tabella) per questo lo metto nella main queue
            
        });
        
    });
    dispatch_release(downloadQueue); //altrimenti c'è un memory leak
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSString *)countryForSection:(NSInteger)section
{
    return [[self.placesByCountry allKeys] objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self countryForSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [self.placesByCountry count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSString *country = [self countryForSection:section];
    NSArray *placesByCountry = [self.placesByCountry objectForKey:country];
    return [placesByCountry count];
    // return [self.places count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    /**
     NSDictionary *place = [self.places objectAtIndex:indexPath.row]; 
     NSString *flickrPlaceName= [place objectForKey:FLICKR_PLACE_NAME];
     NSMutableArray *placeDetails= [[flickrPlaceName componentsSeparatedByString:@","] mutableCopy];
     **/
    NSString *country = [self countryForSection:indexPath.section];
    NSArray *placesByCountry = [self.placesByCountry objectForKey:country];
    NSDictionary *place = [placesByCountry objectAtIndex:indexPath.row]; 
    NSString *flickrPlaceName= [place objectForKey:FLICKR_PLACE_NAME];
    NSMutableArray *placeDetails= [[flickrPlaceName componentsSeparatedByString:@","] mutableCopy];
    
    NSString *town=@"";
    NSString *subtitle=@"";
    
    if ([placeDetails count] != 0){
        town = [placeDetails  objectAtIndex:0]; 
        [placeDetails removeObjectAtIndex:0];
        for (NSString* element in placeDetails) {
            subtitle = [subtitle stringByAppendingFormat:element];    
        }
    }
    
    cell.textLabel.text = town; 
    cell.detailTextLabel.text = subtitle;
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.places count]];
    for (NSDictionary *photo in self.places) {
        [annotations addObject:[FlickrPlaceAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show me photos"]) {
        
        //NSLog(@" %@",selectedPlace);
        //        NSDictionary *selectedPlace = [self.places objectAtIndex:indexPath.row];
        
        [segue.destinationViewController setPlaceName:self.flickrSelected]; 
    }
    
    if ([[segue identifier] isEqualToString:@"Show Me Photo Map" ]){
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]]; 
    }

}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    return nil;
}

- (void)mapViewController:(MapViewController *)sender showDetailForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPlaceAnnotation *fpa = (FlickrPlaceAnnotation *)annotation;
    self.flickrSelected = fpa.place;
    [self performSegueWithIdentifier:@"Show me photos" sender:self];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSString *country = [self tableView:self.tableView titleForHeaderInSection:indexPath.section];
    NSDictionary *selectedPlace = [[self.placesByCountry valueForKey:country] objectAtIndex:indexPath.row];
    self.flickrSelected =selectedPlace;
    //NSLog(@" posto selezionato %@",self.flickrSelected);
    [self performSegueWithIdentifier:@"Show me photos" sender:self];
    
}

#pragma mark - Rotazione schermo
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.spinner setNeedsDisplay];
}



@end
