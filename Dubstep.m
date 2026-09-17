#import "Dubstep.h"
#import "Dubstep+Button.h"
#import <AppKit/AppKit.h>

@implementation Dubstep

+ (NSColor *)controlStrokeColor
{
  return RETAIN([NSColor colorWithCalibratedRed:0.4
                                          green:0.4
                                           blue:0.4
                                          alpha:1]);
}

// Converts RGBA values to NSColor.
- (NSColor *)rgbaToColor:(NSArray<NSNumber *> *)rgba
{
    CGFloat red = rgba[0].floatValue / 255;
    CGFloat green = rgba[1].floatValue / 255;
    CGFloat blue = rgba[2].floatValue / 255;
    CGFloat alpha = rgba[3].floatValue;
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

// Provides the default background color for the theme.
- (NSColor *)defaultBackgroundColor
{
  NSArray *rgba = @[@51.0,@51.0,@51.0,@1.0]; // Mockups default theme
  return [self rgbaToColor:rgba];
}

// Returns the background color for the status bar.
- (NSColor *)statusBarBackgroundColor
{
  return [NSColor blackColor]; 
}

// Returns padding value for menu items.
- (CGFloat)menuPadding
{
   return 16.0;
}

// Determines whether menu icons should be shown.
- (BOOL)menuShouldShowIcon
{
  return NO;
}

// Returns the inset for menu separators.
- (CGFloat)menuSeparatorInset
{
  return 0.0;
}

// Returns the background color for menu items.
- (NSColor *)menuItemBackgroundColor
{
  return [self statusBarBackgroundColor];
}

// Returns the border color for the menu.
- (NSColor *)menuBackgroundColor
{
  return [self statusBarBackgroundColor];
}

- (NSColor *)menuBorderColor
{
  NSArray *rgba = @[@68.0,@68.0,@68.0,@1.0];
  return [self rgbaToColor:rgba];
}

// Returns the border color for the edge of the menu.
- (NSColor *)menuBorderColorForEdge
{
  return [NSColor blackColor];
}

// Returns the horizontal overlap for submenus.
- (CGFloat)menuSubmenuHorizontalOverlap
{
  return 3;
}

// Returns the height of the title bar.
- (float)titlebarHeight
{
  return 40.0f;
}

// Returns the left padding of the title bar.
- (float)titlebarPaddingLeft
{
  return 16.0f;
}

// Returns the right padding of the title bar.
- (float)titlebarPaddingRight
{
  return 16.0f;
}

// Returns the top padding of the title bar.
- (float)titlebarPaddingTop
{
  return 4.0f;
}

// Returns the size of the title bar buttons.
- (float)titlebarButtonSize
{
  return 12.0f;
}

// Returns the padding for window buttons.
- (float)windowButtonPadding
{
  return 8.0f;
}

// Returns the height of the resize bar.
- (float)resizebarHeight
{
  return 12.0f;
}

// Corner radius of the title bar's top corners. Window managers that draw
// GSTheme decorations use this to round decorated windows.
- (CGFloat)titlebarCornerRadius
{
  return 10.0;
}

// Corner radius of the bottom corners of windows with a resize bar.
- (CGFloat)windowBottomCornerRadius
{
  return 10.0;
}

// Returns the vertical overlap for submenus.
- (CGFloat)menuSubmenuVerticalOverlap
{
  return 0;
}

// Returns the height of the menu bar.
- (CGFloat)menuBarHeight
{
  return 32;
}

// Returns the height of menu items.
- (CGFloat)menuItemHeight
{
  return 28;
}

// Returns the height of the menu separator.
- (CGFloat)menuSeparatorHeight
{
  return 1;
}

// Draws a path button with specified state.
- (void)drawPathButton:(NSBezierPath *)path
                    in:(NSView *)view
                 state:(GSThemeControlState)state {
    [[NSColor blackColor] setStroke];
    [path stroke];
}

#pragma mark - Window decorations

// Title bar background for the given input state (GSTitleBarKey/Normal/Main)
- (NSColor *)titleBarColorForState:(int)inputState
{
  NSColor *color = [NSColor windowFrameColor];
  return (inputState == 1) ? [color shadowWithLevel:0.15] : color;
}

- (NSColor *)windowBorderColorForDecorations
{
  NSColor *color = [self colorNamed:@"windowBorderColor" state:GSThemeNormalState];
  return color ? color : [NSColor windowFrameColor];
}

// Title text attributes, built per call so a theme switch picks up new colours
// (and nothing autoreleased is kept in a static).
- (NSDictionary *)titleTextAttributesForState:(int)inputState
{
  NSString *name = @"keyWindowFrameTextColor";
  if (inputState == 1)
    name = @"normalWindowFrameTextColor";
  else if (inputState == 2)
    name = @"mainWindowFrameTextColor";

  NSColor *textColor = [self colorNamed:name state:GSThemeNormalState];
  if (textColor == nil)
    textColor = [NSColor windowFrameTextColor];

  NSMutableParagraphStyle *style = AUTORELEASE([[NSParagraphStyle defaultParagraphStyle] mutableCopy]);
  [style setLineBreakMode:NSLineBreakByTruncatingTail];

  return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont titleBarFontOfSize:0], NSFontAttributeName,
            textColor, NSForegroundColorAttributeName,
            style, NSParagraphStyleAttributeName,
            nil];
}

