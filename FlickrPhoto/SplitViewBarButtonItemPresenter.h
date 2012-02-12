//
//  SplitViewBarButtonItemPresenter.h
//  Psychologist
//
//  Created by Marzoli Alessandro on 15/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> //<-- deve essere UIKit perchè è lì che c'è UIBarButtonItem

//come parlo alla mia detail view per dirgli di mettere, ad esempio un button?

@protocol SplitViewBarButtonItemPresenter <NSObject>
@property (nonatomic,strong) UIBarButtonItem *splitViewBarButtonItem;
@end
