#import "Repository.h"
#import "User.h"
#import "RestKit.h"

@implementation Repository
@synthesize id;
@synthesize name;
@synthesize desc;
@synthesize forks;
@synthesize watchers;
@synthesize owner;

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"id", @"name", @"forks", @"watchers", nil];
    [mapping mapKeyPath:@"description" toAttribute:@"desc"];
    [mapping mapRelationship:@"owner" withMapping:[User objectMapping]];
    return mapping;
}

@end
