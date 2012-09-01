#import "AppDelegate.h"
#import "AuthController.h"
#import "Repository.h"
#import "User.h"
#import <RestKit/RestKit.h>

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLogConfigureByName("RestKit/Network*", RKLogLevelInfo);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Options" ofType:@"plist"];
    NSDictionary *cfg = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *urlString = [cfg objectForKey:@"serverURL"];

    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURLString:urlString];
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
//    objectManager.client.authenticationType = RKRequestAuthenticationTypeOAuth2;

    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping mapAttributes:@"id", @"login", nil];
    [userMapping mapKeyPath:@"avatar_url" toAttribute:@"avatarUrl"];

    RKObjectMapping *repoMapping = [RKObjectMapping mappingForClass:[Repository class]];
    [repoMapping mapAttributes:@"id", @"name", @"forks", @"watchers", nil];
    [repoMapping mapKeyPathsToAttributes:@"description", @"desc",
                                         @"owner[login]", @"owner_login",
                                         @"owner[avatar_url]", @"owner_avatar_url",
                                         nil];
    [repoMapping mapRelationship:@"owner" withMapping:userMapping];

    [objectManager.mappingProvider setObjectMapping:repoMapping forResourcePathPattern:@"/user/repos"];
    [objectManager.mappingProvider setObjectMapping:repoMapping forResourcePathPattern:@"/users/:user/repos"];


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    AuthController *authController = [AuthController new];
    navigationController = [[UINavigationController alloc] initWithRootViewController:authController];

    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
