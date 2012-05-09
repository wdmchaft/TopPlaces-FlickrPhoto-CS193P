//
//  FormViewController.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 19/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FormViewController;
@protocol FormViewControllerDelegate <NSObject>

-(void)addNewVacation:(FormViewController *)sender withName:(NSString *)name;

@end

@interface FormViewController : UIViewController
@property (nonatomic,weak) id <FormViewControllerDelegate> delegate;
@end
