
#import "Controller.h"

@interface Controller (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end

@implementation Controller

- (void) awakeFromNib
{  

	[ NSApp setDelegate:self ];   // We want delegate notifications
	renderTimer = nil;
	[ glWindow makeFirstResponder:self ];
	glView = [ [ View alloc ] initWithFrame:[ glWindow frame ]
								  colorBits:32 depthBits:32 ];
	if( glView != nil )
	{
		
		[ glWindow setContentView:glView ];
		[ glWindow makeKeyAndOrderFront:self ];
		
		//glWindow
		[ self setupRenderTimer ];
	}
	else
		[ self createFailed ];
	

	[Environment setViewController:self];
	[[NSApplication sharedApplication] setDelegate:self];

//	[assets setDelegate:self];
}

-(id)window{
	return glWindow;	
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)updateDescriptiveImage:(NSImage*)image{

	[descriptiveImageView setImage:image];
	
}

-(NSTextField*)getNameTextField{
	return nameTextField;
}
-(NSTextField*)getDescriptionTextField{
	return descriptionTextField;
}

/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = 0.005;
	
	renderTimer = [ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( updateGLView: )
													userInfo:nil repeats:YES ] retain ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
}


/*
 * Called by the rendering timer.
 */
- (void) updateGLView:(NSTimer *)timer
{
	if( glView != nil )
		[ glView drawRect:[ glView frame ] ];
}  


/*
 * Handle key presses
 */
- (void) keyDown:(NSEvent *)theEvent
{
	NSLog(@"aa");
	unichar unicodeKey;
	
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	switch( unicodeKey )
	{
		case 'o':
			NSLog(@"o");
			break;
	}
}


- (void)mouseDown:(NSEvent *)theEvent{
	
		NSLog(@"aa");
}



-(IBAction)createNewMap:(id)action{
	if([Environment newMap]){
		[assets reloadData];
		[assetsDrawer open];
		[detailsDrawer open];
	}else{
		[assetsDrawer close];
		[detailsDrawer close];
	}
}

-(IBAction) openMap:(id)sender{
	if([Environment openMap]){
		[assetsDrawer open];
		[detailsDrawer open];
	}else{
		[assetsDrawer close];
		[detailsDrawer close];
	}
}

-(IBAction) saveMap:(id)sender{
	[Environment saveMap];
}

-(IBAction) importAsset:(id)sender{
	[Environment importAsset];	
	[assets reloadData];
}

-(BOOL)windowShouldClose:(id)sender{
	if([Environment saveCurrentMap]){
		return YES;
	}else{
		return NO;	
	}
}

-(BOOL)validateMenuItem:(NSMenuItem *)item{
	NSLog(@"%@", [item title] );
	if([[item title] isEqualToString:@"Save"]){
		[ glWindow makeKeyAndOrderFront:self ];
		if([Environment hasUnsavedChanges]){
			return YES;
		}
		return NO;
	}
	if([[item title] isEqualToString:@"Asset"]){
		if([Environment mapIsOpen]){
		  	return YES;
		}
		return NO;
	}
	if([[item title] isEqualToString:@"Assets"]){
		if([Environment mapIsOpen]){
		  	return YES;
		}
		return NO;
	}
	if([[item title] isEqualToString:@"Details"]){
		if([Environment mapIsOpen]){
		  	return YES;
		}
		return NO;
	}
	
	if([[item title] isEqualToString:@"Properties"]){
		
		if([Environment mapIsOpen]){
			
		  	return YES;
		}
		return NO;
	}
	if([[item title] isEqualToString:@"Vertices"]){
		if([Environment mapIsOpen]){
		  	return YES;
		}
		return NO;
	}
	if([[item title] isEqualToString:@"Edges"]){
		if([Environment mapIsOpen]){
		  	return YES;
		}
		return NO;
	}
	
	if([[item title] isEqualToString:@"Faces"]){
		if([Environment mapIsOpen]){
		  	return YES;
		}
		return NO;
	}
	return YES;	
}

-(IBAction)doNothing:(id)sender{

	
}
-(IBAction)toggleProperties:(id)sender{

		[propertiesPanel makeKeyAndOrderFront:sender];

	

}

-(IBAction)toggleDetails:(id)sender{
	[detailsDrawer toggle:sender];

}
-(IBAction)toggleAssets:(id)sender{
	[assetsDrawer toggle:sender];
	

}

/*
 * Called if we fail to create a valid OpenGL view
 */
- (void) createFailed
{
	NSWindow *infoWindow;
	
	infoWindow = NSGetCriticalAlertPanel( @"Initialization failed",
                                         @"Failed to initialize OpenGL",
                                         @"OK", nil, nil );
	[ NSApp runModalForWindow:infoWindow ];
	[ infoWindow close ];
	[ NSApp terminate:self ];
}


/* 
 * Cleanup
 */
