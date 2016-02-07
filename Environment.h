//
//  Environment.h
//  x
//
//  Created by Spencer Whyte on 10-11-09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"

#import <Cocoa/Cocoa.h>
#import "Map.h"
@class Map;
@class Controller;
static BOOL mapIsOpen;
static BOOL unsavedChanges;
static Map *currentMap;
static Controller *viewController;
@interface Environment : NSObject {
 	IBOutlet NSMenuItem *saveMenuItem;
}
+(BOOL)newMap;
+(BOOL)saveCurrentMap;
+(BOOL)openMap;
+(BOOL)saveMap;
+(BOOL)mapIsOpen;
+(void)setViewController:(Controller*)controller;
+(BOOL)hasUnsavedChanges;
+(void)importAsset;
+(void)openMap:(NSURL*)url;
+(void)change; // Tell the environment that there are unsaved changes
+(Map*)getMap;
+(void)updateDescriptiveImage:(NSImage*)image;
+(NSMutableArray*)getImageAssets;
+(NSMutableArray*)getModelAssets;
+(NSMutableArray*)getAudioAssets;
+(NSMutableArray*)getAnimationAssets;
+(NSMutableArray*)getScriptAssets;
+(NSMutableArray*)getAllAssets;
+(NSString*)getStringForArray:(NSMutableArray*)array;
@end
