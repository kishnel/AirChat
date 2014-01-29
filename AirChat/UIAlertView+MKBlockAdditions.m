//
//  UIAlertView+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//

#import "UIAlertView+MKBlockAdditions.h"
#import <objc/runtime.h>


static char DISMISS_IDENTIFER;


@implementation UIAlertView (Block)


@dynamic dismissBlock;


- (void)setDismissBlock:(DismissBlock)dismissBlock
{
    objc_setAssociatedObject(self, &DISMISS_IDENTIFER, dismissBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DismissBlock)dismissBlock
{
    return objc_getAssociatedObject(self, &DISMISS_IDENTIFER);
}

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(alertView.dismissBlock)
	{
		alertView.dismissBlock(buttonIndex, alertView);
	}
}

@end