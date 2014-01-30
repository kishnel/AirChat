//
//  ChatViewController.m
//  AirChat
//
//  Created by Marcello Mascia on 24/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "Chat.h"
#import "ChatViewController.h"
#import "CoreController.h"
#import "Message.h"
#import "MessageCell.h"


static NSString * const kMessageCellIdentifier									= @"MessageCell";


@interface ChatViewController () < UITextFieldDelegate >


@property (nonatomic, strong) Chat *											chat;
@property (nonatomic, readonly) NSArray *										messages;


@end


@implementation ChatViewController


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithChat:(Chat *)chat
{
	if ((self = [super init]))
	{
		_chat = chat;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = _chat.title;
	
	self.navigationItem.rightBarButtonItem = _exitButton;
	
	[_table registerNib:[UINib nibWithNibName:kMessageCellIdentifier bundle:nil] forCellReuseIdentifier:kMessageCellIdentifier];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessage:) name:kNotificationChatDidReceiveMessage object:_chat];	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	_chat.isActive			= YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	[_textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	_chat.isActive			= NO;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)exitButtonPressed:(UIBarButtonItem *)button
{
	[_chat exit];
	
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Model


- (NSArray *)messages
{
	return _chat.messages;
}

- (void)chatDidReceiveMessage:(NSNotification *)notification
{
	Message *message		= notification.userInfo[kNotificationMessageKey];
	NSInteger index			= [self.messages indexOfObject:message];
	
	if(index != NSNotFound)
	{
		NSIndexPath *indexPath	= [NSIndexPath indexPathForRow:index inSection:0];

//		[_table beginUpdates];
//		[_table insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//		[_table endUpdates];
		[_table reloadData];
		
		[_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}


#pragma mark - Table stuff


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Message *message			= self.messages[indexPath.row];
	MessageCell *cell			= [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
	cell.message				= message;
    
    return cell;
}


#pragma mark - 


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSString *text = textField.text;
	CoreController *cc	= [CoreController sharedController];

	if(text.length)
	{
		if([_chat sendText:text fromPeerID:cc.myPeerID])
		{
			textField.text = nil;
		}
	}
	
	return YES;
}


#pragma mark - Keyboard


- (void)keyboardWillShow:(NSNotification *)notification
{
	CGRect keyboardBoundsEnd			= [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	NSTimeInterval animationDuration	= [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	CGRect keyboardRect					= [_table convertRect:keyboardBoundsEnd fromView:nil];
	CGRect rect							= _footerView.frame;
	rect.origin.y						= CGRectGetHeight(_table.frame) - CGRectGetHeight(keyboardRect) - rect.size.height;
		
	CGFloat h							= keyboardRect.size.height + rect.size.height;
	
	[UIView animateWithDuration:animationDuration animations:^
	 {
		 _footerView.frame				= rect;
		 
		 _table.contentInset			= UIEdgeInsetsMake(64., 0., h, 0.);
		 _table.scrollIndicatorInsets	= UIEdgeInsetsMake(64., 0., h, 0.);
		 [_table flashScrollIndicators];
	 }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	NSTimeInterval animationDuration;
	[(notification.userInfo)[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	[UIView animateWithDuration:animationDuration animations:^
	 {
		 CGRect rect					= _footerView.frame;
		 rect.origin.y					= CGRectGetMaxX(self.view.frame) - rect.size.height;
		 _footerView.frame				= rect;
		 
		 _table.contentInset			= UIEdgeInsetsMake(64., 0., 0., 0.);
		 _table.scrollIndicatorInsets	= UIEdgeInsetsMake(64., 0., 0., 0.);
	 }];
}


@end
