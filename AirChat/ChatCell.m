//
//  ChatCell.m
//  AirChat
//
//  Created by Marcello Mascia on 25/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "Chat.h"
#import "ChatCell.h"
#import "CoreController.h"
#import "User.h"


@implementation ChatCell


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self selector:@selector(chatDidReceiveMessage:) name:kNotificationChatDidReceiveMessage object:nil];
	[nc addObserver:self selector:@selector(chatStateConnected:) name:kNotificationChatStateConnected object:nil];
	[nc addObserver:self selector:@selector(chatStateNotConnected:) name:kNotificationChatStateNotConnected object:nil];
	[nc addObserver:self selector:@selector(chatRequestStarted:) name:kNotificationChatRequestStarted object:nil];
}

- (void)setUser:(User *)user
{
	if(user != _user)
	{
		_user							= user;
		
		self.textLabel.text				= _user.name;
		
		NSString *detail				= nil;
		CoreController *cc				= [CoreController sharedController];
		Chat *chat						= [cc chatWithUser:_user];
		if(chat)
		{
			detail						= [NSString stringWithFormat:@"%d", chat.unreadCount];
		}

		self.detailTextLabel.text		= detail;
	}
}


#pragma mark - Notifications


- (void)chatDidReceiveMessage:(NSNotification *)notification
{
	Chat *chat							= notification.object;
	
	if([chat.members containsObject:_user.peerID])
	{
		self.detailTextLabel.text		= [NSString stringWithFormat:@"%d", chat.unreadCount];
	}
}

- (void)chatRequestStarted:(NSNotification *)notification
{
	Chat *chat							= notification.object;
	
	if([chat.connectedUser isEqual:_user])
	{
		[_activityIndicator startAnimating];
	}
}

- (void)chatStateConnected:(NSNotification *)notification
{
	Chat *chat							= notification.object;
	
	if([chat.connectedUser isEqual:_user])
	{
		[_activityIndicator stopAnimating];
	}
}

- (void)chatStateNotConnected:(NSNotification *)notification
{
	Chat *chat							= notification.object;
	
	if([chat.connectedUser isEqual:_user])
	{
		[_activityIndicator stopAnimating];
	}
}


@end
