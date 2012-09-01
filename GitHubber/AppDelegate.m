#import "AppDelegate.h"
#import "RestKit.h"
#import "RKErrorMessage.h"
#import "KeychainItem.h"
#import "User.h"
#import "Repository.h"
#import "Authorization.h"
#import "AuthController.h"
#import "ImageCache.h"
#import "Commit.h"

@implementation AppDelegate
@synthesize window;
@synthesize navigationController;
@synthesize imageCache;

+ (AppDelegate *)shared
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    imageCache = [ImageCache new];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Options" ofType:@"plist"];
    NSDictionary *cfg = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [self setupObjectManagerWithURLString:[cfg objectForKey:@"serverURL"]];

    KeychainItem *keychain = [[KeychainItem alloc] initWithIdentifier:[NSBundle mainBundle].bundleIdentifier];
    AuthController *authController = [[AuthController alloc] initWithKeychainItem:keychain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:authController];
    self.navigationController.navigationBarHidden = NO;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark Private

- (void)setupObjectManagerWithURLString:(NSString *)urlString
{
    RKLogConfigureByName("RestKit/Network*", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);

    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURLString:urlString];
    objectManager.client.reachabilityObserver = [RKReachabilityObserver reachabilityObserverForHost:urlString];
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    objectManager.acceptMIMEType = RKMIMETypeJSON;
    objectManager.serializationMIMEType = RKMIMETypeJSON;

    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping mapKeyPath:@"message" toAttribute:@"errorMessage"];
    objectManager.mappingProvider.errorMapping = errorMapping;

    [objectManager.mappingProvider setObjectMapping:[User objectMapping] forResourcePathPattern:@"/user"];
    [objectManager.router routeClass:[User class] toResourcePath:@"/user" forMethod:RKRequestMethodGET];

    [objectManager.mappingProvider setObjectMapping:[Repository objectMapping] forResourcePathPattern:@"/user/repos"];

    [objectManager.mappingProvider setObjectMapping:[Commit objectMapping] forResourcePathPattern:@"/repos/:user/:repo/commits"];

    [objectManager.mappingProvider setObjectMapping:[Authorization objectMapping] forResourcePathPattern:@"/authorizations"];
    [objectManager.mappingProvider setSerializationMapping:[Authorization inverseMapping] forClass:[Authorization class]];

    [objectManager.router routeClass:[Authorization class] toResourcePath:@"/authorizations" forMethod:RKRequestMethodGET];
    [objectManager.router routeClass:[Authorization class] toResourcePath:@"/authorizations" forMethod:RKRequestMethodPOST];
}

@end
