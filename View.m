

#import "View.h"


@interface View (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (void) switchToOriginalDisplayMode;
- (BOOL) initGL;
@end

float logoAngle;
float logoScaling;

@implementation View

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits depthBits:(int)numDepthBits {
	NSOpenGLPixelFormat *pixelFormat;
	
	colorBits = numColorBits;
	depthBits = numDepthBits;
	originalDisplayMode = (NSDictionary *) CGDisplayCurrentMode(
																kCGDirectMainDisplay );
	pixelFormat = [ self createPixelFormat:frame ];
	if( pixelFormat != nil )
	{
		self = [ super initWithFrame:frame pixelFormat:pixelFormat ];
		[ pixelFormat release ];
		if( self )
		{
			[ [ self openGLContext ] makeCurrentContext ];
			[ self reshape ];
			if( ![ self initGL ] )
			{
				[ self clearGLContext ];
				self = nil;
			}
		}
	}
	else
		self = nil;
	
	
	NSImage *im =[[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"logo" ofType:@"png"]]];
	
	
	
	CGImageSourceRef source;
	
	source = CGImageSourceCreateWithData((CFDataRef)[im TIFFRepresentation], NULL);
	CGImageRef textureImage=  CGImageSourceCreateImageAtIndex(source, 0, NULL);
	
	NSInteger texWidth = CGImageGetWidth(textureImage);
	NSInteger texHeight = CGImageGetHeight(textureImage);
	
	GLubyte *textureData = (GLubyte *)calloc(texWidth * texHeight * 4,sizeof(GLubyte));
	//memset(textureData, 0, texWidth * texHeight * 4);
	CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth, texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
	CGContextTranslateCTM(textureContext, 0, texHeight);
	CGContextScaleCTM(textureContext, 1.0, -1.0);
	
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	glGenTextures(1, &logo);
	glBindTexture(GL_TEXTURE_2D, logo);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	free(textureData);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	texturePreview = logo;
	modelPreview=nil;
	partPreview=nil;
	previewMode=0;
	logoAngle=0.0f;
	logoScaling = 1.0f;
	scaleFactor=1.0f;
	offsetX=0.0f;
	offsetY=0.0f;
	offsetZ=0.0f;
	initialX=0.0f;
	initialY =0.0f;
	drawingMode=2;
	return self;
}


/*
 * Create a pixel format and possible switch to full screen mode
 */
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame
{
	NSOpenGLPixelFormatAttribute pixelAttribs[ 16 ];
	int pixNum = 0;
	NSDictionary *fullScreenMode;
	NSOpenGLPixelFormat *pixelFormat;
	
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADoubleBuffer;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAAccelerated;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAColorSize;
	pixelAttribs[ pixNum++ ] = colorBits;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADepthSize;
	pixelAttribs[ pixNum++ ] = depthBits;
	pixelAttribs[ pixNum ] = 0;
	pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
                   initWithAttributes:pixelAttribs ];
	
	return pixelFormat;
}

-(void)mouseDown:(NSEvent *)theEvent{
	
}


/*
 * Switch to the display mode in which we originally began
 */
- (void) switchToOriginalDisplayMode
{
	CGDisplaySwitchToMode( kCGDirectMainDisplay,
                          (CFDictionaryRef) originalDisplayMode );
	CGDisplayShowCursor( kCGDirectMainDisplay );
	CGDisplayRelease( kCGDirectMainDisplay );
}


- (void)mouseDragged:(NSEvent *)theEvent{
	if(previewMode==0){
		offsetX+=[theEvent deltaX]/100.0f;
		offsetY-=[theEvent deltaY]/100.0f;
	}else{
		offsetX+=[theEvent deltaX]/10.0f;
		offsetY-=[theEvent deltaY]/10.0f;
	}
}

-(void)keyDown:(NSEvent *)theEvent{
	NSLog(@"sdfs");
	switch( [theEvent keyCode] ) {
		case 'w':
			offsetZ-=0.5f;
			break;		
	}
	
}


