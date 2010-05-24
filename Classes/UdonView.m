//
//  UdonView.m
//  udon_tairiku
//
//  Created by Sora Harakami on 2010/5/16.
//

#import "UdonView.h"


@implementation UdonView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[tv release];
    [super dealloc];
}


@end
