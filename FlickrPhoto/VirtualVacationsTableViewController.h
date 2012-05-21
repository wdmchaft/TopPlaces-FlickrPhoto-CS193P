//
//  VirtualVacationsTableViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VacationHelper.h"
#import "FormViewController.h"

@class VirtualVacationsTableViewController;
@protocol VirtualVacationsTableViewControllerDelegate <NSObject>
- (void)VirtualVacationsTableViewController:(VirtualVacationsTableViewController *)sender didSelectVacation:(NSString *)vacationName;
@end

@interface VirtualVacationsTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *vacations; 
@property (nonatomic, weak) id <VirtualVacationsTableViewControllerDelegate> delegate;

@end
