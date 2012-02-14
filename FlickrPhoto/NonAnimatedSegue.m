//
//  NonAnimatedSegue.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NonAnimatedSegue.h"



@implementation NonAnimatedSegue

-(void) perform{
    //con questa riga eseguivo la segue senza animazione
   // [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];

    UIViewController *sourceVC = (UIViewController *) self.sourceViewController;
    UIViewController *destinationVC = (UIViewController *) self.destinationViewController;
    
    [UIView transitionWithView:sourceVC.navigationController.view duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        //per andare alla segue designata
                        [sourceVC.navigationController pushViewController:destinationVC animated:NO]; 
                        //per tornare indietro
                        // [sourceVC.navigationController popViewControllerAnimated:YES];
                        
                    }
                    completion:NULL];

    
    
}

@end
