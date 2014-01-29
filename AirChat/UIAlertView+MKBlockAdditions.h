//
//  UIAlertView+MKBlockAdditions.h
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//

#import <Foundation/Foundation.h>


typedef void (^DismissBlock)(int buttonIndex, UIAlertView *alertView);


@interface UIAlertView (Block) <UIAlertViewDelegate>


@property (nonatomic, copy) DismissBlock										dismissBlock;


@end
