//
//  ModelPart.m
//  x
//
//  Created by Spencer Whyte on 10-11-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ModelPart.h"


@implementation ModelPart
-(void)write:(NSMutableData*)data{
	[data appendBytes:&vertexCount length:4];
	[data appendBytes:mesh length:sizeof(Vertex)*vertexCount];
	int lengthOfImageAssetName = [[texture getID] length];
	[data appendBytes:&lengthOfImageAssetName length:4];
	[data appendBytes:[[texture getID] UTF8String] length:[[texture getID] length]];
}

-(ModelAsset*)getParent{
	return parentAsset;	
}

-(id)initWithData:(NSMutableData*)data andParent:(ModelAsset *)parent{
	if(self = [super init]){
		drawingMode=2;
		parentAsset = parent;
		long offset = 0;
		[data getBytes:&vertexCount range:NSMakeRange(offset, 4)];
		offset+=4;
		mesh = malloc(sizeof(Vertex)*vertexCount);
		NSLog(@"Vertex count%d", vertexCount);
		[data getBytes:mesh range:NSMakeRange(offset, sizeof(Vertex)*vertexCount)];
		offset+=sizeof(Vertex)*vertexCount;
		int lengthOfImageAssetName;
		
		
		[data getBytes:&lengthOfImageAssetName range:NSMakeRange(offset, 4)];
		offset+=4;
		char imageAssetName[lengthOfImageAssetName+1];
		[data getBytes:imageAssetName range:NSMakeRange(offset, lengthOfImageAssetName)];
		imageAssetName[lengthOfImageAssetName] = '\0';
		offset+=lengthOfImageAssetName;
		NSString *textureName = [NSString stringWithUTF8String:imageAssetName];
		NSMutableArray *imageAssets = [Environment getImageAssets];
		texture = nil;
		int i;
		for(i = 0; i < [imageAssets count]; i++){
			if([[[imageAssets objectAtIndex:i] getID] isEqualToString:textureName]){
				texture = [imageAssets objectAtIndex:i];
				break;
			}
		}
		[data replaceBytesInRange:NSMakeRange(0, offset) withBytes:NULL length:0];
	}
	return self;
}


-(id)initWithPointer:(Vertex*)pointer vertexCount:(int)count imageAsset:(ImageAsset*)a andParent:(ModelAsset*)pa{
	if(self = [super init]){
		parentAsset=pa;
		drawingMode=2;
		vertexCount=count;
		mesh = pointer;
		if(a!=NULL){
			texture=a;
		}else{
			texture=[[Environment getImageAssets] objectAtIndex:0];	
		}
	}
	return self;
}



-(void)draw{
	//glDisable(GL_TEXTURE_2D);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glVertexPointer(3, GL_FLOAT, sizeof(Vertex), mesh->coordiante);
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glColor4f(0.1f, 1.0f, 0.1f, 1.0f);
	if(drawingMode%5==0){ // Edges
		int i = 0;
		for(i=0; i < vertexCount; i+=3){
			glDrawArrays(GL_LINE_LOOP, i, 3);
		}
	}
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	if(drawingMode%3==0){ // Vertices
		glPointSize(2.0f);
		glDrawArrays(GL_POINTS, 0, vertexCount);
	}
	
	
	
	if(drawingMode%2==0){ // Faces
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glBindTexture(GL_TEXTURE_2D, [texture getImage]);
		glTexCoordPointer(2, GL_FLOAT, sizeof(Vertex), mesh->texCoord);
		glDrawArrays(GL_TRIANGLES, 0, vertexCount); 
	}

	
}

-(void)newDrawingMode:(int)dm{
	drawingMode=dm;
}

-(void)setDrawingMode:(float)dm{
	drawingMode*=dm;
}

-(Vertex*)getMeshData{
	return mesh;	
}
-(int)getVertexCount{
	return vertexCount;
}

-(void)scaleMesh:(float)factor{
	int i;
	for(i=0; i < vertexCount*sizeof(Vertex); i+=sizeof(Vertex)){
	//	(Vertex)(mesh+i).coordiante.x= (Vertex)(mesh+i).coordiante.x*factor;
	//	(Vertex)(mesh+i).coordiante.y= (Vertex)(mesh+i).coordiante.y*factor;
	///	(Vertex)(mesh+i).coordiante.z= (Vertex)(mesh+i).coordiante.z*factor;
	}
}

@end
