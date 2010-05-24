//
//  udon_tairikuAppDelegate.h
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//

#import <UIKit/UIKit.h>

#import "OAConsumer.h"

@class udon_tairikuViewController;

@interface udon_tairikuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    udon_tairikuViewController *viewController;
	OAConsumer *oaConsumer;
	
	UIView *gray_view;
	UIActivityIndicatorView *activity_indicator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet udon_tairikuViewController *viewController;
@property (nonatomic, retain) OAConsumer *oaConsumer;

-(void) turnOnWorkingView;
-(void) turnOffWorkingView;

@end

