//
//  ModelAsset.h
//  x
//
//  Created by Spencer Whyte on 10-11-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModelPart.h"
#import "ImageAsset.h"


typedef struct vec3 {
	GLfloat x;
	GLfloat y;
	GLfloat z;
} vec3;
typedef struct vec2 {
	GLfloat x;
	GLfloat y;
} vec2;
@interface ModelAsset : Asset {

	
	NSMutableArray *parts;
	
	
	
	
	
}


-(id)getPart:(int)index;

-(void)setDrawingMode:(float)dm;
-(void)newDrawingMode:(int)dm;
-(NSMutableArray*)getParts;
-(void)write:(NSMutableData*)data;
-(id)initWithData:(NSMutableData*)data;
-(id)initWithData:(NSData*)data ofType:(NSString*)fileExtension andName:(NSString*)nameOfAsset;
-(void)unload;
-(void)draw;



@end
