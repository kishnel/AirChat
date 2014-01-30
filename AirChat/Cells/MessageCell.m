//
//  MessageCell.m
//  AirChat
//
//  Created by Marcello Mascia on 25/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "Message.h"
#import "MessageCell.h"
#import "CoreController.h"


@implementation MessageCell


- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_textLabel.layer.cornerRadius = 5.;
}

- (void)setMessage:(Message *)message
{
	CoreController *cc			= [CoreController sharedController];
	BOOL isMine					= (cc.myPeerID == message.sender);
	
	_textLabel.text				= message.text;
	_textLabel.textAlignment	= isMine ? NSTextAlignmentRight : NSTextAlignmentLeft;
	_textLabel.backgroundColor	= isMine ? [UIColor colorWithRed:0.549 green:0.678 blue:0.784 alpha:1.000] : [UIColor colorWithWhite:.9 alpha:1.];
	_textLabel.textColor		= isMine ? [UIColor whiteColor] : [UIColor blackColor];
	
	if(!message.sender)
	{
		_textLabel.textAlignment	= NSTextAlignmentCenter;
		_textLabel.backgroundColor	= [UIColor clearColor];
		_textLabel.textColor		= [UIColor lightGrayColor];
	}
}


@end
