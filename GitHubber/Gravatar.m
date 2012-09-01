#import "Gravatar.h"

#define GRAVATAR_URL @"http://www.gravatar.com/avatar"
#define DEFAULT_AVATAR @"mm"

@implementation Gravatar {
    NSString *gravatarId;
}

- (id)initWithGravatarId:(NSString *)_gravatarId
{
    if ((self = [super init])) {
        gravatarId = _gravatarId;
    }

    return self;
}

+ (id)gravatarWithId:(NSString *)_gravatarId
{
    return [[Gravatar alloc] initWithGravatarId:_gravatarId];
}

- (NSURL *)imageURLWithSize:(NSUInteger)size
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?s=%d?d=%@", GRAVATAR_URL, gravatarId, size, DEFAULT_AVATAR];
    return [NSURL URLWithString:urlString];
}

@end
