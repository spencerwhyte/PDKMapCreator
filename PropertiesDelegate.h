//
//  PropertiesDelegate.h
//  x
//
//  Created by Spencer Whyte on 10-12-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Environment.h"

@interface PropertiesDelegate : NSObject<NSControlTextEditingDelegate> {
	IBOutlet NSTextField *nameTextField;
	IBOutlet NSTextField *descriptionTextField;
}
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor;
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;
@end