/*
 * Initial OpenGL setup
 */
- (BOOL) initGL
{ 
	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
	// Really nice perspective calculations
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	return TRUE;
}


- (void)scrollWheel:(NSEvent *)theEvent{
	scaleFactor+=[theEvent deltaY]/100.0f;
	NSLog(@"%f", scaleFactor);
}

/*
 * Resize ourself
 */
- (void) reshape
{ 
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	// Reset current viewport
	glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Calculate the aspect ratio of the view
	gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
                   0.1f, 10000.0f );
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}



-(BOOL)validateMenuItem:(NSMenuItem *)item{
	
	if([[item title] isEqualToString:@"Vertices"]){
		if([Environment mapIsOpen]){
			return YES;
		}
		return NO;
	}
	if([[item title] isEqualToString:@"Edges"]){
		if([Environment mapIsOpen]){
			return YES;
		}
		return NO;
	}
	
	if([[item title] isEqualToString:@"Faces"]){
		if([Environment mapIsOpen]){
			return YES;
		}
		return NO;
	}
	
	return YES;
}

-(IBAction)toggleDrawing:(id)sender{
	if([[sender title] isEqualToString:@"Vertices"]){	
		if(previewMode == 1){ // Model Preview
			if([sender state]== NSOnState){
				[sender setState:NSOffState];
				[modelPreview setDrawingMode:1/3.0f];
				drawingMode/=3.0f;
			}else if([sender state]== NSOffState){
				[sender setState:NSOnState];
				[modelPreview setDrawingMode:3.0f];
				drawingMode*=3;
			}
		}else if(previewMode==2){ // Part preview
			if([sender state]== NSOnState){
				[sender setState:NSOffState];
				[partPreview setDrawingMode:1/3.0f];
				drawingMode/=3.0f;
			}else if([sender state]== NSOffState){
				[sender setState:NSOnState];
				[partPreview setDrawingMode:3.0f];
				drawingMode*=3.0f;
			}
		}
	}else if([[sender title] isEqualToString:@"Edges"]){	
		if(previewMode == 1){ // Model Preview
			if([sender state]== NSOnState){
				[sender setState:NSOffState];
				[modelPreview setDrawingMode:1/5.0f];
				drawingMode/=5.0f;
			}else if([sender state]== NSOffState){
				[sender setState:NSOnState];
				[modelPreview setDrawingMode:5.0f];
				drawingMode*=5.0f;
			}
		}else if(previewMode==2){ // Part preview
			if([sender state]== NSOnState){
				[sender setState:NSOffState];
				[partPreview setDrawingMode:1/5.0f];
				drawingMode/=5.0f;
			}else if([sender state]== NSOffState){
				[sender setState:NSOnState];
				[partPreview setDrawingMode:5.0f];
				drawingMode*=5.0f;
			}
		}
	}else if([[sender title] isEqualToString:@"Faces"]){	
		if(previewMode == 1){ // Model Preview
			if([sender state]== NSOnState){
				[sender setState:NSOffState];
				[modelPreview setDrawingMode:1/2.0f];
				drawingMode/=2.0f;
			}else if([sender state]== NSOffState){
				[sender setState:NSOnState];
				[modelPreview setDrawingMode:2.0f];
				drawingMode*=2.0f;
			}
		}else if(previewMode==2){ // Part preview
			if([sender state]== NSOnState){
				[sender setState:NSOffState];
				[partPreview setDrawingMode:1/2.0f];
				drawingMode/=2.0f;
			}else if([sender state]== NSOffState){
				[sender setState:NSOnState];
				[partPreview setDrawingMode:2.0f];
				drawingMode*=2.0f;
			}
		}
	}

	
	
}

/*
 * Called when the system thinks we need to draw.
 */
