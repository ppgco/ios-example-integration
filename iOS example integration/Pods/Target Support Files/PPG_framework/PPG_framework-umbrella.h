#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#include <PPG_framework/PPG_framework.h>

FOUNDATION_EXPORT double PPG_frameworkVersionNumber;
FOUNDATION_EXPORT const unsigned char PPG_frameworkVersionString[];

