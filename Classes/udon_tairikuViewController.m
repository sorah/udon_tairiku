//
//  udon_tairikuViewController.m
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "udon_tairikuViewController.h"

@implementation udon_tairikuViewController




// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

		setup_done = NO;

    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	/*[bar setRightBarButtonItem:nil animated:NO];*/
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (d == nil) 	d = [NSUserDefaults standardUserDefaults];
	if (([[d stringForKey:@"oauth_key"] isEqualToString:@""] ||
		 [[d stringForKey:@"oauth_secret"] isEqualToString:@""]) &&
		!setup_done) {
		setup_done = YES;
		[self showSetupView];
	} else {

		OAConsumer *c = [((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]).oaConsumer retain];
		if (oa_access_token == nil) {
			oa_access_token = [[OAToken alloc] initWithKey:[d objectForKey:@"oauth_key"]
													secret:[d objectForKey:@"oauth_secret"]];
		}
		if (twit == nil) {
			twit = [[MGTwitterEngine alloc] initWithDelegate:self];
			[twit setUsesSecureConnection:NO];
			[twit setConsumerKey:c.key secret:c.secret];
			[twit setAccessToken:oa_access_token];
			[c release];
		}
		NSLog(@"%@", [twit description]);
		[tv becomeFirstResponder];
	}
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)clearButtonIsPushed: (id)sender {
	if ([tv.text isEqualToString: @""]) {
		//Show setup view
		[self showSetupView];
	} else {
		tv.text = @"";
	}
}

- (IBAction)postButtonIsPushed: (id)sender {
	[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOnWorkingView];
	NSLog(@"%@",[twit sendUpdate:tv.text]);
}

- (void)requestSucceeded:(NSString *)i {
	tv.text = @""; // Clear
	bar.title = NSLocalizedString(@"untitled",@""); // Reset title
	[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
}

- (void)requestFailed:(NSString *)i withError:(NSError *) error {
	[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"post_error_title",@"")
												message:NSLocalizedString(@"post_error_msg",@"")
											   delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
	[a show];
	[a release];
}

- (void)showSetupView {
	[tv resignFirstResponder]; // Hide a keyboard;
	
	if (setup_view == nil) {
		setup_view = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
	}
	[self presentModalViewController:setup_view animated:YES];
}


- (void)textViewDidChange:(UITextView *)textView {
	// http://www.cocoalife.net/2010/03/post_546.html
	
	// if text length longer than 100, change title
	int remain = 140;
	remain = 140 - [[tv text] length];

	if (remain <= 40) {
		NSLog(@"Change title");
		bar.title = [NSString stringWithFormat:@"%d", remain];
	} else {
		bar.title = NSLocalizedString(@"untitled",@"");
	}

	
	// if text length longer than 140, hide button
	if ([[tv text] length] <= 140 && [[tv text] length] > 1) {
		[bar setRightBarButtonItem:done_button animated:YES];
	} else {
		[bar setRightBarButtonItem:nil animated:YES];
	}
}


- (void)dealloc {
	[twit dealloc];
	[oa_access_token dealloc];
	[d dealloc];
	[setup_view release];
	[done_button dealloc];
	[bar dealloc];
	[tv dealloc];
    [super dealloc];
}

@end
