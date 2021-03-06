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

-(void) initializeGrayView {
	// Initialize gray_view -- http://iappdev.blog130.fc2.com/blog-entry-2.html
	if (gray_view == nil) {
		if (([[UIDevice currentDevice].model isEqualToString:@"iPad"] \
			|| [[UIDevice currentDevice].model isEqualToString:@"iPad Simulator"])) {
			gray_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
			activity_indicator = [[UIActivityIndicatorView alloc]
								initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			[activity_indicator setCenter:CGPointMake(384, 512)];
		} else {
			gray_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
			activity_indicator = [[UIActivityIndicatorView alloc]
								initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			[activity_indicator setCenter:CGPointMake(160, 240)];
		}

		[gray_view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
		[gray_view addSubview:activity_indicator];
	}
}


-(void) turnOnWorkingView {
	[self initializeGrayView];
	window.userInteractionEnabled=NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[window addSubview:gray_view];
	[activity_indicator startAnimating];
}

-(void) turnOffWorkingView {
	[self initializeGrayView];
	window.userInteractionEnabled=YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

