#import <Foundation/Foundation.h>

@protocol RKRequestDelegate;
@protocol RKObjectLoaderDelegate;
@class Authorization;
@class Repository;

@interface ApiManager : NSObject
- (id)initWithServerURLString:(NSString *)urlString;

#pragma mark Clear cache (for logout)
- (void)clearCache;

#pragma mark Cancel request (use in dealloc)
- (void)cancelRequestsWithDelegate:(id <RKRequestDelegate>)controller;

#pragma mark Setup auth
- (void)setupOAuth2WithToken:(NSString *)token;
- (void)setupBasicAuthWithUsername:(NSString *)username password:(NSString *)password;

#pragma mark Authorization
- (void)postAuthorization:(Authorization *)authorization withDelegate:(id <RKObjectLoaderDelegate>)delegate;

#pragma mark Repositories
- (void)loadRepositoriesWithDelegate:(id <RKObjectLoaderDelegate>)delegate;

#pragma mark Commits
- (void)loadCommitsFromRepository:(Repository *)repository withDelegate:(id <RKObjectLoaderDelegate>)delegate;

#pragma mark Arbitrary resource url

- (void)loadObjectsAtURLString:(NSString *)urlString withDelegate:(id <RKObjectLoaderDelegate>)delegate;

@end
