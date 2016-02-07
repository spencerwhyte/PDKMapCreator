//
//  Asset.m
//  x
//
//  Created by Spencer Whyte on 10-11-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Asset.h"


@implementation Asset


-(id)initWithData:(NSData*)data ofType:(NSString*)fileExtension andName:(NSString*)nameOfAsset{
	if(self = [super init]){
			ID = nameOfAsset;	
	}
	return self;
}

-(NSString*)getID{
	return ID;	
}

-(void)setID:(NSString*)ID2{
	[ID release];
	ID = ID2;
	[ID2 retain];
}

-(void)write:(NSMutableData*)data{

}


-(id)initWithData:(NSMutableData*)data{
	if(self = [super init]){

		long offset=0;
		int IDLength;
		[data getBytes:&IDLength range:NSMakeRange(offset, 4)];
		offset+=4;
		char IDUTF8[IDLength+1];
		
		[data getBytes:&IDUTF8 range: NSMakeRange(offset, IDLength)];
		IDUTF8[IDLength] = '\0';
		ID = [[NSString alloc] initWithUTF8String:IDUTF8];
		offset+=IDLength;
		[data replaceBytesInRange:NSMakeRange(0, offset) withBytes:NULL length:0];
	}
	return self;
}

-(void)unload{
	
}

@end
