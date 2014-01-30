//
//  ChatCell.h
//  AirChat
//
//  Created by Marcello Mascia on 25/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import <UIKit/UIKit.h>


//@class User;


@interface ChatCell : UITableViewCell
{
	IBOutlet UIActivityIndicatorView *											_activityIndicator;
}


@property (nonatomic, strong) User *											user;
//@property (nonatomic, strong) MCPeerID *										peerID;


@end
