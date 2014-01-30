//
//  Message.h
//  AirChat
//
//  Created by Marcello Mascia on 25/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Message : NSObject
{

}


@property (nonatomic, readonly) NSString *										text;
@property (nonatomic, readonly) MCPeerID *										sender;
@property (nonatomic, readonly) NSDate *										date;


- (id)initWithData:(NSData *)data andSender:(MCPeerID *)peerID;


@end
