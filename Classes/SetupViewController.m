//
//  SetupViewController.m
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//

#import "SetupViewController.h"
#import "udon_tairikuAppDelegate.h"


@implementation SetupViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		oa_consumer = [((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]).oaConsumer retain];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
	// http://d.hatena.ne.jp/tomute/20091120/1258780317
	static NSString *cell_identifier = @"cell_for_udon_setup";
	
	UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:cell_identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:cell_identifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *label;
		switch (UI_USER_INTERFACE_IDIOM()) {
			case UIUserInterfaceIdiomPhone:
				label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6, 100, 30)] autorelease];
				pin_field = [[[UITextField alloc] initWithFrame:CGRectMake(110, 10, 150, 30)] autorelease];
				break;
			case UIUserInterfaceIdiomPad:
				label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6, 150, 30)] autorelease];
				label.opaque = YES;
				pin_field = [[[UITextField alloc] initWithFrame:CGRectMake(160, 10, 200, 30)] autorelease];
				break;
		}
		
		label.font = [UIFont boldSystemFontOfSize:18];
		pin_field.delegate = self;
		pin_field.tag = [index_path row];
		pin_field.keyboardType = UIKeyboardTypeNumberPad;
		
		label.text = NSLocalizedString(@"pin",nil);
		
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:pin_field];
	}
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (IBAction)doneButtonIsPushed: (id)sender {
	if ([pin_field.text isEqualToString:@""]) {
		UIAlertView *a = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"done_button_err0_title",nil)
													message:NSLocalizedString(@"done_button_err0_message",nil)
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil] autorelease];
		[a show];
		return;
	} else {
		[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOnWorkingView];
		// Get access token and secret
		NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
		if ((NSString *)[d objectForKey:@"oauth_request_token_key"] == nil ||
			(NSString *)[d objectForKey:@"oauth_request_token_secret"] == nil) {
			UIAlertView *a = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"done_button_err1_title",nil)
														message:NSLocalizedString(@"done_button_err1_message",nil)
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil] autorelease];
			[a show];
			
			[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
			return;
		}
		
		OAToken *oa_request_token = [[OAToken alloc] initWithKey:[d objectForKey:@"oauth_request_token_key"]
														  secret:[d objectForKey:@"oauth_request_token_secret"]];
		NSURL *oa_url_access_token = [[NSURL URLWithString:@"http://api.twitter.com/oauth/access_token"] retain];
		

//		[oa_request_token setAttribute:@"oauth_verifier"
//								 value:[pin_field text]];
		
		OAMutableURLRequest *oa_req_access_token = [[OAMutableURLRequest alloc] initWithURL:oa_url_access_token 
																				   consumer:oa_consumer 
																					  token:oa_request_token
																					  realm:nil
																		  signatureProvider:nil];
		[oa_req_access_token setHTTPMethod:@"POST"];
		[oa_req_access_token setHTTPBody:
		 [[NSString stringWithFormat:@"oauth_verifier=%@", [pin_field text]]
			dataUsingEncoding:NSUTF8StringEncoding]];
		
		OADataFetcher *oa_fet_access_token = [[OADataFetcher alloc] init];
		
		[oa_fet_access_token fetchDataWithRequest:oa_req_access_token
										 delegate:self
								didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
								  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
		
		[oa_request_token release];
		[oa_url_access_token release];
		[oa_req_access_token release];

		//Continue to accessTokenTicket:didFinishWithData:
	}
}

-(void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

	if (ticket.didSucceed) {
		[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
		
		NSString *response_body = [[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding];
		OAToken *access_token = [[OAToken alloc] initWithHTTPResponseBody:response_body];
		NSUserDefaults *d = [[NSUserDefaults standardUserDefaults] retain];
		[d setObject:access_token.key forKey:@"oauth_key"];
		[d setObject:access_token.secret forKey:@"oauth_secret"];
		[d synchronize];
		
		
		[d release];
		[access_token release];
		[response_body release];
		
		[self dismissModalViewControllerAnimated:YES]; // Hide this dialog
	} else {
		[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
		[self showErrorDialog];
	}

}

-(void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[self showErrorDialog];
	[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];

}

-(void)showErrorDialog {
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
												message:@"Error occured"
											   delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
	[a show];
	[a release];
}


- (IBAction)authorizeButtonIsPushed: (id)sender {
	// Get authorize url
	[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOnWorkingView];
	NSURL *oa_url_get_request_token = [[NSURL URLWithString:@"http://api.twitter.com/oauth/request_token"] retain];
	 
	
	OAMutableURLRequest *oa_req_get_request_token = 
		[[OAMutableURLRequest alloc] initWithURL:oa_url_get_request_token
										consumer:oa_consumer
										   token:nil
										   realm:nil
							   signatureProvider:nil];
	[oa_req_get_request_token setHTTPMethod:@"POST"];
	
	OADataFetcher *oa_fet_get_request_token = [[OADataFetcher alloc] init];

	[oa_fet_get_request_token fetchDataWithRequest:oa_req_get_request_token
										  delegate:self
								 didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
								   didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	
	[oa_url_get_request_token release];
	[oa_req_get_request_token release];
	//[oa_fet_get_request_token release];
	//[oa_consumer release];
	
	// Continue to requestTokenTicket:didFinishWithData:
}

-(void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *response_body = [[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding];
		OAToken *request_token = [[OAToken alloc] initWithHTTPResponseBody:response_body];
		
		
		NSUserDefaults *d = [[NSUserDefaults standardUserDefaults] retain];
		[d setObject:request_token.key forKey:@"oauth_request_token_key"];
		[d setObject:request_token.secret forKey:@"oauth_request_token_secret"];
		[d synchronize];

		[d release];
		[response_body release];
		
		[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
		
		[[UIApplication sharedApplication] openURL:
		 [NSURL URLWithString: [NSString stringWithFormat:@"http://api.twitter.com/oauth/authorize?oauth_token=%@", request_token.key]]];
		
		[request_token release];
		

		
	} else {
		[self showErrorDialog];
	}

}

-(void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[self showErrorDialog];
}

- (void)dealloc {
	[oa_consumer release];
	[pin_field release];
	[done_button release];
	[super dealloc];
}


@end
