//
//  udon_tairikuViewController.m
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//

#import "udon_tairikuViewController.h"
#define TOOLBAR_TL_HIDED [NSArray arrayWithObjects:show_timeline_button,nil]
//[[UIBarButtonItem alloc] initWithCustomView:timeline_switcher]
#define TOOLBAR_TL [NSArray arrayWithObjects:compose_button,toolbar_space,timeline_switcher,toolbar_space,reload_button,nil]



@implementation udon_tairikuViewController

@synthesize twit;

// Core /////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		setup_done = NO;
		clear_button_count = 0;
		post_identifier = @"";
		tl_identifier = @"";
		timeline_array = [NSArray array];
		in_reply_to_status_id = @"";
		was_tv_firstresponder = YES;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[toolbar setItems:[NSArray arrayWithObjects:show_timeline_button,nil] animated:NO];

	
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
		UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"No internet connection"
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
		[a show];
		[a release];
	}
	
	
	
	if (d == nil) 	d = [NSUserDefaults standardUserDefaults];
	if (([[d stringForKey:@"oauth_key"] isEqualToString:@""] ||
		 [[d stringForKey:@"oauth_secret"] isEqualToString:@""]) &&
		!setup_done) {
		setup_done = YES;
		[self showSetupView];
	} else {
		if (animated) {
			tv.editable = NO;
			if (IS_IPAD) {
				tv.text = NSLocalizedString(@"how_to_reauthorize_ipad",@"");
			} else {
				tv.text = NSLocalizedString(@"how_to_reauthorize",@"");
			}
			
			[NSTimer scheduledTimerWithTimeInterval:2.5
											 target:self
										   selector:@selector(clearHowToAuthorize:)
										   userInfo:nil
											repeats:NO];
		} else {
			show_timeline_button.image = [UIImage imageNamed:@"list.png"];
			[tv becomeFirstResponder];
		}
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[bar setRightBarButtonItem:nil animated:NO];
	if (IS_IPAD) {
		timeline.hidden = YES;
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification object:nil];
//		[self minimizeTableView:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIKeyboardWillShowNotification
													  object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIKeyboardWillHideNotification
													  object:nil];
	}
}

// (iPad only) Keyboard & Timeline /////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return IS_IPAD; // Allow auto rotate if iPad. But don't allow it if not iPad.
}

- (void)keyboardWillShow: (NSNotification *)n {
	[self minimizeTableView:YES];
	[self hideTimeline:nil];
	if (!orientation) {
		orientation = [UIDevice currentDevice].orientation;
	}
}

- (void)keyboardWillHide: (NSNotification *)n {
	[tv resignFirstResponder];
	[self resizeTableView:YES];
	[self showTimeline:nil];
}

- (void)minimizeTableView: (BOOL)animate {
	NSLog(@"minimizeTableView");
	CGRect s = self.view.frame;
	CGFloat width, height; 
	switch (orientation) {
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			NSLog(@"landscape");
			width = s.size.height;
			height = s.size.width;
			break;
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
			NSLog(@"portlait");
			width = s.size.width;
			height = s.size.height;
			break;
		default:
			NSLog(@"default");
			/*if (s.size.width == 1004) {
				width = s.size.width;
				height = s.size.height;
			} else {
				width = s.size.height;
				height = s.size.width;
			}*/
			timeline.hidden = YES; 
			return;
			break;
	} 

	
	if (animate) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:@"minimize_table_view_udon_tairiku" context:context];
		[UIView setAnimationDuration:0.3];
	}

	timeline.frame = CGRectMake(0,height, width,0);
	toolbar.frame = CGRectMake(0,height-46, width,46);
	tv.frame = CGRectMake(0,46, width,height-46);
	if (animate) {
		[UIView commitAnimations];
	}
	[tv becomeFirstResponder];
}

