#import "Commit.h"
#import "User.h"
#import "RestKit.h"

@implementation Commit
@synthesize sha;
@synthesize message;
@synthesize date;
@synthesize author;

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"sha", nil];
    [mapping mapKeyPath:@"commit.message" toAttribute:@"message"];
    [mapping mapKeyPath:@"commit.author.date" toAttribute:@"date"];
    [mapping mapRelationship:@"author" withMapping:[User objectMapping]];
    return mapping;
}

@end
