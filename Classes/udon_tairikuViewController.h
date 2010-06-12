//
//  udon_tairikuViewController.h
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16. 
//

#import <UIKit/UIKit.h>
#import "SetupViewController.h"
#import "udon_tairikuAppDelegate.h"
#import "MGTwitterEngine.h"
#import "OAuthConsumer.h"
#import "Reachability.h"

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
	IBOutlet UIBarButtonItem *timeline_switcher;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UITableView *timeline;
	IBOutlet UIBarButtonItem *toolbar_space;
	SetupViewController *setup_view;
	int clear_button_count;
	BOOL setup_done;
	int tlid;
	NSArray *timeline_array;
	NSString *post_identifier;
	NSString *tl_identifier;
	NSString *in_reply_to_status_id;
	UIDeviceOrientation orientation;
	BOOL was_tv_firstresponder;
}

@property (retain, nonatomic) MGTwitterEngine *twit;

+ (CGFloat)heightForContents:(NSString *)contents;

- (void)initializeTwit; // Initialize MGTwitterEngine *twit
- (void)showSetupView; // show authorize dialog
- (void)clearHowToAuthorize:(NSTimer *)timer;
- (void)setSegmentedControl;
- (void)loadSelectedTimeline;

- (void)keyboardWillShow: (NSNotification *)n;
- (void)keyboardWillHide: (NSNotification *)n;
- (void)minimizeTableView: (BOOL)animate;
- (void)resizeTableView: (BOOL)animate;

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

- (UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path;
- (void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path;
@end

