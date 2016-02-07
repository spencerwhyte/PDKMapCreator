//
//  Map.m
//  x
//
//  Created by Spencer Whyte on 10-11-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Map.h"


@implementation Map

-(void)loadMap{
	long offset = 0;
	NSError *n;
	NSData *dataRead = [NSData dataWithContentsOfURL:mapURL options:0 error:&n];
	[dataRead retain];
	NSLog(@"mapURL: %@",mapURL);
	int lengthOfName =0;
	[dataRead getBytes:&lengthOfName range:NSMakeRange(offset,4)];
	offset+=4;
	char *nameUTF8 = malloc(lengthOfName+1);
	[dataRead getBytes:nameUTF8 range:NSMakeRange(offset, lengthOfName)];
	nameUTF8[lengthOfName] = '\0';
	NSString* name = [[NSString alloc] initWithUTF8String:nameUTF8];
	free(nameUTF8);
	[nameTextField setStringValue:name];
	offset+=lengthOfName;
	int lengthOfDescription = 0;
	[dataRead getBytes:&lengthOfDescription range:NSMakeRange(offset,4)];
	offset+=4;
	char *descriptionUTF8 = malloc(lengthOfDescription+1);
	[dataRead getBytes:descriptionUTF8 range: NSMakeRange(offset, lengthOfDescription)];
	descriptionUTF8[lengthOfDescription] = '\0';
	NSString * description = [[NSString alloc] initWithUTF8String:descriptionUTF8];
	free(descriptionUTF8);
	[descriptionTextField setStringValue:description];
	offset+=lengthOfDescription;
	int descriptiveImageLength;
	[dataRead getBytes:&descriptiveImageLength range: NSMakeRange(offset, 4)];
	offset+=4;
	NSData *tiff =[dataRead subdataWithRange:NSMakeRange(offset, descriptiveImageLength)];
	descriptiveImage = [[NSImage alloc] initWithData:tiff];
	[descriptiveImage retain];
	[Environment updateDescriptiveImage:descriptiveImage];
	
	
	offset+=descriptiveImageLength;
	NSLog(@"A");
	int numberOfAssetTypes=0;
	[dataRead getBytes:&numberOfAssetTypes range:NSMakeRange(offset, 4)];
	offset+=4;
	int i;
	for(i=0 ; i < numberOfAssetTypes; i++){
		NSLog(@"A");
		NSMutableArray *currentArray = [allAssets objectAtIndex:i];
		int numberOfAssetsOfType;
		[dataRead getBytes:&numberOfAssetsOfType range:NSMakeRange(offset, 4)];
		offset+=4;
		int j;
		for(j = 0 ; j < numberOfAssetsOfType; j++){
			NSLog(@"B");
			int lengthOfAsset;
			[dataRead getBytes:&lengthOfAsset range:NSMakeRange(offset, 4)];
			offset+=4;
			NSMutableData *assetData = [NSMutableData dataWithData:[dataRead subdataWithRange:NSMakeRange(offset, lengthOfAsset)]];
			[assetData retain];
			offset+=lengthOfAsset;
			
			[currentArray addObject:[[[self classForArray:currentArray]alloc] initWithData:assetData]];
		}
	}
	
}

-(void)unloadMap{
	[mapURL release];
	[assets release];

	[descriptiveImage release];
}

