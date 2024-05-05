#import "KBFont.h"
#import "KBColor.h"

#ifdef IS_MACOS
@interface KBColor: NSColor
#else
@interface KBColor: UIColor
#endif
@end
