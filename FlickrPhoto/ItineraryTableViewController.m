//
//  ItineraryTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItineraryTableViewController.h"
#import "Place.h"
#import "VacationManager.h"
#import "PhotosByPlaceTableViewController.h"
#import "VacationPhotosTableViewController.h"




@interface ItineraryTableViewController () 
@property (nonatomic, strong) UIManagedDocument *placeDatabase; 

@end

@implementation ItineraryTableViewController
@synthesize vacation =_vacation;
@synthesize placeDatabase = _placeDatabase;



-(void)setVacation:(NSString *)vacation
{
    if (_vacation!=vacation) _vacation=vacation;
}

-(void)setPlaceDatabase:(UIManagedDocument *)placeDatabase
{ 
    if (_placeDatabase != placeDatabase) {
        _placeDatabase = placeDatabase;
        [self useDocument];
    }
}

- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    //all PLACES
    //request.predicate = nil;
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"inserted" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]; // senza il selector l'ordinamento era case insensitive
 
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request 
                                                                       managedObjectContext:self.placeDatabase.managedObjectContext
                                                                         sectionNameKeyPath:nil cacheName:nil ];
}

//hook to the database!
-(void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.placeDatabase.fileURL path]]) // se il db non esiste nel disco
    {
        //[self.tagsDatabase saveToURL:self.tagsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        //[self setupFetchedResultsController];  
        //[self fetchFlickrDataIntoDocument:self.tagsDatabase];
        
        //}];
    } else if (self.placeDatabase.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [self.placeDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];  //property CoreDataTableViewController.h usata per popolare la tabella

            NSLog(@"db chiuso");
            
        }];
    } else if (self.placeDatabase.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
        [self setupFetchedResultsController]; 
        NSLog(@"db aperto");
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=@"Places";
    if (!self.placeDatabase) {
        //NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        //url = [url URLByAppendingPathComponent:self.vacation];
        //NSLog(@" %@",url);
        // url is now "<Documents Directory>/Default Photo Database"
        //self.tagsDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
        self.placeDatabase = [VacationManager sharedManagedDocumentForVacation:self.vacation];
    }
    
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itinerary cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableArray *placeInfos= [[place.place_description componentsSeparatedByString:@","] mutableCopy];
    NSString *title = [[NSString alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    //[format setDateFormat:@"MMM dd, yyyy HH:mm"];
     [format setDateFormat:@"dd-MMM-yyyy"];
    //title = [title stringByAppendingFormat:@" %@ (%d)",[placeInfos objectAtIndex:0], [place.photos count]];
    
    title = [title stringByAppendingFormat:@"%@",[placeInfos objectAtIndex:0]];

    cell.textLabel.text = title; //nome del posto
    
    
    cell.detailTextLabel.text = [format stringFromDate:place.inserted]; //[NSString stringWithFormat:@"%d photos (nel db)", [place.photos count]];
    
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"vacation photos"]) {
        Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath]; // ask NSFRC for the NSMO at the row in question
        [segue.destinationViewController setPlace:place];
        [segue.destinationViewController setVacationName:self.vacation];
    } 
}

@end
