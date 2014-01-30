//
//  Message.m
//  AirChat
//
//  Created by Marcello Mascia on 25/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "Message.h"


@interface Message()

@property (nonatomic, strong) NSString *										text;
@property (nonatomic, strong) MCPeerID *										sender;
@property (nonatomic, strong) NSDate *											date;

@end

@implementation Message


- (id)initWithData:(NSData *)data andSender:(MCPeerID *)peerID
{
	if((self = [super init]))
	{
		 _text		= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		_sender		= peerID;
		_date		= [NSDate date];
	}
	
	return self;
}


@end
