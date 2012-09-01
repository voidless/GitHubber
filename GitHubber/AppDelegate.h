#import <UIKit/UIKit.h>

@class ImageCache;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic, readonly) ImageCache *imageCache;

+ (AppDelegate *)shared;

@end
