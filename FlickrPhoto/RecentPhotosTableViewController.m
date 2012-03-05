//
//  RecentPhotosTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoVC.h"
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrPlaceAnnotation.h"


#define MAX_NUMBER 50; //of photos

@interface RecentPhotosTableViewController() <MapViewControllerDelegate>
@end


@implementation RecentPhotosTableViewController
@synthesize placeName = _placeName;
@synthesize recentPhotos = _recentPhotos;
@synthesize flickrSelected = _flickrSelected;

-(void) setFlickrSelected:(NSDictionary *)flickrSelected
{
    if (_flickrSelected != flickrSelected) _flickrSelected = flickrSelected;
}


-(void)setPlaceName:(NSDictionary *)placeName
{ 
    if (_placeName != placeName) _placeName = placeName;
    //NSLog(@" %@ ",placeName); 
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.recentPhotos count]];
    for (NSDictionary *photo in self.recentPhotos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
   //  NSLog(@" %@",annotations);
    return annotations;
}



#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation; //potrei fare introspection
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

/**
-(NSDictionary *)mapViewController:(MapViewController *)sender photoForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *mkav= (MKAnnotationView *)annotation;
    FlickrPhotoAnnotation *annot = (FlickrPhotoAnnotation *)mkav.annotation;
    NSString *codice = annot.codice_id;
    for (NSDictionary *photo in self.recentPhotos) {

        if ([codice isEqualToString:[photo valueForKey:@"id"]]){
            return photo;}
}
    return nil;
}
**/

- (void)mapViewController:(MapViewController *)sender showDetailForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    self.flickrSelected = fpa.photo;
    if ([self splitViewPhotoViewController]){
       [[self splitViewPhotoViewController] setPhotoToShow: self.flickrSelected];
    }
    else [self performSegueWithIdentifier:@"Show Photo" sender:self];
}



-(void)setRecentPhotos :(NSArray *)recentPhotos 
{   
    if (_recentPhotos != recentPhotos){
        _recentPhotos = recentPhotos;
         //model changed, so update our view (the table)
        if (self.tableView.window) {[self.tableView reloadData];}
    } 
        //NSLog(@" %@ ",_recentPhotos);
}


// recupera una lista di foto dato un posto
-(NSArray *)getListOfPhotos{
    return [FlickrFetcher photosInPlace:self.placeName maxResults:50];
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

-(void)awakeFromNib{
/**
 PROBLEMA: ho una barra mista: 2 pulsanti li inserisco da codice, uno da storyboard.
 Usando il codice che uso qui sotto in viewWillAppear ho bisogno di mettere un controllo IF, altrimenti tutte le volte che appare questo VC si aggiungerebbero pulsanti a quelli presenti.
 Se invece definissi tutto qui dentro, l'awakeFromNib viene chiamato solo una volta quando setto gli elementi dal NIB, per cui non ho bisogno di usare la condizione IF
 **/
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

 
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //[spinner setBackgroundColor:[UIColor redColor]];
    
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:@"Flip"                                            
                                   style:UIBarButtonItemStyleBordered 
                                   target:self 
                                   action:@selector(flipView)];
    UIBarButtonItem *loader = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    

    NSMutableArray *rightButtons = [  self.navigationItem.rightBarButtonItems mutableCopy];
    if ([rightButtons count]<=1){ //fix sbrigativo... se ho solo un item (ossia quello che ho messo da storyboard, aggiungo gli altri); soluzione migliore : creare una property per lo spinner e inizializzare tutti in awakeFromNib (che viene chiamato solo 1 volta (come viewDidLoad) quando tutto è settato... in questo modo la barra di 3 pulsanti rimarrà sempre tale :)
    [rightButtons addObject:flipButton];
    [rightButtons addObject:loader];
    }
   self.navigationItem.rightBarButtonItems = rightButtons;
        
    
    //self.view.hidden=YES;
    //[self.parentViewController.view addSubview:spinner];
    [spinner startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue,^{
        //block
           NSArray *listOfPhotos = [self getListOfPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            self.recentPhotos = listOfPhotos; //modifica la UI (tabella) per questo lo metto nella main queue
            
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
/**
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
**/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.recentPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    //recent photos dictionary
    NSDictionary *photo = [self.recentPhotos objectAtIndex:indexPath.row]; 
    
    NSString *photoTitle= [photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description=[photo valueForKeyPath:@"description._content"]; 

    if (!photoTitle || [photoTitle isEqualToString:@""]) {
        if(description && ![description isEqualToString:@""]){photoTitle= description;}
        else { //se non esiste nè il titolo nè la descrizione
        photoTitle= @"senza titolo";
        description =@"senza descrizione";
        }
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.6 alpha:1];
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = description;
    
    //NSMutableArray *placeDetails= [[flickrPlaceName componentsSeparatedByString:@","] mutableCopy];
    
    //extra: add a photo's thumbnail image
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
        //NSLog(@"RecentPhotosTableViewController tableView:cellForRowAtIndexPath, [NSData dataWithContentsOfURL]");
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (([cell.textLabel.text isEqualToString:photoTitle] && [cell.detailTextLabel.text isEqualToString:description])) {
                UIImage *image = data ? [UIImage imageWithData:data] : nil;
                cell.imageView.image = image;
                cell.imageView.hidden = NO;
                [cell setNeedsLayout];  //esegue un update (reload) della cella senza fare il reload dell'intera tabella
            }
        });
    });
    dispatch_release(downloadQueue);
    
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"Show Photo"]) {
    
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        //NSDictionary *selectedPhoto = [self.recentPhotos objectAtIndex:indexPath.row];
        [segue.destinationViewController setPhotoToShow:self.flickrSelected]; 
        
    }
    
    if ([[segue identifier] isEqualToString:@"Show Me Photo Map" ]){
    
        id destSegue = segue.destinationViewController;        
        MapViewController *mapVC = (MapViewController *)destSegue; //non faccio l'introspection perchè so per certo che la segue è una mapviewcontroller
        mapVC.delegate = self; //imposto questo controller come il delegate del mapviewcontroller
       // mapVC.annotations = [self mapAnnotations];
     [segue.destinationViewController setAnnotations:[self mapAnnotations]]; 
    }
    
}



- (PhotoVC *)splitViewPhotoViewController
{
    id hvc = [self.splitViewController.viewControllers lastObject]; // it gets me "detail view controller"
    if (![hvc isKindOfClass:[PhotoVC class]]){ hvc=nil;} 
    return hvc; // questo metodo ritorna nil a meno che  the detail outside the splitviewcontroller i'm in is happinessviewcontroller
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
     NSDictionary *selectedPhoto = [self.recentPhotos objectAtIndex:indexPath.row];
    self.flickrSelected = selectedPhoto;
    if ([self splitViewPhotoViewController]){
       
        [self splitViewPhotoViewController].photoToShow =  self.flickrSelected ;
    }
   else [self performSegueWithIdentifier:@"Show Photo" sender:self];

}

@end
