//
//  ModelPart.h
//  x
//
//  Created by Spencer Whyte on 10-11-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageAsset.h"
#import "Environment.h"
#import "ModelAsset.h"

@class ModelAsset;
typedef struct Vertex {
	GLfloat coordiante[3];
    GLfloat normal[3];
    GLfloat texCoord[2];
} Vertex;

@interface ModelPart : NSObject {
    ImageAsset *texture;
	Vertex *mesh;
	int vertexCount;
	
	ModelAsset *parentAsset;
	int drawingMode;
}

-(ModelAsset*)getParent;

-(void)write:(NSMutableData*)data;
-(id)initWithData:(NSMutableData*)data andParent:(ModelAsset*)parent;
-(Vertex*)getMeshData;
-(int)getVertexCount;
-(void)draw;
-(void)setDrawingMode:(float)dm;
-(void)scaleMesh:(float)factor;
-(void)newDrawingMode:(int)dm;
-(id)initWithPointer:(Vertex*)pointer vertexCount:(int)count imageAsset:(ImageAsset*)a andParent:(ModelAsset*)parent;
@end
