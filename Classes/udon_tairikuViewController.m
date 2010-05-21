//
//  udon_tairikuViewController.m
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "udon_tairikuViewController.h"
#define TOOLBAR_TL_HIDED [NSArray arrayWithObjects:show_timeline_button,nil]
#define TOOLBAR_REFRESH_BUTTON [NSArray arrayWithObjects:compose_button,toolbar_space,[[UIBarButtonItem alloc] initWithCustomView:timeline_switcher],toolbar_space,reload_button,nil]
#define TOOLBAR_STOP_BUTTON [NSArray arrayWithObjects:compose_button,toolbar_space,[[UIBarButtonItem alloc] initWithCustomView:timeline_switcher],toolbar_space,stop_button,nil]


@implementation udon_tairikuViewController

@synthesize twit;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		setup_done = NO;

		clear_button_count = 0;
		
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

	[bar setRightBarButtonItem:nil animated:NO];
}

- (void)initializeTwit {
	if (twit == nil) {
		OAConsumer *c = [((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]).oaConsumer retain];
		twit = [[MGTwitterEngine alloc] initWithDelegate:self];
		[twit setUsesSecureConnection:NO];
		[twit setConsumerKey:c.key secret:c.secret];
		[twit setAccessToken:oa_access_token];
		[c release];
		NSLog(@"twit is now initialized.");
	}	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	/*
	toolbar_items_timeline_hided = [NSArray arrayWithObjects:show_timeline_button,nil];
	toolbar_items_refresh_button = [NSArray arrayWithObjects:compose_button,
									toolbar_space,
									[[UIBarButtonItem alloc] initWithCustomView:timeline_switcher],
									toolbar_space,
									reload_button,nil];
	toolbar_items_stop_button = [NSArray arrayWithObjects:compose_button,
								 toolbar_space,
								 [[UIBarButtonItem alloc] initWithCustomView:timeline_switcher],
								 toolbar_space,
								 stop_button,nil];
	 */
	 [toolbar setItems:[NSArray arrayWithObjects:show_timeline_button,nil] animated:NO];
	
	if (d == nil) 	d = [NSUserDefaults standardUserDefaults];
	if (([[d stringForKey:@"oauth_key"] isEqualToString:@""] ||
		 [[d stringForKey:@"oauth_secret"] isEqualToString:@""]) &&
		!setup_done) {
		setup_done = YES;
		[self showSetupView];
	} else {
		if (oa_access_token == nil) {
			oa_access_token = [[OAToken alloc] initWithKey:[d objectForKey:@"oauth_key"]
													secret:[d objectForKey:@"oauth_secret"]];
		}
		if (animated) {
			tv.editable = NO;
			tv.text = NSLocalizedString(@"how_to_reauthorize",@"");

			[NSTimer scheduledTimerWithTimeInterval:2.5
											target:self
										   selector:@selector(clearHowToAuthorize:)
										   userInfo:nil
											repeats:NO];
		} else {
			[tv becomeFirstResponder];
		}
	}
}

- (void)clearHowToAuthorize:(NSTimer *)timer {
	tv.text = @"";
	tv.editable = YES;
	[tv becomeFirstResponder];
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
	if ([tv.text isEqualToString:@""]) {
		clear_button_count++;
		if (clear_button_count >= 5) {
			UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Reauthorize is moved"
														message:@"Turn on \"Reauthorize\" in Settings.app \"Udon Tairiku\""
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
			[a show];
			[a release];
		}
	} else {
		clear_button_count = 0;
		tv.text = @"";
	}
}

- (IBAction)postButtonIsPushed: (id)sender {
	[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOnWorkingView];
	[self initializeTwit];
	[twit sendUpdate:tv.text];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	[toolbar setItems:TOOLBAR_TL_HIDED animated:YES];
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
	// http://www.cocoalife.net/2010/03/post_546.html
	// if text length longer than 100, change title
	int remain = 140;
	remain = 140 - [[tv text] length];

	if (remain <= 40) {
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

- (IBAction)switchToMention: (id)sender {}
- (IBAction)switchToTimeline: (id)sender {}

- (IBAction)showTimeline: (id)sender {
	[self initializeTwit];
	[toolbar setItems:TOOLBAR_REFRESH_BUTTON animated:YES];
	[tv resignFirstResponder];
}

- (IBAction)hideTimeline: (id)sender {
	[toolbar setItems:TOOLBAR_TL_HIDED animated:YES];
	[tv	becomeFirstResponder];
}

- (IBAction)switchTimeline: (id)sender {}
- (IBAction)reloadTimeline: (id)sender {}
- (IBAction)stopReloadTimeline: (id)sender {}

-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
	return [UITableViewCell alloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (void)dealloc {
	[toolbar dealloc];
	[timeline dealloc];
	[timeline_switcher dealloc];
	[show_timeline_button dealloc];
	[compose_button dealloc];
	[reload_button dealloc];
	[stop_button dealloc];
	[toolbar_space dealloc];
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
