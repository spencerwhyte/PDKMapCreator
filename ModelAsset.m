//
//  ModelAsset.m
//  x
//
//  Created by Spencer Whyte on 10-11-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ModelAsset.h"


@implementation ModelAsset

-(void)write:(NSMutableData*)data{
	int IDLength = [ID length];
	[data appendBytes:&IDLength length:4];
	const char * IDUTF8 = [ID UTF8String];
	[data appendBytes:IDUTF8 length:[ID length]];
    int numberOfParts = [parts count];
	[data appendBytes:&numberOfParts length:4];
	int i;
	for(i=0; i < numberOfParts; i++){
		[[parts objectAtIndex:i] write:data];
	}
}
/*
bool loadOBJ(char* fileName){ 
	FILE *objFile = fopen(fileName, "r");
	int vertexCount=0;
	int normalCount=0;
	int texCoordCount=0;
	int faceCount=0;
	int partsCount=0;
	if(objFile != NULL){
		
		fseek (objFile , 0 , SEEK_END);
		long fileLength = ftell (objFile);
		rewind (objFile);
		char *buffer  = malloc(fileLength);
		fread(buffer, 1, fileLength, objFile);
		
		
		while(fscanf(objFile, "%100s", c)){
			if(strlen(c)>2){
			if(c[0]=='f'){
				faceCount++;
			}else if(c[0]=='v' && c[1]=='t'){
				texCoordCount++;
			}else if(c[0]=='v' && c[1]=='n'){
				normalCount++;
			}else if(c[0]=='v' && c[1]==' '){
				vertexCount++;
			}else if(c[0]=='u' && c[1]=='s'){
				partsCount++;
			}
			
			}
		}
		fclose(objFile);
	}else{
		return false;	
	}
	
	
	return true;
}
*/

