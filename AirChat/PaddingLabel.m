//
//  PaddingLabel.m
//  AirChat
//
//  Created by Marcello Mascia on 31/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "PaddingLabel.h"

@implementation PaddingLabel


- (void)drawTextInRect:(CGRect)rect
{
	UIEdgeInsets insets = {0., 10., 0., 10.};

	return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
