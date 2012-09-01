#import "Authorization.h"
#import "RestKit.h"

#define kToken @"Token"

@implementation Authorization
@synthesize id;
@synthesize token;
@synthesize note;
@synthesize scopes;

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"id", @"token", @"note", @"scopes", nil];
    return mapping;
}

+ (RKObjectMapping *)inverseMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"note", @"scopes", nil];
    return mapping;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init])) {
        token = [coder decodeObjectForKey:kToken];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:token forKey:kToken];
}

@end
