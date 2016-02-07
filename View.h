/*
 * Original Windows comment:
 * "This code was created by Jeff Molofee 2000
 * A HUGE thanks to Fredric Echols for cleaning up
 * and optimizing the base code, making it more flexible!
 * If you've found this code useful, please let me know.
 * Visit my site at nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */

/* Lesson01View.h */

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "Environment.h"
#import "ModelPart.h"
@class ModelAsset;
@class ModelPart;
@interface View : NSOpenGLView
{
   int colorBits, depthBits;
	NSDictionary *originalDisplayMode;
	GLuint logo;
	GLuint texturePreview;
	ModelAsset*modelPreview;
	ModelPart  *partPreview;
	
	int previewMode;// 0 for texture, 1 for model, 2 for model part
	
	float scaleFactor;
	float offsetX;
	float offsetY;
	float offsetZ;
	
	
	float initialX;
	float initialY;
	
	int drawingMode;
}

-(BOOL)validateMenuItem:(NSMenuItem *)item;
- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits depthBits:(int)numDepthBits;
- (void) reshape;
- (void) drawRect:(NSRect)rect;
- (void) dealloc;
-(void)setTexturePreview:(GLuint)tp;
-(void)setModelPreview:(ModelAsset*)a;
-(void)setModelPartPreview:(ModelPart*)p;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)scrollWheel:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
-(void)keyDown:(NSEvent *)theEvent;
-(IBAction)toggleDrawing:(id)sender;
@end
