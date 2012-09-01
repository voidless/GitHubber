#import "AppDelegate.h"
#import "KeychainItem.h"
#import "AuthController.h"
#import "ImageCache.h"
#import "ApiManager.h"

@implementation AppDelegate
@synthesize window;
@synthesize navigationController;
@synthesize imageCache;
@synthesize apiManager;

+ (AppDelegate *)shared
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    imageCache = [ImageCache new];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Options" ofType:@"plist"];
    NSDictionary *cfg = [NSDictionary dictionaryWithContentsOfFile:filePath];
    apiManager = [[ApiManager alloc] initWithServerURLString:[cfg objectForKey:@"serverURL"]];

    KeychainItem *keychain = [[KeychainItem alloc] initWithIdentifier:[NSBundle mainBundle].bundleIdentifier];
    AuthController *authController = [[AuthController alloc] initWithKeychainItem:keychain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:authController];
    self.navigationController.navigationBarHidden = NO;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
