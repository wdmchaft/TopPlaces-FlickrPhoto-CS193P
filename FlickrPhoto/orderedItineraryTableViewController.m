//
//  orderedItineraryTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "orderedItineraryTableViewController.h"
#import "Place.h"
#import "Itinerary.h"
#import "VacationHelper.h"
#import "VacationPhotosTableViewController.h"

@interface orderedItineraryTableViewController ()
@property (nonatomic,strong) NSOrderedSet *orderedPlaces;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reorderButton;

@end


@implementation orderedItineraryTableViewController
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
    if (_orderedPlaces != orderedPlaces)
    {_orderedPlaces = orderedPlaces;
      /**
        for (Place *myPlace in _orderedPlaces) {
            NSLog(@"%@",myPlace.place_description);
        }
       **/
       //if (self.tableView.window) 
           [self.tableView reloadData];
    }
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
    //lo metto qui anzichè in setVacation perchè in questo modo la tabella si aggiorna dal core data ogni volta che appare la view (e quindi aggiorna le modifiche anche con i push back)
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
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
    //[format setDateFormat:@"MMM dd, yyyy HH:mm"];
    [format setDateFormat:@"dd-MMM-yyyy"];
    //title = [title stringByAppendingFormat:@" %@ (%d)",[placeInfos objectAtIndex:0], [place.photos count]];
    
    title = [title stringByAppendingFormat:@"%@",[placeInfos objectAtIndex:0]];
    
    cell.textLabel.text = title; //nome del posto
    
    
    cell.detailTextLabel.text = [format stringFromDate:place.inserted]; //[NSString stringWithFormat:@"%d photos (nel db)", [place.photos count]];
    //cell.showsReorderControl = YES; //dicono di metterlo per visualizzare il reorder ma funziona anche senza
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
#pragma mark - Row reordering

- (IBAction)clickReorder:(id)sender {
    if ([self.reorderButton.title isEqualToString:@"Reorder"]){
        [[self tableView] setEditing:YES animated:YES];
        self.reorderButton.title=@"Done";
    }
    else {
        [[self tableView] setEditing:NO animated:YES];
        self.reorderButton.title=@"Reorder"; 
    }

}


/**
 
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 [[self tableView] setEditing:YES animated:YES];
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 [[self tableView] setEditing:YES animated:YES];
 
 }
 **/

//row rearrange without using edit button
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

//I want to be able to reorder cells in a table, but not to delete or insert them.
//http://stackoverflow.com/questions/3027818/reorder-cells-in-a-uitableview-without-displaying-a-delete-button
//in questo modo posso usare il metodo: "tableView:editingStyleForRowAtIndexPath:" per far comparire Edit o Insert in alcune righe senza che l'indentazione venga applicata su tutte!
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"muovo la riga");
    
    UITableViewCell *cella = [[UITableViewCell alloc] init];
    cella = [tableView cellForRowAtIndexPath:fromIndexPath];
    NSLog(@"prova:%@",cella.textLabel.text);
    NSLog(@"prova2:%@",cella.detailTextLabel.text);
    //rimuovo dall'indice e aggiungo a quello successivo
    /**
     Place *toBeReorderedPlace = [[Place alloc] init];
     toBeReorderedPlace.place_description = cella.textLabel.text;
     toBeReorderedPlace.inserted=(NSDate *)cella.detailTextLabel.text;
     NSLog(@"%@",toBeReorderedPlace);
     **/
}



// Override to support conditional rearranging of the table view.
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
        Place *place = [self.orderedPlaces objectAtIndex:indexPath.row]; // ask NSFRC for the NSMO at the row in question
        
        
        [segue.destinationViewController setPlace:place];
        [segue.destinationViewController setVacationName:self.vacation];
        
    } 
    
}

@end
