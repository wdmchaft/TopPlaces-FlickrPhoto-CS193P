//
//  RecentPhotosTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrPlaceAnnotation.h"


#define MAX_NUMBER 50; //of photos

@interface RecentPhotosTableViewController() <MapViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;

@end


@implementation RecentPhotosTableViewController
@synthesize mapButton = _mapButton;
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
    [self setMapButton:nil];
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
            
    
    //self.view.hidden=YES;
    //[self.parentViewController.view addSubview:spinner];
    [spinner startAnimating];
    UIBarButtonItem *oldButton =self.mapButton; // oppure imposto STRONG IBOutlet perchè altrimenti quando rilascio il button, se è weak diventa nullo
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue,^{
        //block
         //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];  //SIMULAZIONE LATENZA
           NSArray *listOfPhotos = [self getListOfPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
           [spinner stopAnimating];
           self.navigationItem.rightBarButtonItem = oldButton;
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
    NSString *photoDescription=[photo valueForKeyPath:@"description._content"];  // se è troppo lungo genera un errore: <Error>: CGAffineTransformInvert: singular matrix.  perchè credo che venga calcolato un resize adatto per visualizzarlo del detailTextLaber.text; SOLUZIONE: da storyboard -> minimum size, autoshrink no (nelle opzioni del subtitle della cella)

     

    
    // If photo title is nil set it to the description, else set it to unknown
    if (photoTitle == nil || [photoTitle isEqualToString:@""]) { //se non ho il titolo
        if (photoDescription == nil || [photoDescription isEqualToString:@""]) { //se non ho nemmeno la descizione
            photoTitle = @"Unknown";
        } else { //altrimenti uso la descrizione come titolo
            photoTitle = photoDescription;
        }
    } 


    
    cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.6 alpha:1];
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = photoDescription;

    
    //extra: add a photo's thumbnail image
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr thumbnail downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (([cell.textLabel.text isEqualToString:photoTitle] && [cell.detailTextLabel.text isEqualToString:photoDescription])) {
                UIImage *image = data ? [UIImage imageWithData:data] : nil;
                cell.imageView.image = image;
                cell.imageView.hidden = NO;
                [cell setNeedsLayout];  //esegue un update (reload) della cella senza fare il reload dell'intera tabella
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
    dispatch_release(downloadQueue);
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set the image to nil before it is loaded by GCD
    cell.imageView.image = nil;
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"Show Photo"]) {
    
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



- (PhotoViewController *)splitViewPhotoViewController
{
    id pvc = [self.splitViewController.viewControllers lastObject]; // it gets me "detail view controller"
    if (![pvc isKindOfClass:[PhotoViewController class]]){ pvc=nil;} 
    return pvc; // questo metodo ritorna nil a meno che non esista la detail
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
      //  NSLog(@" foto selezionata: %@",self.flickrSelected);
    if ([self splitViewPhotoViewController]){
       
        [self splitViewPhotoViewController].photoToShow =  self.flickrSelected ;
    }
   else [self performSegueWithIdentifier:@"Show Photo" sender:self];

}

@end