-(id)initWithData:(NSMutableData*)data{
	if(self = [super initWithData:data]){
		parts = [[NSMutableArray alloc] init];
		int numberOfParts;
		[data getBytes:&numberOfParts range:NSMakeRange(0, 4)];
		[data replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
		int i;
		for(i = 0 ; i < numberOfParts; i++){
			[parts addObject:[[ModelPart alloc]initWithData:data andParent:self]];
		}
	}
	return self;
}




-(id)initWithData:(NSData*)data ofType:(NSString*)fileExtension andName:(NSString*)nameOfAsset{
	
	if(self = [super init]){
		ID = nameOfAsset;
		[ID retain];
		if([fileExtension isEqualToString:@"parts"]){ // LAODS PARTS FILE
			parts = [[NSMutableArray alloc] init];
			long offset = 0;
			int numberOfParts;
			[data getBytes:&numberOfParts range:NSMakeRange(offset, 4)];
			offset+=4;
			int i;
			NSMutableArray *arr=[[NSMutableArray alloc] init];
			for(i = 0 ; i < numberOfParts; i++){
				int vertexCount;
				[data getBytes:&vertexCount range:NSMakeRange(offset, 4)];
				int sizex, sizey;
				[data getBytes:&sizex range:NSMakeRange(offset+4, 4)];
				[data getBytes:&sizey range:NSMakeRange(offset+8, 4)];
				NSString *tempID = [NSString stringWithFormat:@"%@Part%dTexture", nameOfAsset,i];
				int tempIDLength = [tempID length];
				NSMutableData *imageData = [NSMutableData dataWithBytes:&tempIDLength length:4];
				[imageData appendBytes:[tempID UTF8String] length:tempIDLength];
				[imageData appendData:[data subdataWithRange:NSMakeRange(offset+4, 8+(sizex*sizey*4))]];
				NSMutableArray *imageAssets = [Environment getImageAssets];
				[imageAssets addObject:[[ImageAsset alloc] initWithData:imageData]];
				NSMutableData *partData = [NSMutableData dataWithBytes:&vertexCount length:4];
				[partData appendData:[data subdataWithRange:NSMakeRange(offset+12+sizex*sizey*4, sizeof(Vertex)*vertexCount)]];
				[partData appendBytes:&tempIDLength length:4];
				[partData appendBytes:[tempID UTF8String] length:tempIDLength];
				[parts addObject:[[ModelPart alloc]initWithData:partData andParent:self] ];
				[arr addObject:partData];
				[arr addObject:imageData];
				[arr addObject:tempID];
				offset+=12+(sizex*sizey*4)+ sizeof(Vertex)*vertexCount;
			}
			int u;
			for(u = 0 ; u < [arr count]; u++){
				[[arr objectAtIndex:u] release];
			}
		}else if([fileExtension isEqualToString:@"obj"]){ // LOADS OBJ FILE
			
		parts = [[NSMutableArray alloc] init];
			
			char tempPointer[[data length]+1];
			tempPointer[[data length]]='\0';
			[data getBytes:tempPointer];
			NSString *objData = [[NSString alloc] initWithUTF8String:tempPointer];
		    NSArray *lines = [objData componentsSeparatedByString:@"\n"];	
			NSLog(@"%d", [lines count]);
			int textureCoordinateCount=0;
			int normalCount=0;
			int vertexCount=0;
			int faceCount=0;
			
			NSMutableArray *images = [[NSMutableArray alloc] init];
			
			int i;
			for(i = 0 ;i < [lines count]; i++){
				NSString *currentLine = [lines objectAtIndex:i];
				if([currentLine length]>2){
					if([currentLine characterAtIndex:0] == 'v' && [currentLine characterAtIndex:1] == 't'){
						textureCoordinateCount++;
					}else if([currentLine characterAtIndex:0] == 'v' && [currentLine characterAtIndex:1] == 'n'){
						normalCount++;
					}else if([currentLine characterAtIndex:0] == 'v'){
						vertexCount++;
					}else if([currentLine characterAtIndex:0] == 'f'){
						faceCount++;
					}else if([currentLine rangeOfString:@"usemtl"].location ==0){
						NSString *mtl =[currentLine stringByReplacingOccurrencesOfString:@"usemtl " withString:@""];
						int mtlIndex = -1;
						int j;
						for(j=0; j< [images count]; j++){
							if([[images objectAtIndex:j] isEqualToString:mtl]){
								mtlIndex=i;
							}
						}
						if(mtlIndex==-1){
							[images addObject:mtl];
						}
					}
				}
			}
			
			
	
			int faceCountForPart[[images count]];
			int d= 0;
			for(d=0; d < [images count] ; d++){
				faceCountForPart[d] = 0;
				
			}
			
			
			vec3 vertices[vertexCount];
			vec3 normals[normalCount];
			vec2 textureCoords[textureCoordinateCount];
			
			int vertexIndex =0;
			int textureCoordsIndex = 0;
			int normalIndex =0;
			int magicUnicorn = 0;
			
			for(i = 0 ;i < [lines count]; i++){
				NSString *currentLine = [lines objectAtIndex:i];
				if([currentLine length]>2){
					if([currentLine characterAtIndex:0] == 'v' && [currentLine characterAtIndex:1] == 't'){
						NSScanner* s2 = [[NSScanner alloc] initWithString:[currentLine substringFromIndex:2]];
						[s2 scanFloat:&(textureCoords[textureCoordsIndex].x)];
						[s2 scanFloat:&(textureCoords[textureCoordsIndex].y)];
						textureCoordsIndex++;
					}else if([currentLine characterAtIndex:0] == 'v' && [currentLine characterAtIndex:1] == 'n'){
						NSScanner* s2 = [[NSScanner alloc] initWithString:[currentLine substringFromIndex:2]];
						[s2 scanFloat:&(normals[normalIndex].x)];
						[s2 scanFloat:&(normals[normalIndex].y)];
						[s2 scanFloat:&(normals[normalIndex].z)];
						normalIndex++;
					}else if([currentLine characterAtIndex:0] == 'v'){
						NSScanner *s2 = [[NSScanner alloc] initWithString:[currentLine substringFromIndex:1]];
						[s2 scanFloat:&(vertices[vertexIndex].x)];
						[s2 scanFloat:&(vertices[vertexIndex].y)];
						[s2 scanFloat:&(vertices[vertexIndex].z)];
						
						vertexIndex++;
					}else if([currentLine characterAtIndex:0] == 'f'){
							faceCountForPart[magicUnicorn]++;
					}else if([currentLine rangeOfString:@"usemtl"].location ==0){
						NSString *ob = [currentLine stringByReplacingOccurrencesOfString:@"usemtl " withString:@""];
						 magicUnicorn = [images indexOfObject:ob];
					}
				}
			}
			
			
	
			
			int j;
			for(j = 0 ; j  < [images count]; j++){
				
				if(faceCountForPart[j]!=0){
					Vertex * currentPart = malloc(sizeof(Vertex)*faceCountForPart[j]*3);
					long currentPartFaceIndex = 0;
					BOOL inRange = NO;
					for(i = 0 ;i < [lines count]; i++){
						NSString *currentLine = [lines objectAtIndex:i];
						NSScanner *s = [[NSScanner alloc] initWithString:currentLine];
						if([currentLine length]>2){
							if([currentLine characterAtIndex:0] == 'f'){
								
								if(inRange){
									NSString *newCurrentLine = [[currentLine stringByReplacingOccurrencesOfString:@"/" withString:@" "] substringFromIndex:1];
									NSScanner *newScanner = [[NSScanner alloc] initWithString:newCurrentLine];
									int k;
									for(k = 0 ; k < 3; k ++){
										int vertexIndex1;
										int texCoordIndex1;
										int normalIndex1;
										[newScanner scanInt:&vertexIndex1];
										[newScanner scanInt:&texCoordIndex1];
										[newScanner scanInt:&normalIndex1];
										currentPart[currentPartFaceIndex].coordiante[2] = vertices[vertexIndex1-1].x;
										currentPart[currentPartFaceIndex].coordiante[1] = vertices[vertexIndex1-1].y;
										currentPart[currentPartFaceIndex].coordiante[0] = vertices[vertexIndex1-1].z;
										currentPart[currentPartFaceIndex].normal[0] = normals[normalIndex1-1].x;
										currentPart[currentPartFaceIndex].normal[1] = normals[normalIndex1-1].y;
										currentPart[currentPartFaceIndex].normal[2] = normals[normalIndex1-1].z;
										currentPart[currentPartFaceIndex].texCoord[0] = textureCoords[texCoordIndex1-1].x;
										currentPart[currentPartFaceIndex].texCoord[1] = textureCoords[texCoordIndex1-1].y;
										NSLog(@"blah   %f %f %f", vertices[vertexIndex1-1].x,	vertices[vertexIndex1-1].y,	vertices[vertexIndex1-1].z);
										currentPartFaceIndex++;
									}
								}
							}else if([currentLine rangeOfString:@"usemtl"].location ==0){
								inRange = [[currentLine stringByReplacingOccurrencesOfString:@"usemtl " withString:@""]isEqualToString:[images objectAtIndex:j]];
							}
						}
					}
					for(d=0; d < [images count] ; d++){
						NSLog(@"brocoli %d",faceCountForPart[d]);
					}
					
					ModelPart *ma = [[ModelPart alloc] initWithPointer:currentPart vertexCount:faceCountForPart[j]*3 imageAsset:NULL andParent: self];
					[parts addObject:ma];
				}
			}
			
		
		}
		
	}
	return self;
}

-(void)setDrawingMode:(float)dm{
	int i;
	for(i=0 ; i < [parts count]; i++){
		[[parts objectAtIndex:i] setDrawingMode:dm];
	}
}

-(void)newDrawingMode:(int)dm{
	int i;
	for(i=0 ; i < [parts count]; i++){
		[[parts objectAtIndex:i] newDrawingMode:dm];
	}
}

-(NSMutableArray*)getParts{
	
	return parts;	
}


-(ModelPart*)getPart:(int)index{
	return [parts objectAtIndex:index];	
}

-(void)draw{
	

	int i;
	for(i = 0 ; i < [parts count]; i++){
		
		[(ModelPart*)[parts objectAtIndex:i] draw];
	}
}

-(void)unload{
	
}
@end
