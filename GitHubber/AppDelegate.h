#import <UIKit/UIKit.h>

@class ImageCache;
@class ApiManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic, readonly) ImageCache *imageCache;
@property (strong, nonatomic, readonly) ApiManager *apiManager;

+ (AppDelegate *)shared;

@end
