#import "Singletons.h"
#import "AppDelegate.h"

@implementation ImageCache (Singleton)
+ (ImageCache *)shared
{
    return [AppDelegate shared].imageCache;
}
@end

@implementation ApiManager (Singleton)
+ (ApiManager *)shared
{
    return [AppDelegate shared].apiManager;
}
@end