- (void) dealloc
{
	[ glWindow release ]; 
	[ glView release ];
	if( renderTimer != nil && [ renderTimer isValid ] )
		[ renderTimer invalidate ];
}



- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	   NSLog(@"aaa");	
	if([Environment mapIsOpen]){
		if(item == nil){
			return [[Environment getAllAssets]count];
		}
		if([item isKindOfClass:[NSMutableArray class]]){
			return [item count];
		}else if([item isKindOfClass:[ModelAsset class]]){
		    return [[(ModelAsset*)item getParts] count];
		}
	}
    return 0;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if([Environment mapIsOpen]){
		if(item == nil){
			YES;
		}
		if([item isKindOfClass:[NSMutableArray class]]){
			if([item count]>0){
				return YES;
			}
			NO;
		}else if([item isKindOfClass:[ModelAsset class]]){
			return YES; 
		}
	}
	return NO;
}



- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if([Environment mapIsOpen]){
		if(item == nil){
			return [[Environment getAllAssets] objectAtIndex:index];	
		}else if([item isKindOfClass:[NSArray class]]){
			return [item objectAtIndex:index];	
		}else{
			return [item getPart:index];
		}
	}
	NSLog(@"Returning fuck");
	return @"FUCK";
}


-(void)makeDefaultMesh:(id)sender{
	NSString  *a;
	a= [[sender title] substringWithRange:NSMakeRange(6, [[sender title] length] - 24)];
	NSLog(@"%@",a);
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item{
	
	NSLog(@"%@", [item description]);

	if([item isKindOfClass:[ModelAsset class]]){
		NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
		NSString * temp = [[NSString alloc] initWithFormat:@"Make \"%@\" The Default Mesh",[item getID]];
		[theMenu insertItemWithTitle:temp  action:@selector(makeDefaultMesh:) keyEquivalent:@"" atIndex:0];
		[temp release];
		[cell setMenu:theMenu];	
		[outlineView setMenu:theMenu];
	}
 
	//[theMenu release];
}

- (void)scrollWheel:(NSEvent *)theEvent{
	NSLog(@"AWESOME");
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	NSLog(@"COOL");
	if(item == nil){
		return @"Assets";
	}
	if([item isKindOfClass:[NSMutableArray class]]){
		return [Environment getStringForArray:item];
	}
	if([item isKindOfClass:[ModelPart class]]){
		return [[NSString alloc] initWithFormat:@"A%d",[[[(ModelPart*)item getParent] getParts]  indexOfObject:item] ];
	}
	if([item isKindOfClass:[Asset class]]){
		return [item getID];
	//	return @"gggg";
	}
	return @"lol";
}

- (BOOL)drawerShouldClose:(NSDrawer *)sender{
	NSLog(@"sds");
	return YES;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
	NSLog(@"aaa");
	if([[assets itemAtRow:[assets selectedRow]] isKindOfClass:[ImageAsset class]]){
		[glView setTexturePreview:[[assets itemAtRow:[assets selectedRow]] getImage]];
		[detailsDrawer setContentView:imageDetails];
		ImageAsset*ia = [imageDetails getIA];
		if(ia!=nil){
			[ia setID:   [ [imageDetails getName] stringValue ] ];
			
		}
		
		[assets  reloadItem:ia];
		[[imageDetails getName] setStringValue:[[assets itemAtRow:[assets selectedRow]]getID]];
		[[imageDetails getWidth] setStringValue:    [  [NSString alloc]  initWithFormat:@"Width: %d",         [[assets itemAtRow:[assets selectedRow]]getWidth]     ]   ];
		[[imageDetails getHeight] setStringValue:  [    [NSString alloc]  initWithFormat:@"Height: %d",             [[assets itemAtRow:[assets selectedRow]]getHeight]     ]    ];
	
		[imageDetails setIA:[assets itemAtRow:[assets selectedRow]]];
		
	
	}else if([[assets itemAtRow:[assets selectedRow]] isKindOfClass:[ModelAsset class]]){
		[glView setModelPreview:[assets itemAtRow:[assets selectedRow]]];
	    NSLog(@"set");
	}else if([[assets itemAtRow:[assets selectedRow]] isKindOfClass:[ModelPart class]] ){
		[glView setModelPartPreview:[assets itemAtRow:[assets selectedRow]]];
	}
}

-(IBAction)toggleDrawing:(id)sender{
	[glView toggleDrawing:sender];	
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	NSLog(@"%@",[[NSURL alloc]initFileURLWithPath:filename]);
	NSLog(@"OULALA");
	if(![[[[NSURL alloc]initFileURLWithPath:filename] pathExtension] isEqualToString:@"map"]){
		return NO;
	}
	NSLog(@"ssk");
	[Environment openMap:[[NSURL alloc]initFileURLWithPath:filename]];
	[assetsDrawer open];
	[detailsDrawer open];
	return TRUE;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item{
	return NO;	
}

@end
