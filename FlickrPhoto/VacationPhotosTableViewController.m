//
//  VacationPhotosTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationPhotosTableViewController.h"
#import "Photo.h"
#import "PhotoViewController.h"

@interface VacationPhotosTableViewController ()

@end

@implementation VacationPhotosTableViewController
@synthesize place = _place;
@synthesize mytag =_mytag;
@synthesize vacationName = _vacationName;



- (void)setupFetchedResultsController:(UIManagedDocument *)vacation
{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];


    if (self.place) {
        
      
        request.predicate = [NSPredicate predicateWithFormat:@"scattateDove.place_description = %@", self.place.place_description];  
    }  else if (self.mytag)
    {         
        request.predicate = [NSPredicate predicateWithFormat:@"ANY etichettataDa.tag_name = %@", self.mytag.tag_name];     }
    else {
       //handle this...
    }
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]; // 
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request 
                                                                       managedObjectContext:vacation.managedObjectContext
                                                                         sectionNameKeyPath:nil cacheName:nil ];

}


-(void)setMytag:(Tag *)mytag
{
   
    _mytag=mytag;
    self.title=mytag.tag_name;
 
}


-(void)setPlace:(Place *)place
{
   
    _place = place;
    self.title = place.place_description;
 
}

- (void)setVacationName:(NSString *)vacationName
{
    if (_vacationName != vacationName) {
        _vacationName = vacationName;
        [VacationHelper openVacation:self.vacationName usingBlock:^(UIManagedDocument *vacation) {
            [self setupFetchedResultsController:vacation];
        }];
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"vacation photo cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = ![photo.title isEqualToString:@""]? photo.title : @"untitled";
    cell.detailTextLabel.text = photo.tags;
    
    return cell;
}

- (PhotoViewController *)splitViewPhotoViewController
{
    id pvc = [self.splitViewController.viewControllers lastObject]; 
    if (![pvc isKindOfClass:[PhotoViewController class]]){ pvc=nil;} 
    return pvc; 
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([self splitViewPhotoViewController]){
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self splitViewPhotoViewController].photoFromVacation = photo;
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        [segue.destinationViewController setPhotoFromVacation:photo];
        [segue.destinationViewController setTitle:photo.title];
    }
}
@end


