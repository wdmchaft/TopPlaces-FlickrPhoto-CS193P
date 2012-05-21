//
//  FlipSegue.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipSegue.h"



@implementation FlipSegue

-(void) perform{
    
    UIViewController *sourceVC = (UIViewController *) self.sourceViewController;
    UIViewController *destinationVC = (UIViewController *) self.destinationViewController;
    
    [UIView transitionWithView:sourceVC.navigationController.view duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [sourceVC.navigationController pushViewController:destinationVC animated:NO]; 
                        
                    }
                    completion:NULL];
    
    
    
}

@end
