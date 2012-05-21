//
//  OrderedItineraryTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OrderedItineraryTableViewController.h"
#import "Place.h"
#import "Itinerary+Create.h"
#import "VacationHelper.h"
#import "VacationPhotosTableViewController.h"

@interface OrderedItineraryTableViewController ()
@property (nonatomic,strong) NSOrderedSet *orderedPlaces;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reorderButton;

@end


@implementation OrderedItineraryTableViewController
@synthesize vacation =_vacation;
@synthesize orderedPlaces = _orderedPlaces;
@synthesize reorderButton = _reorderButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setVacation:(NSString *)vacation
{
    if (_vacation != vacation) {
        _vacation = vacation;
        
    }
}

-(void)setOrderedPlaces:(NSOrderedSet *)orderedPlaces
{

    _orderedPlaces = orderedPlaces;
    
    [self.tableView reloadData];
    
}


-(void)getOrderedPlacesFromVacation:(UIManagedDocument *)vacation
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Itinerary"]; //i have only 1 itinerary per vacation itinerary
    
    NSError *error = nil;
    NSArray *itineraries = [vacation.managedObjectContext executeFetchRequest:request error:&error]; 
    
    Itinerary *myItinerary = [itineraries lastObject];
    
    self.orderedPlaces = myItinerary.hasPlaces;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.title=@"Places";
   
    [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
        [self getOrderedPlacesFromVacation:vacation];
    }];
    
    
    
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
    [self setReorderButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orderedPlaces count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itinerary cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Place *place = [self.orderedPlaces objectAtIndex:indexPath.row];
    NSMutableArray *placeInfos= [[place.place_description componentsSeparatedByString:@","] mutableCopy];
    NSString *title = [[NSString alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MMM-yyyy"];
    
    title = [title stringByAppendingFormat:@"%@",[placeInfos objectAtIndex:0]];
    
    cell.textLabel.text = title; //nome del posto
    
    
    cell.detailTextLabel.text = [format stringFromDate:place.inserted]; 
    return cell;
    
}


#pragma mark - Row reordering

- (IBAction)clickReorder:(id)sender {
    if ([self.reorderButton.title isEqualToString:@"Reorder"]){
        [[self tableView] setEditing:YES animated:YES];
        self.reorderButton.title=@"Done";
    }
    else {
        [[self tableView] setEditing:NO animated:YES];
        self.reorderButton.title=@"Reorder"; 
        [self reorderItineraryList:[self.orderedPlaces copy]];
    }
    
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    UITableViewCell *cella = [[UITableViewCell alloc] init];
    cella = [tableView cellForRowAtIndexPath:fromIndexPath];
    
    
    NSMutableOrderedSet* orderedSet = [self.orderedPlaces mutableCopy];
    
    NSInteger fromIndex = fromIndexPath.row;
    NSInteger toIndex = toIndexPath.row;
    
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:fromIndex];
    
    if (fromIndex > toIndex) {
        // we're moving up
        [orderedSet moveObjectsAtIndexes:indexes toIndex:toIndex];
    } else {
        // we're moving down
        [orderedSet moveObjectsAtIndexes:indexes toIndex:toIndex-[indexes count]];
    }
    
    self.orderedPlaces = orderedSet; 
    
}

-(void)reorderItineraryList:(NSMutableOrderedSet *)orderedPlaces
{
    [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
        [Itinerary updatePlacesOrder:orderedPlaces inManagedObjectContext:vacation];
    }];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"vacation photos"]) {
        Place *place = [self.orderedPlaces objectAtIndex:indexPath.row];
        
        
        [segue.destinationViewController setPlace:place];
        [segue.destinationViewController setVacationName:self.vacation];
        
    } 
    
}

@end