// Draws the window border: title bar at the top, resize bar at the bottom,
// both using the same metrics the window frame offsets are computed from.
- (void)drawWindowBorder:(NSRect)rect
               withFrame:(NSRect)frame
            forStyleMask:(unsigned int)styleMask
                   state:(int)inputState
                andTitle:(NSString *)title
{
  if (styleMask & (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask))
    {
      CGFloat height = [self titlebarHeight];
      NSRect titleBarRect = NSMakeRect(0, NSHeight(frame) - height, NSWidth(frame), height);

      if (NSIntersectsRect(rect, titleBarRect))
        [self drawTitleBarRect:titleBarRect
                  forStyleMask:styleMask
                         state:inputState
                      andTitle:title];
    }

  if (styleMask & NSResizableWindowMask)
    {
      NSRect resizeBarRect = NSMakeRect(0, 0, NSWidth(frame), [self resizebarHeight]);

      if (NSIntersectsRect(rect, resizeBarRect))
        [self drawResizeBarRect:resizeBarRect];
    }
}

// Provides the standard window button for a given button type.
- (NSButton *)standardWindowButton:(NSWindowButton)button
                       forStyleMask:(NSUInteger)mask
{
  NSButton *newButton = [[NSButton alloc] init];
  [newButton setRefusesFirstResponder:YES];
  [newButton setButtonType:NSMomentaryChangeButton];
  [newButton setImagePosition:NSImageOnly];
  [newButton setBordered:NO];
  [newButton setTag:button];

  switch (button)
    {
      case NSWindowCloseButton:
        [newButton setImage:[NSImage imageNamed:@"common_Close"]];
        [newButton setAlternateImage:[NSImage imageNamed:@"common_CloseH"]];
        [newButton setAction:@selector(performClose:)];
        break;

      case NSWindowMiniaturizeButton:
        [newButton setImage:[NSImage imageNamed:@"common_Miniaturize"]];
        [newButton setAlternateImage:[NSImage imageNamed:@"common_MiniaturizeH"]];
        [newButton setAction:@selector(miniaturize:)];
        break;

      case NSWindowZoomButton:
        // common_Zoom is mapped to common_Maximize.png in the theme Info.plist
        [newButton setImage:[NSImage imageNamed:@"common_Zoom"]];
        [newButton setAlternateImage:[NSImage imageNamed:@"common_ZoomH"]];
        [newButton setAction:@selector(zoom:)];
        break;

      case NSWindowToolbarButton:
        [newButton setAction:@selector(toggleToolbarShown:)];
        break;

      case NSWindowDocumentIconButton:
      default:
        break;
    }

  return AUTORELEASE(newButton);
}

// Buttons sit on the left, vertically centred: close, miniaturize, zoom.
// These methods only compute geometry; they must not draw.
- (NSRect)titleBarButtonFrameAtIndex:(NSUInteger)index forBounds:(NSRect)bounds
{
  CGFloat size = [self titlebarButtonSize];
  CGFloat height = [self titlebarHeight];

  return NSMakeRect([self titlebarPaddingLeft] + index * (size + [self windowButtonPadding]),
                    NSHeight(bounds) - height + floor((height - size) / 2),
                    size, size);
}

- (NSRect)closeButtonFrameForBounds:(NSRect)bounds
{
  return [self titleBarButtonFrameAtIndex:0 forBounds:bounds];
}

- (NSRect)miniaturizeButtonFrameForBounds:(NSRect)bounds
{
  return [self titleBarButtonFrameAtIndex:1 forBounds:bounds];
}

- (NSRect)zoomButtonFrameForBounds:(NSRect)bounds
{
  return [self titleBarButtonFrameAtIndex:2 forBounds:bounds];
}

// Draws the title bar: full background, separator line and centred title.
- (void)drawTitleBarRect:(NSRect)titleBarRect
            forStyleMask:(unsigned int)styleMask
                   state:(int)inputState
                andTitle:(NSString *)title
{
  if (inputState < 0 || inputState > 2)
    inputState = 1;

  [[self titleBarColorForState:inputState] set];
  NSRectFill(titleBarRect);

  [[self windowBorderColorForDecorations] set];
  NSRectFill(NSMakeRect(NSMinX(titleBarRect), NSMinY(titleBarRect),
                        NSWidth(titleBarRect), 1));

  if (!(styleMask & NSTitledWindowMask) || [title length] == 0)
    return;

  // Keep the title clear of the buttons on the left, but centre it on the bar
  NSDictionary *attrs = [self titleTextAttributesForState:inputState];
  NSSize titleSize = [title sizeWithAttributes:attrs];
  NSUInteger buttons = 3;
  CGFloat inset = [self titlebarPaddingLeft] +
    buttons * ([self titlebarButtonSize] + [self windowButtonPadding]);
  NSRect textRect = NSInsetRect(titleBarRect, inset, 0);

  if (NSWidth(textRect) <= 0)
    return;
  if (titleSize.width < NSWidth(textRect))
    {
      textRect.origin.x = NSMidX(textRect) - titleSize.width / 2;
      textRect.size.width = titleSize.width;
    }
  textRect.origin.y = NSMidY(titleBarRect) - titleSize.height / 2;
  textRect.size.height = titleSize.height;

  [title drawInRect:textRect withAttributes:attrs];
}