- (void)resizeTableView: (BOOL)animate {
	NSLog(@"resizeTableView");
	// h:44px (toolbar)
	// if 600
	CGRect s = self.view.frame;
	CGFloat width, height; 
	switch (orientation) {
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			NSLog(@"landscape");
			width = s.size.height;
			height = s.size.width;
			break;
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
			NSLog(@"portlait");
			width = s.size.width;
			height = s.size.height;
			break;
		default:
			width = s.size.width;
			height = s.size.height;
			break;
	}
	
	if (animate) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:@"resize_table_view_udon_tairiku" context:context];
		[UIView setAnimationDuration:0.3];
	}
	timeline.hidden = NO;
	tv.frame = CGRectMake(0,46, width,height-554);
	toolbar.frame = CGRectMake(0,height-600, width,46);
	timeline.frame = CGRectMake(0,height-554, width,46+46+554);
	if (animate) {
		[UIView commitAnimations];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	orientation = toInterfaceOrientation;
	was_tv_firstresponder = [tv isFirstResponder];
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	if(was_tv_firstresponder) {
		[self minimizeTableView:NO];
	} else {
		[self resizeTableView:NO];
	}
}

// Util /////

- (void)showSetupView {
	[tv resignFirstResponder]; // Hide a keyboard;
	
	if (setup_view == nil) {
		setup_view = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
	}
	[self presentModalViewController:setup_view animated:YES];
}

- (void)initializeTwit {
	if (oa_access_token == nil) {
		oa_access_token = [[OAToken alloc] initWithKey:[d objectForKey:@"oauth_key"]
												secret:[d objectForKey:@"oauth_secret"]];
	}
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


- (void)clearHowToAuthorize:(NSTimer *)timer {
	tv.text = @"";
	tv.editable = YES;
	show_timeline_button.image = [UIImage imageNamed:@"list.png"];
	[tv becomeFirstResponder];
}

// Actions /////

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
		in_reply_to_status_id = @"";
		tv.text = @"";
	}
}

- (IBAction)postButtonIsPushed: (id)sender {
	[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOnWorkingView];
	[self initializeTwit];
	if ([in_reply_to_status_id isEqualToString:@""]) {
		post_identifier = [[twit sendUpdate:tv.text] retain];
	} else {
		post_identifier = [[twit sendUpdate:tv.text inReplyTo:[in_reply_to_status_id longLongValue]] retain];
	}
}

// MGTwitter- Delegates /////

- (void)requestSucceeded:(NSString *)i {
	if ([i isEqualToString:post_identifier]) {
		tv.text = @""; // Clear
		in_reply_to_status_id = @"";
		bar.title = NSLocalizedString(@"untitled",@""); // Reset title
		[bar setRightBarButtonItem:nil animated:YES]; // Clear button
		[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
	}
}

- (void)requestFailed:(NSString *)i withError:(NSError *) error {
	if ([i isEqualToString:post_identifier]) {
		[((udon_tairikuAppDelegate *)[[UIApplication sharedApplication] delegate]) turnOffWorkingView];
	}
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"post_error_title",@"")
												message:NSLocalizedString(@"post_error_msg",@"")
											   delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
	[a show];
	[a release];
}

// UITextView Delegates /////

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	[toolbar setItems:TOOLBAR_TL_HIDED animated:YES];
//	if (IS_IPAD) {
//		[self minimizeTableView:YES];
//	}
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

// Timeline Actions /////

- (IBAction)showTimeline: (id)sender {
	[self initializeTwit];
	[self setSegmentedControl];
	[self loadSelectedTimeline];
	if (IS_IPAD) {
		[self resizeTableView:YES];
	}
	[toolbar setItems:TOOLBAR_TL animated:YES];
	[tv resignFirstResponder];
}

- (IBAction)hideTimeline: (id)sender {
	[toolbar setItems:TOOLBAR_TL_HIDED animated:YES];
	if (IS_IPAD) {
		[self minimizeTableView:YES];
	}
	[tv	becomeFirstResponder];
}

- (IBAction)switchTimeline: (id)sender {
	NSLog(@"switchTimeline");
	[d setInteger:((UISegmentedControl *)timeline_switcher.customView).selectedSegmentIndex forKey:@"default_page"];
	[self loadSelectedTimeline];
}

- (IBAction)reloadTimeline: (id)sender {
	if ([tl_identifier isEqualToString:@""]) {
		NSLog(@"reloadTimeline");
		tl_identifier = @"";
		[self loadSelectedTimeline];
	}
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)i {
	if ([i isEqualToString:tl_identifier]) {
		NSLog(@"statusesReceived");
		tl_identifier = @"";
		[timeline_array release];
		timeline_array = [statuses retain];
		tlid++;
		[timeline reloadData];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		tl_identifier = @"";
	}
}

- (void)setSegmentedControl {
	((UISegmentedControl *)timeline_switcher.customView).selectedSegmentIndex = [d integerForKey:@"default_page"];
}

