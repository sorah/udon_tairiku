//
//  udon_tairikuAppDelegate.m
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//

#import "udon_tairikuAppDelegate.h"
#import "udon_tairikuViewController.h"




@implementation udon_tairikuAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize oaConsumer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	oaConsumer = 
		[[OAConsumer alloc] initWithKey:@"kYIlJwdlzvTBDKsxvxrhRQ" secret:@"7u4hr2w23JGfFvk9S14mgJojnlPm9jwDQZ4g4Kgepc"];

	// Initialize gray_view -- http://iappdev.blog130.fc2.com/blog-entry-2.html
	gray_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	[gray_view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
	activity_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activity_indicator setCenter:CGPointMake(160, 230)];
	[gray_view addSubview:activity_indicator];
	
	// Set UserDefault
	NSUserDefaults *d = [[NSUserDefaults standardUserDefaults] retain];
	
	if ([d boolForKey:@"reauthorize_pref"]) {
		[d setObject:@"" forKey:@"oauth_key"];
		[d setObject:@"" forKey:@"oauth_secret"];
		[d setBool:NO forKey:@"reauthorize_pref"];
	}
	
	if ([d stringForKey:@"oauth_key"] == nil) {
		[d setObject:@"" forKey:@"oauth_key"];
	}
	if ([d stringForKey:@"oauth_secret"] == nil) {
		[d setObject:@"" forKey:@"oauth_secret"];
	}
	if ((NSInteger *)[d integerForKey:@"default_page"] == nil) {
		[d setInteger:0 forKey:@"default_page"];
	}
	
	
	[d synchronize];
	[d release];
    
	// Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}

-(void) turnOnWorkingView {
	window.userInteractionEnabled=NO;
	[window addSubview:gray_view];
	[activity_indicator startAnimating];
}

-(void) turnOffWorkingView {
	window.userInteractionEnabled=YES;
	[activity_indicator stopAnimating];
	[gray_view removeFromSuperview];
}

- (void)dealloc {
	[activity_indicator release];
	[gray_view release];
	[oaConsumer release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end

