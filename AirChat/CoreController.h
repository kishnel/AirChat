//
//  CoreController.h
//  Menelao
//
//  Created by Marcello Mascia on 01/05/2012.
//  Copyright (c) 2012 - kishnel.com. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const kServiceType;
extern NSString * const kNotificationChatDidStart;
extern NSString * const kUserIDKey;


@class Chat;
@class User;


@interface CoreController : NSObject
{
	
}


@property (nonatomic, strong) NSMutableArray *									chats;
@property (nonatomic, readonly) MCPeerID *										myPeerID;
@property (nonatomic, readonly) NSString *										myIdentifier;


+ (CoreController *)sharedController;

- (Chat *)chatForPeerID:(MCPeerID *)peerID;
- (Chat *)chatWithUser:(User *)user;


@end
