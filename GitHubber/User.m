#import "User.h"
#import "RestKit.h"
#import "Gravatar.h"

@implementation User
@synthesize id;
@synthesize login;
@synthesize avatarUrl;
@synthesize gravatarId;

- (Gravatar *)gravatar
{
    return [Gravatar gravatarWithId:gravatarId];
}

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"id", @"login", nil];
    [mapping mapKeyPath:@"avatar_url" toAttribute:@"avatarUrl"];
    [mapping mapKeyPath:@"gravatar_id" toAttribute:@"gravatarId"];
    return mapping;
}

@end
