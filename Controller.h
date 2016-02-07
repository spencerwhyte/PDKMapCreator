

#import <Cocoa/Cocoa.h>
#import "ModelAsset.h"
#import "View.h"
#import "ImageDetails.h"
@class View;
@class ImageDetails;


@interface Controller : NSResponder <NSDrawerDelegate,NSOutlineViewDataSource, NSApplicationDelegate, NSOutlineViewDelegate, NSWindowDelegate>
{
   IBOutlet NSWindow *glWindow;
 	IBOutlet NSDrawer *assetsDrawer;
	IBOutlet NSDrawer *detailsDrawer;
	NSTimer *renderTimer;
	View *glView;
	IBOutlet NSMenuItem *saveMenuItem;
	IBOutlet NSOutlineView *assets;
	NSScrollView * scrollView;
	IBOutlet NSTextField *nameTextField;
	IBOutlet NSTextField *descriptionTextField;
	IBOutlet NSImageView *descriptiveImageView;
	IBOutlet NSPanel * propertiesPanel;
	
	IBOutlet ImageDetails *imageDetails;
	
}
-(void) awakeFromNib;
-(void) keyDown:(NSEvent *)theEvent;

- (BOOL)drawerShouldClose:(NSDrawer *)sender;
-(void)makeDefaultMesh:(id)sender;
- (void)mouseDown:(NSEvent *)theEvent;
-(void) dealloc;
-(IBAction)doNothing:(id)sender;
-(IBAction)toggleDrawing:(id)sender;
-(IBAction)toggleDetails:(id)sender;
-(IBAction)toggleAssets:(id)sender;
-(IBAction)toggleProperties:(id)sender;

-(BOOL)validateMenuItem:(NSMenuItem *)item;
-(IBAction) createNewMap:(id)sender;
-(IBAction) openMap:(id)sender;
-(IBAction) saveMap:(id)sender;
-(IBAction) importAsset:(id)sender;
-(id)window;
-(BOOL)acceptsFirstResponder;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
-(void)updateDescriptiveImage:(NSImage*)image;
-(NSTextField*)getNameTextField;
-(NSTextField*)getDescriptionTextField;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
-(BOOL)windowShouldClose:(id)sender;
@end
