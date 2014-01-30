//
//  User.h
//  AirChat
//
//  Created by Marcello Mascia on 01/09/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : NSObject
{
	MCPeerID *																	_peerID;
	NSString *																	_identifier;
}


@property (nonatomic, readonly) MCPeerID *										peerID;
@property (nonatomic, readonly) NSString *										identifier;
@property (nonatomic, readonly) NSString *										name;


+ (User *)userWithPeerID:(MCPeerID *)peerID andIdentifier:(NSString *)identifier;
- (id)initWithPeerID:(MCPeerID *)peerID andIdentifier:(NSString *)identifier;


@end
