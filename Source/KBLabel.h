#import "KBFont.h"

#ifdef IS_MACOS
@interface KBLabel: NSTextField
#else
@interface KBLabel: UILabel
#endif
@end
