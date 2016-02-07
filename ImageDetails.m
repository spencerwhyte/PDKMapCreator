//
//  ImageDetails.m
//
//  Created by Spencer Whyte on 10-12-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageDetails.h"

@implementation ImageDetails

-(IBAction)exportImage:(id)sender{
	

	NSSavePanel * savePanel = [NSSavePanel savePanel];
	NSArray * fileTypes = [NSArray arrayWithObject:@"imageData"];
	[savePanel setAllowedFileTypes:fileTypes];
	if([savePanel runModal]==NSFileHandlingPanelOKButton){
		NSURL* exportURL = [savePanel URL];
		NSMutableData *d = [[NSMutableData alloc] init];
		[ia write:d];
		[d writeToURL:exportURL atomically:YES];
	}
	
	
	
}

-(NSTextField*)getName{
	return nameTextField;
}

-(NSTextField*)getWidth{
	return widthLabel;
}

-(NSTextField*)getHeight{
	return heightLabel;	
}

-(void)export{
	
	
}


- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor{
	[Environment change];
	return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
	[Environment change];
	return YES;
}

-(void)setIA:(ImageAsset*)IA{
	ia = IA;
}

-(ImageAsset*)getIA{
	return ia;
}

@end
