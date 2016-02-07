//
//  ImageDetails.h
//
//  Created by Spencer Whyte on 10-12-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageAsset.h"
#import "Environment.h"
 
@interface ImageDetails : NSView <NSControlTextEditingDelegate>{
	IBOutlet NSTextField *nameTextField;
	IBOutlet NSTextField *widthLabel;
	IBOutlet NSTextField *heightLabel;
	ImageAsset *ia;
}
-(IBAction)exportImage:(id)sender;
-(NSTextField*)getName;
-(NSTextField*)getWidth;
-(NSTextField*)getHeight;
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor;
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;
-(void)setIA:(ImageAsset*)IA;
-(ImageAsset*)getIA;

@end
