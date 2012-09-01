#import "ImageCache.h"
#import "ApiManager.h"

@interface ImageCache (Singleton)
+ (ImageCache *)shared;
@end

@interface ApiManager (Singleton)
+ (ApiManager *)shared;
@end
