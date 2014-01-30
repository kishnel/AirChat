//
//  Chat.m
//  AirChat
//
//  Created by Marcello Mascia on 24/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "Chat.h"
#import "Message.h"
#import "User.h"


NSString * const kNotificationChatDidReceiveMessage								= @"kNotificationChatDidReceiveMessage";
NSString * const kNotificationChatStateConnected								= @"kNotificationChatStateConnected";
NSString * const kNotificationChatStateNotConnected								= @"kNotificationChatStateNotConnected";
NSString * const kNotificationChatRequestStarted								= @"kNotificationChatRequestStarted";
NSString * const kNotificationMessageKey										= @"message";
NSString * const kNotificationPeerIDKey											= @"peerID";


@interface Chat() < MCSessionDelegate >

@property (nonatomic, strong) NSCountedSet *									queuedMessages;
@property (nonatomic, strong) NSMutableSet *									unsortedMessages;

@end

@implementation Chat


- (id)initWithSession:(MCSession *)session
{
	if((self = [super init]))
	{
		_session			= session;
		_session.delegate	= self;
		
		_unsortedMessages	= [NSMutableSet new];
		_queuedMessages		= [NSCountedSet new];
	}
	
	return self;
}

- (void)setSession:(MCSession *)session
{
	if(session != _session)
	{
		_session.delegate	= nil;
		
		_session			= session;
		_session.delegate	= self;
	}
}

- (NSArray *)members
{
	return self.session.connectedPeers;
}

- (NSString *)title
{
	NSString *result		= NSLocalizedString(@"Chat", nil);
	
	if (self.members.count)
	{
		MCPeerID *peer		= self.members[0];
		result				= peer.displayName;
	}
	
	return result;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@> %@ %@", NSStringFromClass(self.class), self.title, self.members];
}

- (NSArray *)messages
{
	NSSortDescriptor *descriptor	= [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
	NSArray *results				= [self.unsortedMessages sortedArrayUsingDescriptors:@[descriptor]];
	
	return results;
}

- (void)setIsActive:(BOOL)isActive
{
	if(isActive != _isActive)
	{
		_isActive = isActive;
		
		if(_isActive)
		{
			[self.unsortedMessages addObjectsFromArray:[self.queuedMessages allObjects]];

			[self.queuedMessages removeAllObjects];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatDidReceiveMessage object:self];
		}
	}
}

- (NSInteger)unreadCount
{
	return self.queuedMessages.count;
}


#pragma mark - Actions


- (BOOL)sendText:(NSString *)text fromPeerID:(MCPeerID *)peerID
{
	NSData *data			= [text dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error			= nil;
	BOOL result				= NO;
	
	if([_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error])
	{
		Message *message	= [[Message alloc] initWithData:data andSender:peerID];
		[self.unsortedMessages addObject:message];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatDidReceiveMessage
															object:self
														  userInfo:@{kNotificationMessageKey : message}];
		
		result				= YES;
	}
	else
	{
		NSLog(@"ERROR SENDING DATA: %@", error);
	}
	
	return result;
}

- (void)sendSystemMessage:(NSString *)text
{
	NSData *data		= [text dataUsingEncoding:NSUTF8StringEncoding];
	Message *message	= [[Message alloc] initWithData:data andSender:nil];
	
	if(_isActive)
	{
		[self.unsortedMessages addObject:message];
	}
	else
	{
		[self.queuedMessages addObject:message];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatDidReceiveMessage
														object:self
													  userInfo:@{kNotificationMessageKey : message}];
}

- (void)exit
{
	[_session disconnect];
}


#pragma mark - MCSession delegate methods


- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{	
	switch (state)
	{
		case MCSessionStateConnecting:
		{
			NSLog(@"MCSESSION: state for peer %@ changed -> CONNECTING...", peerID);
			
			break;
		}
			
		case MCSessionStateConnected:
		{
			NSLog(@"MCSESSION: state for peer %@ changed -> CONNECTED", peerID);
			
			dispatch_async(dispatch_get_main_queue(), ^
			{
				if(!_firstConnection)
				{
					_firstConnection = YES;
					
					[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatStateConnected
																		object:self
																	  userInfo:@{kNotificationPeerIDKey : peerID}];
				}
				else
				{
					NSString *format	= NSLocalizedString(@"%@ is connected", nil);
					NSString *text		= [NSString stringWithFormat:format, peerID.displayName];
					[self sendSystemMessage:text];
				}
			});
			
			break;
		}
			
		case MCSessionStateNotConnected:
		{
			NSLog(@"MCSESSION: state for peer %@ changed -> NOT CONNECTED!", peerID);
			
			dispatch_async(dispatch_get_main_queue(), ^
			{
				if(!_firstConnection)
				{
					_firstConnection = YES;
					
					[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatStateNotConnected
																		object:self
																	  userInfo:@{kNotificationPeerIDKey : peerID}];
					
				}
				else
				{
					NSString *format	= NSLocalizedString(@"%@ left the building", nil);
					NSString *text		= [NSString stringWithFormat:format, peerID.displayName];
					[self sendSystemMessage:text];
				}
			});
			
			break;
		}
			
		default:
			break;
	}
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
	NSLog(@"DID RECEIVE CERTIFICATE: %@ FROM PEER: %@", certificate, peerID);
	dispatch_async(dispatch_get_main_queue(), ^ {
		certificateHandler(YES);
	});
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
	NSLog(@"RECEIVED DATA FROM PEER: %@", peerID);
		
	dispatch_async(dispatch_get_main_queue(), ^ {
		Message *message = [[Message alloc] initWithData:data andSender:peerID];
		
		if(_isActive)
		{
			[self.unsortedMessages addObject:message];
		}
		else
		{
			[self.queuedMessages addObject:message];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatDidReceiveMessage
															object:self
														  userInfo:@{kNotificationMessageKey : message}];
	});
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
	NSLog(@"DID START RECEIVING RESOURCE: %@ FROM PEER: %@", resourceName, peerID);
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
	NSLog(@"DID FINISH RECEIVING RESOURCE: %@ FROM PEER: %@", resourceName, peerID);
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
	NSLog(@"DID RECEIVE STREAM: %@ FROM PEER: %@", streamName, peerID);
}


@end
