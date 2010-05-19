//
//  SetupViewController.h
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"


@interface SetupViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate> {
	IBOutlet UIBarButtonItem *done_button;
	OAConsumer *oa_consumer;
	UITextField *pin_field;

}

-(IBAction) doneButtonIsPushed: (id)sender;
-(IBAction) authorizeButtonIsPushed: (id)sender;
-(void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
-(void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
-(void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
-(void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
-(void)showErrorDialog;
@end
