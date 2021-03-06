//
//  Tag.h
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * tag_name;
@property (nonatomic, retain) NSNumber * used;
@property (nonatomic, retain) NSSet *taggedPhotos;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addTaggedPhotosObject:(Photo *)value;
- (void)removeTaggedPhotosObject:(Photo *)value;
- (void)addTaggedPhotos:(NSSet *)values;
- (void)removeTaggedPhotos:(NSSet *)values;

@end
