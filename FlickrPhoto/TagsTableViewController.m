//
//  TagsTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagsTableViewController.h"
#import "Tag+Create.h"
#import "VacationHelper.h"
#import "VacationPhotosTableViewController.h"

@interface TagsTableViewController ()
//@property (nonatomic, strong) UIManagedDocument *tagsDatabase; 
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation TagsTableViewController
//@synthesize tagsDatabase = _tagsDatabase;
@synthesize searchBar = _searchBar;
@synthesize vacation = _vacation;

- (void)setVacation:(NSString *)vacation
{
    if (_vacation != vacation) {
        _vacation = vacation;
        [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
            [self setupFetchedResultsController:vacation];
        }];
    }
}

- (void)setupFetchedResultsController:(UIManagedDocument *)vacation
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    
    //all TAGS!!
    //request.predicate = nil;
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"used" ascending:NO selector:@selector(compare:)]];
    
    // Predicate results based on text in the search bar
    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
   
        request.predicate = [NSPredicate predicateWithFormat:@"tag_name beginswith[c] %@", self.searchBar.text];
    }
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request 
                                                                       managedObjectContext:vacation.managedObjectContext
                                                                         sectionNameKeyPath:nil cacheName:nil ];

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
    self.searchBar.delegate=self; //lo potevo defnire anche dal Document Outline
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.showsCancelButton = NO;
    
    self.title=@"Tags";
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
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tag cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [tag.tag_name capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos (nel db) %@", [tag.taggedPhotos count], tag.used];
    
    return cell;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
  if ([segue.identifier isEqualToString:@"vacation photos"]){
        Tag *tag =[self.fetchedResultsController objectAtIndexPath:indexPath];
      
      
      [segue.destinationViewController setMytag:tag]; //prima questo
      [segue.destinationViewController setVacationName:self.vacation]; //e poi questo perchè nella segue quando setto questo, popolo la tabella dal db
      
    }

}

#pragma mark UISearchBarDelegate


//premo il tasto search: faccio scomparire tastiera e cancel
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

//mi appresto a scrivere: faccio comparire cancel
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
}

//man mano che scrivo nella ricerca: aggiorno la tabella
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Reset the fetchResultsController to include a predicate based on the search text
    [VacationHelper openVacation:self.vacation usingBlock:^(UIManagedDocument *vacation) {
        [self setupFetchedResultsController:vacation];
    }];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text= @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}


@end
