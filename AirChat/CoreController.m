//
//  CoreController.m
//  Menelao
//
//  Created by Marcello Mascia on 01/05/2012.
//  Copyright (c) 2012 - kishnel.com. All rights reserved.
//

#import "Chat.h"
#import "CoreController.h"
#import "User.h"


static CoreController *sharedController											= nil;

NSString * const kServiceType													= @"ksh-airchat";
NSString * const kNotificationChatDidStart										= @"kNotificationChatDidStart";
NSString * const kUserIDKey														= @"userID";


@interface CoreController() < MCNearbyServiceAdvertiserDelegate >

@property (nonatomic, strong) NSString *										myName;
@property (nonatomic, strong) MCPeerID *										myPeerID;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *						advertiser;

@end


@implementation CoreController


+ (CoreController *)sharedController
{
	if(!sharedController)
	{
		sharedController = [CoreController new];
	}
	
	return sharedController;
}

- (id)init
{
	if((self = [super init]))
	{
		UIDevice *currentDevice			= [UIDevice currentDevice];
		
		_myName							= [currentDevice name];
		_myPeerID						= [[MCPeerID alloc] initWithDisplayName:_myName];

		NSDictionary *info				= @{kUserIDKey : self.myIdentifier};
		
		_advertiser						= [[MCNearbyServiceAdvertiser alloc] initWithPeer:_myPeerID discoveryInfo:info serviceType:kServiceType];
		_advertiser.delegate			= self;
		[_advertiser startAdvertisingPeer];

		_chats							= [NSMutableArray new];
	}
	
	return self;
}

- (NSString *)myIdentifier
{
	return [UIDevice currentDevice].identifierForVendor.UUIDString;
}


#pragma mark - 


- (Chat *)chatWithUser:(User *)user
{
	Chat *result = nil;
	
	for (Chat *chat in self.chats)
	{
		if ([chat.connectedUser isEqual:user])
		{
			result = chat;
			break;
		}
	}
	
	return result;
}

- (Chat *)chatForPeerID:(MCPeerID *)peerID
{
	Chat *result = nil;
	
	for (Chat *chat in self.chats)
	{
		if ([chat.members containsObject:peerID])
		{
			result = chat;
			break;
		}
	}
	
	return result;
}


#pragma mark - Advertiser delegate methods


- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
	NSLog(@"ERROR: %@", error);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
	NSLog(@"ADVERTISER INVITATION FROM: %@", peerID);
	
	// Accept or refuse a received invitation
	
	// Sanity check
	NSString *peerIdentifier		= [[NSString alloc] initWithData:context encoding:NSUTF8StringEncoding];
	if(!peerIdentifier.length)
	{
		NSLog(@"PEER %@ HAS NO IDENTIFIER", peerID);
		
		invitationHandler(NO, nil);
		
		return;
	}
	
	User *user							= [User userWithPeerID:peerID andIdentifier:peerIdentifier];
	
	// Let the user resume a previous chat if any
	{
		Chat *existingChat				= [self chatWithUser:user];
		if(existingChat)
		{
			MCSession *session			= [[MCSession alloc] initWithPeer:self.myPeerID];
			existingChat.session		= session;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatRequestStarted
																object:existingChat
															  userInfo:@{kNotificationPeerIDKey : peerID}];
			
			invitationHandler(YES, existingChat.session);
			
			return;
		}
	}
	
	// Request confirmation
	{
		NSString *format				= NSLocalizedString(@"%@ wants to chat with you", nil);
		NSString *text					= [NSString stringWithFormat:format, peerID.displayName];
		
		UIAlertView *alert				= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Chat request", nil)
														   message:text
														  delegate:[UIAlertView class]
												 cancelButtonTitle:NSLocalizedString(@"Reject", nil)
												 otherButtonTitles:NSLocalizedString(@"Accept", nil), nil];
		
		alert.dismissBlock				= ^(int buttonIndex, UIAlertView *alert)
		{
			BOOL result					= buttonIndex != alert.cancelButtonIndex ? YES : NO;
			MCSession *session			= nil;
					
			if(result)
			{
				session					= [[MCSession alloc] initWithPeer:self.myPeerID];
				Chat *chat				= [[Chat alloc] initWithSession:session];
				chat.connectedUser		= user;
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatRequestStarted
																	object:chat
																  userInfo:@{kNotificationPeerIDKey : peerID}];

				[self.chats addObject:chat];
			}
			
			invitationHandler(result, session);
		};
		
		[alert show];
	}
}


@end
