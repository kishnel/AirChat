//
//  ViewController.h
//  AirChat
//
//  Created by Marcello Mascia on 24/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController < UITableViewDataSource, UITableViewDelegate >
{
	IBOutlet UITableView *														_table;
}

@end
