//
//  egDiscoverViewController.m
//  slideviewTest
//
/*
        Copyright 2013 Handpoint Ltd.
 
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
     
            http://www.apache.org/licenses/LICENSE-2.0
     
        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 */

#import "hpDiscoverViewController.h"

@interface hpDiscoverViewController ()

@end

@implementation hpDiscoverViewController
{

}
@synthesize deviceTable;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [sharedHeftService resetDevices]; // Clean out device list
    sharedHeftService.automaticConnectToReader = NO;
    [sharedHeftService startDiscoveryWithActivitiMonitor:NO];
    // Recieve notification from hpHeftService when new devices found
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshDeviceTableView:)
                                                 name:@"refreshDevicesTableView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readerConnected:)
                                                 name:@"readerConnected"
                                               object:nil];

    super.navigationItem.title = Localize(@"Discover");
    super.navigationItem.backBarButtonItem.title = Localize(@"Back");

  
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView:");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSLog(@"numberOfRowsInSection:");
    return [sharedHeftService.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"discoverCell";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
	}
	
	// Set up the cell.
	cell.textLabel.text = [[sharedHeftService.devices objectAtIndex:indexPath.row] name];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Declare the shared secret in hex numbers.
    selectedDevice = [sharedHeftService.devices objectAtIndex:indexPath.row];
    [sharedHeftService clientForDevice:selectedDevice sharedSecret:[sharedHeftService readSharedSecretFromFile] delegate:sharedHeftService];
}

- (void)refreshDeviceTableView:(NSNotification *)notif
{
    [deviceTable reloadData];
}
- (void)readerConnected:(NSNotification *)notif
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSData* sharedSecretData = [[[alertView textFieldAtIndex:0] text] dataUsingEncoding:NSUTF8StringEncoding];
        [sharedHeftService clientForDevice:selectedDevice sharedSecret:sharedSecretData delegate:sharedHeftService];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


@end