-(void)saveMap{
	NSMutableData *dataToBeWritten= [[NSMutableData alloc] initWithLength:0];
	int lengthOfName = [[nameTextField stringValue] length];
	NSLog(@"length of name %d", lengthOfName);
	[dataToBeWritten appendData:[NSData dataWithBytes:&lengthOfName length:4]];
	[dataToBeWritten appendData:[NSData dataWithBytes:[[nameTextField stringValue] UTF8String] length:lengthOfName]];
	int lengthOfDescription = [[descriptionTextField stringValue] length];
	[dataToBeWritten appendData:[NSData dataWithBytes:&lengthOfDescription length:4]];
	[dataToBeWritten appendData:[NSData dataWithBytes:[[descriptionTextField stringValue] UTF8String] length:lengthOfDescription]];
	NSData *tiff = [descriptiveImage TIFFRepresentation];
	int lengthOfDescriptiveImage = [tiff length];
	[dataToBeWritten appendData:[NSData dataWithBytes:&lengthOfDescriptiveImage length:4]];
	[dataToBeWritten appendData: tiff];
	int numberOfAssetTypes = [allAssets count];
	NSLog(@"%d", [allAssets count]);
	[dataToBeWritten appendData:[NSData dataWithBytes:&numberOfAssetTypes length:4]];
	int i;
	NSLog(@"ALL ASSETS COUNT: %d", [allAssets count]);
	for(i = 0 ; i < [allAssets count]; i++){
		NSLog(@"TRYING: %d", i);
		NSMutableArray *currentArray = [allAssets objectAtIndex:i];
		int numberOfAssetsOfType = [currentArray count];
		[dataToBeWritten appendData:[NSData dataWithBytes:&numberOfAssetsOfType length:4]];
		int j;
		for(j = 0 ; j < [currentArray count]; j++){
			NSMutableData *assetData = [[NSMutableData alloc] initWithLength:0];
			[[currentArray objectAtIndex:j] write:assetData];
			int lengthOfAsset = [assetData length];
			[dataToBeWritten appendData:[NSData dataWithBytes:&lengthOfAsset length:4]];
			[dataToBeWritten appendData:assetData];
		}
	}
	
	
	[dataToBeWritten writeToURL:mapURL atomically:YES];
	//[tiff release];
}

-(void)drawMap{
	
	
	
	
}

-(NSMutableArray*)getImageAssets{
	return imageAssets;	
}
-(NSMutableArray*)getModelAssets{
	return modelAssets;	
}
-(NSMutableArray*)getAudioAssets{
	return audioAssets;	
}
-(NSMutableArray*)getAnimationAssets{
	return animationAssets;	
}
-(NSMutableArray*)getScriptAssets{
	return scriptAssets;	
}

-(NSMutableArray*)getWeaponAssets{
	return weaponAssets;
}

-(NSMutableArray*)getAllAssets{
	return allAssets;	
}

-(NSString*)getStringForArray:(NSMutableArray*)array{
	if(array == imageAssets){
		return @"Images";
	}else if(array == modelAssets){
		return @"Models";
	}else if(array == audioAssets){
		return @"Audio"	;
	}else if(array  == animationAssets){
		return @"Animations";
	}else if(array == scriptAssets){
		return @"Scripts";
	}else if(array == weaponAssets){
		return @"Weapons";
	}
	return @"IDK WTF THIS IS";
}


-(Class)classForArray:(NSMutableArray*)array{
	if(array == imageAssets){
		return [ImageAsset class];
	}else if(array == modelAssets){
		return [ModelAsset class];
	}
	return [NSObject class];
}

+(void)passNameTextField:(NSTextField *)name andDescriptionTextField:(NSTextField *)description{
	nameTextField = name;
	descriptionTextField=description;
	
}

-(id)initWithURL:(NSURL*) fileURL{
	if (self = [super init]){
		mapURL = fileURL;
		[mapURL retain];
	
		NSError *err = nil;
		NSNumber *n = nil;
	
		
		descriptiveImage = [NSImage imageNamed:@"defaultImage.png"];
		[Environment updateDescriptiveImage:descriptiveImage];
		
		imageAssets=[[NSMutableArray alloc] init];
		modelAssets=[[NSMutableArray alloc] init];
		audioAssets=[[NSMutableArray alloc] init];
		animationAssets=[[NSMutableArray alloc] init];
		scriptAssets=[[NSMutableArray alloc] init];
		weaponAssets=[[NSMutableArray alloc] init];
		allAssets=[[NSMutableArray alloc] init];
		
		[allAssets addObject:animationAssets];
		[allAssets addObject:audioAssets];
		[allAssets addObject:imageAssets];
		[allAssets addObject:modelAssets];
		[allAssets addObject:scriptAssets];
		[allAssets addObject:weaponAssets];
		
		
	}
	return self;	
}

-(void)swapImage:(NSImage*)image{
	NSImage*tempPointer = descriptiveImage;
	descriptiveImage = image;
	if(tempPointer!=nil){
		NSLog(@"releasing");
		[tempPointer release];
	}
}

@end
