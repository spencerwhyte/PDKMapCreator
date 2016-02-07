//
//  Environment.m
//  x
//
//  Created by Spencer Whyte on 10-11-09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Environment.h"


@implementation Environment

// Gets called when the user selects new from the file menu
+(BOOL)newMap{
	if([Environment saveCurrentMap]){
		NSSavePanel * savePanel = [NSSavePanel savePanel];
		NSArray * fileTypes = [NSArray arrayWithObject:@"map"];
		[savePanel setAllowedFileTypes:fileTypes];
		if([savePanel runModal] == NSFileHandlingPanelOKButton){
			currentMap=nil;
			currentMap = [[Map alloc] initWithURL:[savePanel URL]];
			unsavedChanges = NO;
			[currentMap saveMap];
			mapIsOpen = YES;
			[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[savePanel URL]];
			return YES;
		}
	}
	return NO;
}


+(void)setViewController:(Controller*)controller{
	viewController=controller;
	[Map passNameTextField:[controller getNameTextField] andDescriptionTextField:[controller getDescriptionTextField]];
}
										
+(BOOL)hasUnsavedChanges{
	return unsavedChanges;
}

+(BOOL)saveCurrentMap{
	if(mapIsOpen){
	    /// Ask the user if they want to save the map
		// If they want to save the map save it and return YES and set mapIsOpen to NO
		// If they dont want to save the map dont save it and return YES and set mapIsOpen to NO
		// If they want to cencel return NO
		int temp = NSRunAlertPanel(@"Save", @"Would you like to save the current map?", @"Save", @"Cancel", @"Don't Save");
		if(temp==0){
			return NO;
		}else if(temp==-1){
			mapIsOpen = NO;
			[currentMap unloadMap];
			[currentMap release];
				currentMap=nil;
			unsavedChanges = NO;
			return YES;
		}
		[currentMap saveMap];
		[currentMap unloadMap];
		[currentMap release];
		mapIsOpen = NO;
		unsavedChanges = NO;
	}
	return YES;
}

+(void)updateDescriptiveImage:(NSImage*)image{

	[viewController updateDescriptiveImage:image];
	
}


+(void)saveMap{
	if(mapIsOpen){
		[currentMap saveMap];
		unsavedChanges=NO;
	}
}
+(void)change{
	unsavedChanges = YES;	
}

+(BOOL)mapIsOpen{
	return mapIsOpen;
}

+(BOOL)openMap{
	if([Environment saveCurrentMap]){	
		NSOpenPanel * openPanel = [NSOpenPanel openPanel];
		NSArray * fileTypes = [NSArray arrayWithObject:@"map"];
		[openPanel setAllowedFileTypes:fileTypes];
		[openPanel setAllowsMultipleSelection:NO];
		if([openPanel runModal] == NSFileHandlingPanelOKButton){
			currentMap=nil;
			currentMap = [[Map alloc] initWithURL:[openPanel URL]];	
			[currentMap loadMap];
			mapIsOpen = YES;
			unsavedChanges = YES;
	
			[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[openPanel URL]];
			return YES;
		}
		return NO;
	}
}

+(void)openMap:(NSURL*)url{
	if([Environment saveCurrentMap]){	
			currentMap=nil;
			currentMap = [[Map alloc] initWithURL:url];	
			[currentMap loadMap];
			mapIsOpen = YES;
			unsavedChanges = YES;
			
			[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
			
		
	}
	
}

+(void)importAsset{

	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	NSMutableArray * fileTypes2 = [NSMutableArray arrayWithObject:@"png"];
	[fileTypes2 addObject:@"parts"];
	[fileTypes2 addObject:@"obj"];
	[fileTypes2 addObject:@"imageData"];
	// embarassment!!!!!!!!
	NSArray *fileTypes = [NSArray arrayWithArray:fileTypes2];
	[openPanel setAllowedFileTypes:fileTypes];
	[openPanel setAllowsMultipleSelection:NO];
	if([openPanel runModal] == NSFileHandlingPanelOKButton){
	    if([[[openPanel URL] pathExtension] isEqualToString:@"png"]){
			NSString *name = [[NSString stringWithString:[[openPanel URL] lastPathComponent]] stringByReplacingOccurrencesOfString:@".png" withString:@""];
			[name retain];
			ImageAsset *ia = [[ImageAsset alloc] initWithData:[NSData dataWithContentsOfURL:[openPanel URL]] ofType:@"png" andName:name];
			if(ia!=nil){
				[ia retain];
				NSLog(@"A%@", [[openPanel URL]relativeString]);
				NSMutableArray* imageAssets = [currentMap getImageAssets];
				[imageAssets addObject:ia];
				unsavedChanges = YES;
			}
		}else if([[[openPanel URL] pathExtension] isEqualToString:@"parts"]){
			NSString *name = [[NSString stringWithString:[[openPanel URL] lastPathComponent]] stringByReplacingOccurrencesOfString:@".parts" withString:@""];
			[name retain];
			ModelAsset * ma = [[ModelAsset alloc] initWithData: [NSData dataWithContentsOfURL:[openPanel URL]] ofType:@"parts" andName:name];
			[ma retain];
			NSLog(@"A%@", [[openPanel URL]relativeString]);
			NSMutableArray* modelAssets = [currentMap getModelAssets];
			[modelAssets addObject:ma];
			unsavedChanges = YES;
		}else if([[[openPanel URL] pathExtension] isEqualToString:@"obj"]){
			NSString *name = [[NSString stringWithString:[[openPanel URL] lastPathComponent]] stringByReplacingOccurrencesOfString:@".obj" withString:@""];
			[name retain];
			ModelAsset * ma = [[ModelAsset alloc] initWithData: [NSData dataWithContentsOfURL:[openPanel URL]] ofType:@"obj" andName:name];
			[ma retain];
			NSLog(@"A%@", [[openPanel URL]relativeString]);
			NSMutableArray* modelAssets = [currentMap getModelAssets];
			[modelAssets addObject:ma];
			unsavedChanges = YES;
		}else if([[[openPanel URL] pathExtension] isEqualToString:@"imageData"]){
			NSString *name = [[NSString stringWithString:[[openPanel URL] lastPathComponent]] stringByReplacingOccurrencesOfString:@".imageData" withString:@""];
			[name retain];
			ImageAsset *ia = [[ImageAsset alloc] initWithData:[NSMutableData dataWithContentsOfURL:[openPanel URL]]];
			if(ia!=nil){
				[ia retain];
				NSLog(@"A%@", [[openPanel URL]relativeString]);
				NSMutableArray* imageAssets = [currentMap getImageAssets];
				[imageAssets addObject:ia];
				unsavedChanges = YES;
			}
		}
		
	}
	
}

+(NSMutableArray*)getImageAssets{
	return [currentMap getImageAssets];	
}
+(NSMutableArray*)getModelAssets{
	return [currentMap getModelAssets];	
}
+(NSMutableArray*)getAudioAssets{
	return [currentMap getAudioAssets];	
}
+(NSMutableArray*)getAnimationAssets{
	return [currentMap getAnimationAssets];	
}
+(NSMutableArray*)getScriptAssets{
	return [currentMap getScriptAssets];	
}

+(NSMutableArray*)getAllAssets{
	return [currentMap getAllAssets];	
}

+(NSString*)getStringForArray:(NSMutableArray*)array{
	return [currentMap getStringForArray:array];
}


+(Map*)getMap{
	return currentMap;	
}

@end
