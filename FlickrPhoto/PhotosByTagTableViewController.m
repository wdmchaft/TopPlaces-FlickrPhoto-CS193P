//
//  PhotosByPlaceTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosByTagTableViewController.h"
#import "Photo.h"
#import "PhotoViewController.h"

@interface PhotosByTagTableViewController ()

@end

@implementation PhotosByTagTableViewController

@synthesize tag = _tag;

- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    //foto scattate da un certo fotografo
    //request.predicate = [NSPredicate predicateWithFormat:@"etichettataDa.tag_name CONTAINS %@", self.tag.tag_name];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY etichettataDa.tag_name = %@", self.tag.tag_name]; // va bene anche il predicato sopra; questo qui è qualcosa tipo : qualsiasi (foto) collegata al tag (etichettataDa) che si chiama tag_name
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]; // senza il selector l'ordinamento era case insensitive
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request 
                                                                       managedObjectContext:self.tag.managedObjectContext
                                                                         sectionNameKeyPath:nil cacheName:nil ];
}



-(void)setMyTag:(Tag *)tag
{
    _tag =tag;
    self.title = tag.tag_name;
    [self setupFetchedResultsController];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"photo cell of a tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Config/Users/alessandromarzoli/Developer/FlickrPhoto/FlickrPhoto/SingleVacationTVC.hure the cell...
    //importo "photo.h" e non "photo+flick.h" perchè non creo foto ma le uso!!
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    //cell.detailTextLabel.text = photo.subtitle;

    return cell;
}
/**
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath]; // ask NSFRC for the NSMO at the row in question
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        // [segue.destinationViewController setImageURL:[NSURL URLWithString:photo.imageURL]];
        [segue.destinationViewController setImageURL:[NSURL URLWithString:photo.photo_url]];
        [segue.destinationViewController setDelegate:self]; //mi imposto come delegato!
        [segue.destinationViewController setTitle:photo.title];
    }
}
**/


@end

