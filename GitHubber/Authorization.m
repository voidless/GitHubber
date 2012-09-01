#import "Authorization.h"
#import "RestKit.h"

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

@end
