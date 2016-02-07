//
//  ImageAsset.m
//  x
//
//  Created by Spencer Whyte on 10-11-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageAsset.h"




@implementation ImageAsset
-(id)initWithData:(NSData*)data ofType:(NSString*)fileExtension andName:(NSString*)nameOfAsset{
	if(self = [super initWithData:data ofType:fileExtension andName:nameOfAsset]){
		if([fileExtension isEqualToString:@"png"]){
			NSImage *im =[[NSImage alloc] initWithData:data];
			CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[im TIFFRepresentation], NULL);
			CGImageRef textureImage=  CGImageSourceCreateImageAtIndex(source, 0, NULL);
			NSInteger texWidth = CGImageGetWidth(textureImage);
			NSInteger texHeight = CGImageGetHeight(textureImage);
			if(log2(texWidth)!=round(log2(texWidth))|| log2(texHeight)!=round(log2(texHeight))){
				return nil;
			}
			imageData = (GLubyte *)calloc(texWidth * texHeight * 4,sizeof(GLubyte));
			CGContextRef textureContext = CGBitmapContextCreate(imageData,texWidth, texHeight,8, texWidth * 4,CGImageGetColorSpace(textureImage),kCGImageAlphaPremultipliedLast);
			CGContextTranslateCTM(textureContext, 0, texHeight);
			CGContextScaleCTM(textureContext, 1.0, -1.0);
			CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
			CGContextRelease(textureContext);
			glGenTextures(1, &image);
			glBindTexture(GL_TEXTURE_2D,image);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			imageWidth = (int)texWidth;
			imageHeight = (int)texHeight;
		}
	}
	return self;
}
-(GLubyte *)getImageData{
	return imageData;	
}


-(GLuint)getImage{
	return image;	
}

-(void)write:(NSMutableData*)data{ 
	int IDLength = [ID length];
	[data appendBytes:&IDLength length:4];
	const char * IDUTF8 = [ID UTF8String];
	[data appendBytes:IDUTF8 length:[ID length]];
	[data appendBytes:&imageWidth length:4];
	[data appendBytes:&imageHeight length:4];
	[data appendBytes:imageData length:imageWidth*imageHeight*4];
}

-(id)initWithData:(NSMutableData*)data{
	if(self = [super initWithData:data]){
		long offset =0;
		[data getBytes:&imageWidth range:NSMakeRange(offset, 4)];
		offset+=4;
		[data getBytes:&imageHeight range:NSMakeRange(offset, 4)];
		offset+=4;
		imageData = calloc(imageWidth*imageHeight*4, sizeof(GLubyte));
		[data getBytes:imageData range:NSMakeRange(offset, imageWidth*imageHeight*4)];
		offset+=imageWidth*imageHeight*4;
		glGenTextures(1, &image);
		glBindTexture(GL_TEXTURE_2D,image);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	return self;
}

-(int)getWidth{
	return imageWidth;
	
	
}

-(int)getHeight{
	return imageHeight;
}

-(void)unload{
	free(imageData);
}

@end
