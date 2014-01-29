//
//  ViewController.m
//  AirChat
//
//  Created by Marcello Mascia on 24/08/2013.
//  Copyright (c) 2013 Marcello Mascia. All rights reserved.
//

#import "Chat.h"
#import "ChatCell.h"
#import "ChatViewController.h"
#import "CoreController.h"
#import "User.h"
#import "ViewController.h"


static NSString * const kChatCellIdentifier										= @"ChatCell";


@interface ViewController () < MCNearbyServiceBrowserDelegate >


//@property (nonatomic, strong) NSMutableSet *									peers;
@property (nonatomic, strong) NSMutableSet *									users;
@property (nonatomic, readonly) NSArray *										sortedUsers;
@property (nonatomic, strong) MCNearbyServiceBrowser *							browser;


@end


@implementation ViewController


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *backButton				= [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"\n", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
	self.navigationItem.backBarButtonItem	= backButton;

	[_table registerNib:[UINib nibWithNibName:kChatCellIdentifier bundle:nil] forCellReuseIdentifier:kChatCellIdentifier];

	self.title					= NSLocalizedString(@"Nearby users", nil);
	
	self.users					= [NSMutableSet new];
	
	CoreController *cc			= [CoreController sharedController];
	NSNotificationCenter *nc	= [NSNotificationCenter defaultCenter];
	
	self.browser				= [[MCNearbyServiceBrowser alloc] initWithPeer:cc.myPeerID serviceType:kServiceType];
	self.browser.delegate		= self;
	[self.browser startBrowsingForPeers];
	
	[nc addObserver:self selector:@selector(chatDidStart:) name:kNotificationChatDidStart object:nil];
	[nc addObserver:self selector:@selector(chatStateConnected:) name:kNotificationChatStateConnected object:nil];
	[nc addObserver:self selector:@selector(chatStateNotConnected:) name:kNotificationChatStateNotConnected object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[_table deselectRowAtIndexPath:_table.indexPathForSelectedRow animated:animated];
}

#pragma mark - MCNearbyServiceBrowser delegate methods


- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
	NSLog(@"BROWSER DID NOT START BROWSING FOR PEERS: %@", error);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
	NSLog(@"BROWSER FOUND PEER: %@ WITH INFO: %@", peerID, info);

	User *user = [User userWithPeerID:peerID andIdentifier:info[kUserIDKey]];

	[self.users addObject:user];
	
	[_table reloadData];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
	NSLog(@"BROWSER LOST PEER: %@", peerID);

	NSPredicate *predicate	= [NSPredicate predicateWithFormat:@"peerID != %@", peerID];
	NSSet *cleanedSet		= [self.users filteredSetUsingPredicate:predicate];
	
	self.users				= [cleanedSet mutableCopy];
	
	[_table reloadData];
}


#pragma mark -


// This method gets called when the the remote peer accepts an invite
- (void)chatDidStart:(NSNotification *)notification
{
	Chat *chat = notification.object;
	
	[self showChat:chat];
}

- (void)showChat:(Chat *)chat
{
	ChatViewController *controller = [[ChatViewController alloc] initWithChat:chat];
	[self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -


- (void)requestChatApprovalToUser:(User *)user
{
	// Send an invitation request
	
	CoreController *cc					= [CoreController sharedController];
	MCSession *session					= [[MCSession alloc] initWithPeer:cc.myPeerID];
	Chat *chat							= [[Chat alloc] initWithSession:session];
	chat.connectedUser					= user;
	
	[cc.chats addObject:chat];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChatRequestStarted
														object:chat
													  userInfo:@{kNotificationPeerIDKey : user.peerID}];
	
	NSData *data						= [cc.myIdentifier dataUsingEncoding:NSUTF8StringEncoding];
	
	[self.browser invitePeer:user.peerID toSession:chat.session withContext:data timeout:20];
}

- (void)chatStateConnected:(NSNotification *)notification
{
	Chat *chat			= notification.object;
	
	[self showChat:chat];
}

- (void)chatStateNotConnected:(NSNotification *)notification
{
	CoreController *cc					= [CoreController sharedController];
	Chat *chat							= notification.object;
	
	[cc.chats removeObject:chat];
		
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Chat request", nil)
													message:NSLocalizedString(@"Request not accepted", nil)
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK", nil)
										  otherButtonTitles: nil];
	[alert show];
}


#pragma mark - Model


- (NSArray *)sortedUsers
{
	NSSortDescriptor *descriptor	= [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
	NSArray *results				= [[self.users allObjects] sortedArrayUsingDescriptors:@[descriptor]];
	
	return results;
}


#pragma mark - Table stuff


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	User *user					= self.sortedUsers[indexPath.row];

	ChatCell *cell				= [tableView dequeueReusableCellWithIdentifier:kChatCellIdentifier forIndexPath:indexPath];
	cell.user					= user;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CoreController *cc			= [CoreController sharedController];
	User *user					= self.sortedUsers[indexPath.row];
	Chat *chat					= [cc chatForPeerID:user.peerID];

	if(chat)
	{
		[self showChat:chat];
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		[self requestChatApprovalToUser:user];
	}
}


@end
