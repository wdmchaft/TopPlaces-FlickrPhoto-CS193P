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
#define MAX_NUMBER 50; //of photos

@interface RecentPhotosTableViewController()
@end

@implementation RecentPhotosTableViewController
@synthesize placeName = _placeName;
@synthesize recentPhotos = _recentPhotos;


-(void)setPlaceName:(NSDictionary *)placeName
{
    if (_placeName != placeName) _placeName = placeName;
    //NSLog(@" %@ ",placeName);
}

-(void)setRecentPhotos :(NSArray *)recentPhotos 
{   
    if (_recentPhotos != recentPhotos){
        _recentPhotos = recentPhotos;
        if (self.tableView.window) { 
            [self.tableView reloadData];
        }
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
 Se invece definissi tutto qui dentro, l'awakeFromNib viene chiamato solo una volta quando setto gli elementi dal NIB per cui non ho bisogno di usare la condizione IF
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *selectedPhoto = [self.recentPhotos objectAtIndex:indexPath.row];
        [segue.destinationViewController setPhotoToShow:selectedPhoto]; 
        
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
    if ([self splitViewPhotoViewController]){
        NSDictionary *selectedPhoto = [self.recentPhotos objectAtIndex:indexPath.row];
        [self splitViewPhotoViewController].photoToShow =selectedPhoto ;
    }

}

@end
