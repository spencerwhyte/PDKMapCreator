//
//  Asset.h
//  x
//
//  Created by Spencer Whyte on 10-11-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Asset : NSObject {
	NSString *ID;
	
}
-(void)write:(NSMutableData*)data;
-(id)initWithData:(NSMutableData*)data;
-(id)initWithData:(NSData*)data ofType:(NSString*)fileExtension andName:(NSString*)nameOfAsset;
-(NSString*)getID;
-(void)setID:(NSString*)ID2;
-(void)unload;
@end
