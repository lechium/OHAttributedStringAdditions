#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#define IS_IOS
#import <UIKit/UIKit.h>
#else
#define IS_MACOS
#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#endif
