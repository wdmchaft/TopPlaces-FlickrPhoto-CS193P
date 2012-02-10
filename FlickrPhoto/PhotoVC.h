//
//  PhotoVC.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LAST_VIEWED_PHOTOS_KEY @"LAST_PHOTOS" //aggiunto da me

@interface PhotoVC : UIViewController
@property (nonatomic,strong) NSDictionary *photoToShow;
@end
