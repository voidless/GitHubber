#import "Singletons.h"
#import "AppDelegate.h"

@implementation ImageCache (Singleton)
+ (ImageCache *)shared
{
    return [AppDelegate shared].imageCache;
}
@end
