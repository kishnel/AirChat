//
//  MessageCell.h
//  AirChat
//
//  Created by Marcello Mascia on 25/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Message;


@interface MessageCell : UITableViewCell
{
	IBOutlet UILabel *															_textLabel;
}


@property (nonatomic, weak) Message *											message;


@end