- (void)loadSelectedTimeline {
	if (![tl_identifier isEqualToString:@""]) {
		[twit closeConnection:tl_identifier];
	}
	switch (((UISegmentedControl *)timeline_switcher.customView).selectedSegmentIndex) {
		case 0:
			tl_identifier = [[twit getHomeTimelineSinceID:0 startingAtPage:0 count:20] retain];
			break;
		case 1:
			tl_identifier = [[twit getRepliesSinceID:0 startingAtPage:0 count:20] retain];
			break;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
	UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:
							 [NSString stringWithFormat:@"cell_for_timeline%d%d", tlid, index_path.row]];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:[NSString stringWithFormat:
														@"cell_for_timeline%d%d", tlid, index_path.row]] autorelease];
	} else {
		return cell;
	}
	NSDictionary *s = [[timeline_array objectAtIndex:index_path.row] retain];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	UILabel *user_label, *text_label;
	if (IS_IPAD) {
		user_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 150, 30)];
		text_label = [[UILabel alloc] initWithFrame:CGRectMake(160, 3, 600, 
															   [self heightForContents:
																[s objectForKey:@"text"]])];	
		
	} else {
		user_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 80, 30)];
		text_label = [[UILabel alloc] initWithFrame:CGRectMake(90, 3, 220, 
																		[self heightForContents:
																			[s objectForKey:@"text"]])];	
	}
	
	user_label.baselineAdjustment = YES;
	text_label.numberOfLines = 0;
	NSDictionary *u = [[s objectForKey:@"user"] retain];
	user_label.text = [NSString stringWithFormat:@"%@",[u objectForKey:@"screen_name"]];
	text_label.text = [s objectForKey:@"text"];
	
	if (IS_IPAD) {
		user_label.font = [UIFont boldSystemFontOfSize:13.0];
		text_label.font = [UIFont systemFontOfSize:15.0];
		
	} else {
		user_label.font = [UIFont boldSystemFontOfSize:11.0];
		text_label.font = [UIFont systemFontOfSize:13.0];
	}
	
	
	
	[cell.contentView addSubview:user_label];
	[cell.contentView addSubview:text_label];
	
	[user_label release];
	[text_label release];
	[u release];
	[s release];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [timeline_array count];
}

- (CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path {
	return [self heightForContents:
			[[timeline_array objectAtIndex:index_path.row] objectForKey:@"text"]];
}

- (void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
	[table_view deselectRowAtIndexPath:index_path animated:YES];
	in_reply_to_status_id = [[[timeline_array objectAtIndex:index_path.row] objectForKey:@"id"] retain];
	tv.text = [NSString stringWithFormat:@"@%@ ",
										 [[[timeline_array objectAtIndex:index_path.row] objectForKey:@"user"]
										  objectForKey:@"screen_name"]];
	[tv becomeFirstResponder];
}

- (CGFloat)heightForContents:(NSString *)contents {
	// http://tech.actindi.net/3477191382
    CGFloat result;
    CGSize  labelSize;
	
	CGRect s = self.view.frame;
	CGFloat width;
	if (IS_IPAD) {
		switch (orientation) {
			case UIDeviceOrientationLandscapeLeft:
			case UIDeviceOrientationLandscapeRight:
				width = s.size.height-20;
				break;
			case UIDeviceOrientationPortrait:
			case UIDeviceOrientationPortraitUpsideDown:
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
				width = s.size.width-20;
				break;
			default:
				width = 220;
				break;
		}
	} else {
		width = 220;
	}
	
    result = 0.0;
    labelSize = [contents sizeWithFont:[UIFont systemFontOfSize:13.0]
                     constrainedToSize:CGSizeMake(width, 10000)
                         lineBreakMode:UILineBreakModeWordWrap];
    result += labelSize.height;
	result += 12;
	
    return result;
}

// Exit /////

- (void)dealloc {
	[toolbar release];
	[timeline release];
	[timeline_switcher release];
	[show_timeline_button release];
	[compose_button release];
	[reload_button release];
	[toolbar_space release];
	[twit release];
	[oa_access_token release];
	[d release];
	[setup_view release];
	[done_button release];
	[bar release];
	[tv release];
	[timeline_array release];
	[post_identifier release];
	[tl_identifier release];
	[in_reply_to_status_id release];
    [super dealloc];
}


@end