- (void) drawRect:(NSRect)rect
{
	// Clear the screen and depth buffer
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	
	
	
	
	
	
	
	
	
	if([Environment mapIsOpen]){
		logoScaling-=0.03f;
	}else{
		logoScaling =1.0f;	
	}
	if(logoScaling>0){
		logoAngle+=0.1f;
		glTranslatef( 0.0, 0.0f, -5.0f );   // Left 1.5 units, into screen 6.0
		glRotatef(logoAngle, 0.0f, 1.0f, 0.0f);
		const GLfloat  a[] = {
			-1.0f,  1.0f, 0.0f ,   // Top
			-1.0f, -1.0f, 0.0f ,    // Bottom left
			1.0f, -1.0f, 0.0f,
			1.0f, 1.0f, 0.0f
		};
		const GLfloat  b[] = {
			0.0f,  1.0f,    // Top
			0.0f, 0.0f,    // Bottom left
			1.0f, 0.0f, 
			1.0f, 1.0f
		};
		
		glScalef(logoScaling, logoScaling, logoScaling);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glBindTexture(GL_TEXTURE_2D, logo);
		glVertexPointer(3, GL_FLOAT, 0, a);
		glTexCoordPointer(2, GL_FLOAT, 0, b);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	}else if(previewMode==1){
		glTranslatef(offsetX*10.0f, offsetY*10.0f, scaleFactor*10.0f); 
		//glScalef(0.01f, 0.01f, 0.01f);
		//glScalef(scaleFactor,scaleFactor,scaleFactor);
	
		//glRotatef(logoAngle, 1.0f, 1.0f, 1.0f);
		logoAngle+=0.1f;
		[modelPreview draw];
	}else if(previewMode==2){
		glTranslatef(offsetX, offsetY, scaleFactor ); 
		//
		//glScalef(0.01f, 0.01f, 0.01f);
		//glScalef(scaleFactor,scaleFactor,scaleFactor);
		
		//glRotatef(logoAngle, 1.0f, 1.0f, 1.0f);
		logoAngle+=0.1f;
		[partPreview draw];	
	}else if(previewMode==0){
		glTranslatef( offsetX, offsetY, -6.0f ); 
		const GLfloat  a[] = {
			-1.0f,  1.0f, 0.0f ,   // Top
			-1.0f, -1.0f, 0.0f ,    // Bottom left
			1.0f, -1.0f, 0.0f,
			1.0f, 1.0f, 0.0f
		};
		const GLfloat  b[] = {
			0.0f,  1.0f,    // Top
			0.0f, 0.0f,    // Bottom left
			1.0f, 0.0f, 
			1.0f, 1.0f
		};
		glScalef(scaleFactor,scaleFactor,scaleFactor);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glBindTexture(GL_TEXTURE_2D, texturePreview);
		glVertexPointer(3, GL_FLOAT, 0, a);
		glTexCoordPointer(2, GL_FLOAT, 0, b);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		
	}
	
	
	glLoadIdentity();   // Reset the current modelview matrix
	[ [ self openGLContext ] flushBuffer ];
}

-(void)setTexturePreview:(GLuint)tp{
	previewMode=0;
	texturePreview = tp;	
	scaleFactor=1.0f;
	offsetX=0.0f;
	offsetY=0.0f;
	offsetZ=0.0f;
}
-(void)setModelPreview:(ModelAsset*)a{
	NSLog(@"BURITO");
	modelPreview = a;	
	previewMode=1;
	scaleFactor=1.0f;
	[a newDrawingMode:drawingMode];
	offsetX=0.0f;
	offsetY=0.0f;
	offsetZ=0.0f;
}


-(void)setModelPartPreview:(ModelPart*)p{
	previewMode=2;
	[p newDrawingMode:drawingMode];
	partPreview=p;
	if(modelPreview==nil || ![[modelPreview getParts] containsObject:p]){
		scaleFactor=1.0f;
		offsetX=0.0f;
		offsetY=0.0f;
		offsetZ=0.0f;
	}
}


/*
 * Cleanup
 */
- (void) dealloc
{
	[ originalDisplayMode release ];
}

@end
