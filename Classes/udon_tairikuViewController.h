//
//  udon_tairikuViewController.h
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupViewController.h"
#import "udon_tairikuAppDelegate.h"
#import "MGTwitterEngine.h"
#import "OAuthConsumer.h"

@interface udon_tairikuViewController : UIViewController <UITextViewDelegate, UITableViewDataSource> {
	NSUserDefaults *d;
	MGTwitterEngine *twit;
	OAToken *oa_access_token;
	IBOutlet UITextView *tv;
	IBOutlet UIBarButtonItem *done_button;
	IBOutlet UINavigationItem *bar;
	IBOutlet UIBarButtonItem *show_timeline_button;
	IBOutlet UIBarButtonItem *compose_button;
	IBOutlet UIBarButtonItem *reload_button;
	IBOutlet UISegmentedControl *timeline_switcher;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UITableView *timeline;
	IBOutlet UIBarButtonItem *toolbar_space;
	SetupViewController *setup_view;
	int clear_button_count;
	BOOL setup_done;
	NSArray *timeline_array;
	NSString *post_identifier;
	NSString *tl_identifier;
}

@property (retain, nonatomic) MGTwitterEngine *twit;

- (void)initializeTwit; // Initialize MGTwitterEngine *twit
- (void)showSetupView; // show authorize dialog
- (void)clearHowToAuthorize:(NSTimer *)timer;

- (void)textViewDidChange:(UITextView *)textView; // Count text size in TextView
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;

- (void)requestSucceeded:(NSString *)i;
- (void)requestFailed:(NSString *)i withError:(NSError *) error;
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)i;

- (IBAction)clearButtonIsPushed: (id)sender;
- (IBAction)postButtonIsPushed: (id)sender;
- (IBAction)showTimeline: (id)sender;
- (IBAction)hideTimeline: (id)sender;
- (IBAction)switchTimeline: (id)sender;
- (IBAction)reloadTimeline: (id)sender;



@end

