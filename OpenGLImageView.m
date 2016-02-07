//
//  OpenGLImageView.m
//  x
//
//  Created by Spencer Whyte on 10-12-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OpenGLImageView.h"

@implementation OpenGLImageView
- (void)setImage:(NSImage *)image{
	[Environment change];
	Map * m = [Environment getMap];
	if(m!=nil){
		[m swapImage:image];
	}
	[super setImage:image];	
}

@end
