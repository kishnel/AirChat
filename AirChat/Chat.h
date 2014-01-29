//
//  Chat.h
//  AirChat
//
//  Created by Marcello Mascia on 24/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const kNotificationChatDidReceiveMessage;
extern NSString * const kNotificationChatStateConnected;
extern NSString * const kNotificationChatStateNotConnected;
extern NSString * const kNotificationChatRequestStarted;
extern NSString * const kNotificationMessageKey;
extern NSString * const kNotificationPeerIDKey;


@class Message;
@class User;


@interface Chat : NSObject
{
	BOOL																		_firstConnection;
}


@property (nonatomic, readonly) NSString *										title;
@property (nonatomic, strong) MCSession *										session;
@property (nonatomic, readonly) NSArray *										members;
@property (nonatomic, readonly) NSInteger										unreadCount;
@property (nonatomic, readonly) NSArray *										messages;
@property (nonatomic, readwrite) BOOL											isActive;
@property (nonatomic, strong) User *											connectedUser;


- (id)initWithSession:(MCSession *)session;
- (BOOL)sendText:(NSString *)text fromPeerID:(MCPeerID *)peerID;
- (void)exit;


@end
