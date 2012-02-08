//
//  PhotoVC.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoVC.h"
#import "FlickrFetcher.h"
@interface PhotoVC() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation PhotoVC
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize photoToShow = _photoToShow;

-(void) setPhotoToShow:(NSDictionary *)photoToShow
{
if (_photoToShow != photoToShow) _photoToShow = photoToShow;
// reload ??    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //test
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue,^{
        //block
        NSURL *urlPhoto = [FlickrFetcher urlForPhoto:self.photoToShow format:FlickrPhotoFormatLarge];
        NSData *imageData = [NSData dataWithContentsOfURL:urlPhoto];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.imageView.image = [UIImage imageWithData:imageData]; 
            // imposto il size dello scrollview uguale a quello dell'immagine
            self.scrollView.contentSize = self.imageView.image.size;
            
            //setting the frame which is where in the content area of the scrollview that the image view is gonna live (setting it to be the entire content area)
            self.imageView.frame= CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            //RICORDARSI DI IMPOSTARE IL DELEGATE!! :)
        });
        
    });
    dispatch_release(downloadQueue); //altrimenti c'è un memory leak


}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self; // lo posso fare anche dallo storyboard lez.8 1:01
   
   }

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView; //return la view che voglio zoomare
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
