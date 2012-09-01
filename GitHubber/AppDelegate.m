#import "AppDelegate.h"
#import "AuthController.h"
#import "Repository.h"
#import "Authorization.h"
#import "RestKit.h"
#import "RKErrorMessage.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLogConfigureByName("RestKit/Network*", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Options" ofType:@"plist"];
    NSDictionary *cfg = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *urlString = [cfg objectForKey:@"serverURL"];

    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURLString:urlString];
    objectManager.client.reachabilityObserver = [RKReachabilityObserver reachabilityObserverForHost:urlString];
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    objectManager.acceptMIMEType = RKMIMETypeJSON;
    objectManager.serializationMIMEType = RKMIMETypeJSON;

    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping mapKeyPath:@"message" toAttribute:@"errorMessage"];
    objectManager.mappingProvider.errorMapping = errorMapping;

    RKObjectMapping *repoMapping = [Repository objectMapping];
    [objectManager.mappingProvider setObjectMapping:repoMapping forResourcePathPattern:@"/user/repos"];
    [objectManager.mappingProvider setObjectMapping:repoMapping forResourcePathPattern:@"/users/:user/repos"];

    [objectManager.mappingProvider setObjectMapping:[Authorization objectMapping] forResourcePathPattern:@"/authorizations"];
    [objectManager.mappingProvider setSerializationMapping:[Authorization inverseMapping] forClass:[Authorization class]];

    RKObjectRouter *router = objectManager.router;
    [router routeClass:[Authorization class] toResourcePath:@"/authorizations" forMethod:RKRequestMethodGET];
    [router routeClass:[Authorization class] toResourcePath:@"/authorizations" forMethod:RKRequestMethodPOST];


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    AuthController *authController = [AuthController new];
    navigationController = [[UINavigationController alloc] initWithRootViewController:authController];

    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