// Draws the resize bar in the title bar colour with a separator line.
- (void)drawResizeBarRect:(NSRect)resizeBarRect
{
  [[self titleBarColorForState:0] set];
  NSRectFill(resizeBarRect);

  [[self windowBorderColorForDecorations] set];
  NSRectFill(NSMakeRect(NSMinX(resizeBarRect), NSMaxY(resizeBarRect) - 1,
                        NSWidth(resizeBarRect), 1));
}

// Draw the menu background and item cells
- (void)drawMenuRect:(NSRect)rect
              inView:(NSView *)view
        isHorizontal:(BOOL)horizontal
           itemCells:(NSArray *)itemCells
{
    NSMenuView *menuView = (NSMenuView *)view;
    NSRect bounds = [view bounds];
    
    // Clear the existing menu background in the drawing rectangle
    NSRectFillUsingOperation(bounds, NSCompositeClear);
    
    // Set the border color
    NSColor *borderColor = [self menuBorderColor];
    [borderColor setStroke];
    
    // Create a path for the menu border
    NSBezierPath *menuPath;
    
    if (horizontal) {
        // Horizontal menu bar
        menuPath = [NSBezierPath bezierPathWithRect:bounds];
        
        // Fill background color
        NSColor *fillColor = [self menuBackgroundColor];
        [fillColor setFill];
        NSRectFill(bounds);
        
        // Draw the top border line
        NSBezierPath *linePath = [NSBezierPath bezierPath];
        [linePath moveToPoint:NSMakePoint(bounds.origin.x, bounds.origin.y)];
        [linePath lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y)];
        [linePath setLineWidth:1];
        [linePath stroke];
    } else {
        // Vertical menus with rounded corners
        CGFloat radius = 6.0;
        menuPath = [NSBezierPath bezierPathWithRoundedRect:bounds
                                                   xRadius:radius
                                                   yRadius:radius];
        
        // Draw the menu border
        [menuPath stroke];
    }
    
    // Draw the menu item cells
    NSUInteger itemCount = itemCells.count;
    for (NSUInteger i = 0; i < itemCount; i++) {
        NSRect itemRect = [menuView rectOfItemAtIndex:i];
        if (NSIntersectsRect(rect, itemRect)) {
            NSMenuItemCell *itemCell = [menuView menuItemCellForItemAtIndex:i];
            [itemCell drawWithFrame:itemRect inView:menuView];
        }
    }
}

// Draw the background for menu view
- (void)drawBackgroundForMenuView:(NSMenuView *)menuView
                        withFrame:(NSRect)bounds
                        dirtyRect:(NSRect)dirtyRect
                       horizontal:(BOOL)horizontal
{
    // This method is currently not implemented. The original code was commented out.
    // You can implement custom background drawing here if needed.
}

// Draw the border and background for a menu item cell
- (void)drawBorderAndBackgroundForMenuItemCell:(NSMenuItemCell *)cell
                                     withFrame:(NSRect)cellFrame
                                        inView:(NSView *)controlView
                                         state:(GSThemeControlState)state
                                  isHorizontal:(BOOL)isHorizontal
{
    NSColor *menuItemBackground = [self menuItemBackgroundColor];
    
    NSColor *selectedBackgroundColor1 = [NSColor colorWithCalibratedRed:0.392
                                                                  green:0.533
                                                                   blue:0.953
                                                                  alpha:1.0];
    NSColor *selectedBackgroundColor2 = [NSColor colorWithCalibratedRed:0.165
                                                                  green:0.373
                                                                   blue:0.929
                                                                  alpha:1.0];

    NSGradient *menuItemGradient =
        [[NSGradient alloc] initWithStartingColor:selectedBackgroundColor1
                                      endingColor:selectedBackgroundColor2];
    
    [cell setBordered:NO];
    cellFrame = [cell drawingRectForBounds:cellFrame];

    if (isHorizontal) {
        cellFrame.origin.y = 1;
    }

    if (state == GSThemeSelectedState || state == GSThemeHighlightedState) {
        NSRectFillUsingOperation(cellFrame, NSCompositeClear);
        [menuItemGradient drawInRect:cellFrame angle:-90];
        return;
    } else if (!isHorizontal) {
        [menuItemBackground setFill];
    } else {
        return;
    }

    NSRectFillUsingOperation(cellFrame, NSCompositeClear);
    NSRectFill(cellFrame);
}

@end
