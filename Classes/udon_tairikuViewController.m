//
//  udon_tairikuViewController.m
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "udon_tairikuViewController.h"
#define TOOLBAR_TL_HIDED [NSArray arrayWithObjects:show_timeline_button,nil]
#define TOOLBAR_TL [NSArray arrayWithObjects:compose_button,toolbar_space,[[UIBarButtonItem alloc] initWithCustomView:timeline_switcher],toolbar_space,reload_button,nil]



@implementation udon_tairikuViewController

@synthesize twit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		setup_done = NO;
		clear_button_count = 0;
		post_identifier = @"";
		tl_identifier = @"";
		timeline_array = [NSArray array];
    }
    return self;
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {}

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
	post_identifier = [twit sendUpdate:tv.text];
}

- (void)requestSucceeded:(NSString *)i {
	if ([i isEqualToString:post_identifier]) {
		tv.text = @""; // Clear
		bar.title = NSLocalizedString(@"untitled",@""); // Reset title
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
	[self setSegmentedControl];
	[self loadSelectedTimeline];
	[toolbar setItems:TOOLBAR_TL animated:YES];
	[tv resignFirstResponder];
}

- (IBAction)hideTimeline: (id)sender {
	[toolbar setItems:TOOLBAR_TL_HIDED animated:YES];
	[tv	becomeFirstResponder];
}

- (IBAction)switchTimeline: (id)sender {
	NSLog(@"switchTimeline");
	[d setInteger:timeline_switcher.selectedSegmentIndex forKey:@"default_page"];
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
	NSLog(@"statusesReceived");
	tl_identifier = @"";
	timeline_array = [statuses retain];
	[timeline reloadData];
}

- (void)setSegmentedControl {
	timeline_switcher.selectedSegmentIndex = [d integerForKey:@"default_page"];
}

- (void)loadSelectedTimeline {
	if (![tl_identifier isEqualToString:@""]) {
		[twit closeConnection:tl_identifier];
	}
	tl_identifier = [twit getHomeTimelineSinceID:0 startingAtPage:0 count:20];
}

-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
	UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:@"cell_for_timeline"];
	NSDictionary *s = [[timeline_array objectAtIndex:index_path.row] retain];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:@"cell_for_timeline"] autorelease];
		return cell;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	UILabel *user_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 80, 30)];
	UILabel *text_label = [[UILabel alloc] initWithFrame:CGRectMake(90, 6, 230, 
											  [[self class] heightForContents:
											   [s objectForKey:@"text"]])];	
	
	user_label.baselineAdjustment = YES;
	text_label.numberOfLines = 0;
	NSDictionary *u = [[s objectForKey:@"user"] retain];
	user_label.text = [NSString stringWithFormat:@"%@",[u objectForKey:@"screen_name"]];
	user_label.font = [UIFont boldSystemFontOfSize:11.0];
	text_label.text = [s objectForKey:@"text"];
	 text_label.font = [UIFont systemFontOfSize:14.0];
	
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
	return [[self class] heightForContents:
			[[timeline_array objectAtIndex:index_path.row] objectForKey:@"text"]];
}

+ (CGFloat)heightForContents:(NSString *)contents {
	// http://tech.actindi.net/3477191382
    CGFloat result;
    CGSize  labelSize;
	
    result = 0.0;
    labelSize = [contents sizeWithFont:[UIFont systemFontOfSize:14.0]
                     constrainedToSize:CGSizeMake(230, 10000)
                         lineBreakMode:UILineBreakModeWordWrap];
    result += labelSize.height;
	result += 20;
	
    return result;
}


- (void)dealloc {
	[toolbar dealloc];
	[timeline dealloc];
	[timeline_switcher dealloc];
	[show_timeline_button dealloc];
	[compose_button dealloc];
	[reload_button dealloc];
	[toolbar_space dealloc];
	[twit dealloc];
	[oa_access_token dealloc];
	[d dealloc];
	[setup_view release];
	[done_button dealloc];
	[bar dealloc];
	[tv dealloc];
	[timeline_array dealloc];
	[post_identifier dealloc];
	[tl_identifier dealloc];
    [super dealloc];
}


@end
