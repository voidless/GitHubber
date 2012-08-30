#import "AppDelegate.h"
#import "AuthController.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    AuthController *authController = [AuthController new];
    navigationController = [[UINavigationController alloc] initWithRootViewController:authController];

    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
