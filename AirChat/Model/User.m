//
//  User.m
//  AirChat
//
//  Created by Marcello Mascia on 01/09/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "User.h"


@implementation User


+ (User *)userWithPeerID:(MCPeerID *)peerID andIdentifier:(NSString *)identifier
{
	return [[self alloc] initWithPeerID:peerID andIdentifier:identifier];
}

- (id)initWithPeerID:(MCPeerID *)peerID andIdentifier:(NSString *)identifier
{
	if((self = [super init]))
	{
		_peerID			= peerID;
		_identifier		= identifier;
	}
	
	return self;
}

- (NSString *)name
{
	return _peerID.displayName;
}


#pragma mark - Equality


- (BOOL)isEqualToUser:(User *)object
{
	BOOL status = (object && [_identifier isEqual:object.identifier]);
	
	return status;
}

- (BOOL)isEqual:(id)object
{
	BOOL status = [object isKindOfClass:[self class]] && [self isEqualToUser:object];
	
	return status;
}

- (unsigned)hash
{
	return [_identifier hash];
}


@end
