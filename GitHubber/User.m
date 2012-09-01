#import "User.h"
#import "RestKit.h"

@implementation User
@synthesize id;
@synthesize login;
@synthesize avatarUrl;

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"id", @"login", nil];
    [mapping mapKeyPath:@"avatar_url" toAttribute:@"avatarUrl"];
    return mapping;
}

@end
