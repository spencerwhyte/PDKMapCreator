//
//  PropertiesDelegate.m
//  x
//
//  Created by Spencer Whyte on 10-12-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PropertiesDelegate.h"


@implementation PropertiesDelegate

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor{
	if(control==nameTextField){
		[Environment change];
		NSLog(@"NAME");
	}else if(control==descriptionTextField){
		[Environment change];
		NSLog(@"Description");
	}
	return YES;
}


- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
	NSLog(@"ZOMG");
	return YES	;
}

@end
