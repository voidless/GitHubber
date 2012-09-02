#import "ApiManager.h"
#import "Network.h"
#import "Authorization.h"
#import "RestKit.h"
#import "RKErrorMessage.h"
#import "User.h"
#import "Repository.h"
#import "Commit.h"


#define AUTH_PATH @"/authorizations"
#define USER_REPO_PATH @"/user/repos"
#define REPO_COMMITS_PATH @"/repos/:user/:repo/commits"

@implementation ApiManager {
    RKObjectManager *objectManager;
}

- (id)initWithServerURLString:(NSString *)urlString
{
    if ((self = [super init])) {
#if TARGET_IPHONE_SIMULATOR
        RKLogConfigureByName("RestKit*", RKLogLevelWarning);
#endif
        objectManager = [RKObjectManager managerWithBaseURLString:urlString];
        objectManager.client.reachabilityObserver = [RKReachabilityObserver reachabilityObserverForHost:urlString];
        objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
        objectManager.client.cachePolicy = RKRequestCachePolicyEtag | RKRequestCachePolicyLoadIfOffline;
        objectManager.acceptMIMEType = RKMIMETypeJSON;
        objectManager.serializationMIMEType = RKMIMETypeJSON;

        // Error
        RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
        [errorMapping mapKeyPath:@"message" toAttribute:@"errorMessage"];
        objectManager.mappingProvider.errorMapping = errorMapping;

        // Repository
        [objectManager.mappingProvider setObjectMapping:[Repository objectMapping] forResourcePathPattern:USER_REPO_PATH];

        // Commit
        [objectManager.mappingProvider setObjectMapping:[Commit objectMapping] forResourcePathPattern:REPO_COMMITS_PATH];

        // Authorization
        [objectManager.mappingProvider setObjectMapping:[Authorization objectMapping] forResourcePathPattern:AUTH_PATH];
        [objectManager.mappingProvider setSerializationMapping:[Authorization inverseMapping] forClass:[Authorization class]];

        [objectManager.router routeClass:[Authorization class] toResourcePath:AUTH_PATH forMethod:RKRequestMethodPOST];
    }
    return self;
}

#pragma mark Cancel request (use in dealloc)

- (void)cancelRequestsWithDelegate:(id <RKRequestDelegate>)controller
{
    [objectManager.requestQueue cancelRequestsWithDelegate:controller];
}

#pragma mark Clear cache (for logout)

- (void)clearCache
{
    [objectManager.requestCache invalidateAll];
}

#pragma mark Setup auth

- (void)setupOAuth2WithToken:(NSString *)token
{
    objectManager.client.authenticationType = RKRequestAuthenticationTypeOAuth2;
    objectManager.client.OAuth2AccessToken = token;
}

- (void)setupBasicAuthWithUsername:(NSString *)username password:(NSString *)password
{
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    objectManager.client.username = username;
    objectManager.client.password = password;
}

#pragma mark Authorization

- (void)postAuthorization:(Authorization *)authorization withDelegate:(id <RKObjectLoaderDelegate>)delegate
{
    [objectManager postObject:authorization delegate:delegate];
}

#pragma mark Repositories

- (void)loadRepositoriesWithDelegate:(id <RKObjectLoaderDelegate>)delegate
{
    [objectManager loadObjectsAtResourcePath:USER_REPO_PATH delegate:delegate];
}

#pragma mark Commits

- (void)loadCommitsFromRepository:(Repository *)repository withDelegate:(id <RKObjectLoaderDelegate>)delegate
{
    NSString *resourcePath = [[REPO_COMMITS_PATH
            stringByReplacingOccurrencesOfString:@":user" withString:repository.owner.login]
            stringByReplacingOccurrencesOfString:@":repo" withString:repository.name];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
}

@end
