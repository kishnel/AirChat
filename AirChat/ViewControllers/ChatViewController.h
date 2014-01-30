//
//  ChatViewController.h
//  AirChat
//
//  Created by Marcello Mascia on 24/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController < UITableViewDataSource, UITableViewDelegate >
{
	IBOutlet UITableView *														_table;
	IBOutlet UIView *															_footerView;
	IBOutlet UITextField *														_textField;
	IBOutlet UIBarButtonItem *													_exitButton;
}


- (id)initWithChat:(Chat *)chat;


@end
