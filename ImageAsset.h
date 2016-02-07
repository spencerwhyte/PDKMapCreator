//
//  ImageAsset.h
//  x
//
//  Created by Spencer Whyte on 10-11-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Asset.h"

#import <OpenGL/gl.h>

@interface ImageAsset : Asset {
	int imageWidth;
	int imageHeight;
	GLubyte *imageData;
	GLuint image;
}
-(GLuint)getImage;
-(GLubyte *)getImageData;
-(void)write:(NSMutableData*)data;
-(void)unload;
-(int)getWidth;
-(int)getHeight;
-(id)initWithData:(NSMutableData*)data;

-(id)initWithData:(NSData*)data ofType:(NSString*)fileExtension andName:(NSString*)nameOfAsset;
@end
