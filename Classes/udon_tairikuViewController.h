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

@interface udon_tairikuViewController : UIViewController <UITextViewDelegate> {
	IBOutlet UITextView *tv;
	NSUserDefaults *d;
	SetupViewController *setup_view;
	IBOutlet UIBarButtonItem *done_button;
	IBOutlet UINavigationItem *bar;
	MGTwitterEngine *twit;
	BOOL setup_done;
	OAToken *oa_access_token;
	IBOutlet UIBarButtonItem *show_timeline_button;
	IBOutlet UIBarButtonItem *compose_button;
	IBOutlet UIBarButtonItem *reload_button;
	IBOutlet UIBarButtonItem *stop_button;
	IBOutlet UISegmentedControl *timeline_switcher;
}

@property (retain, nonatomic) MGTwitterEngine *twit;

- (IBAction)clearButtonIsPushed: (id)sender;
- (void)showSetupView;
- (IBAction)postButtonIsPushed: (id)sender;
- (void)textViewDidChange:(UITextView *)textView;
- (void)requestSucceeded:(NSString *)i;
- (void)requestFailed:(NSString *)i withError:(NSError *) error;
- (void)clearHowToAuthorize:(NSTimer *)timer;
- (void)initializeTwit;
- (IBAction)switchTimeline: (id)sender;
- (IBAction)showTimeline: (id)sender;
- (IBAction)hideTimeline: (id)sender;
- (IBAction)reloadTimeline: (id)sender;
- (IBAction)stopReloadTimeline: (id)sender;

@end

