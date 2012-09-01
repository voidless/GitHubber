#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class Gravatar;

@interface User : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *gravatarId;

@property (nonatomic, strong, readonly) Gravatar *gravatar;

+ (RKObjectMapping *)objectMapping;

@end
