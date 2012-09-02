#import "LinkHTTPHeader.h"

#define LINK_REGEX @"<([^>]+)>; rel=\"([^\"]+)\""

@implementation LinkHTTPHeader {
    NSMutableDictionary *links;
}

+ (LinkHTTPHeader *)linkHTTPHeaderFromHeaders:(NSDictionary *)headers
{
    return [[self alloc] initWithHeaderString:[headers objectForKey:@"Link"]];
}

- (id)initWithHeaderString:(NSString *)string
{
    if (!string.length) {
        return nil;
    }

    if ((self = [super init])) {
        NSError *err;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:LINK_REGEX options:0 error:&err];
        if (err) {
            NSLog(@"Error matching LinkHTTPHeader: %@ from string: %@", err, string);
            return nil;
        }

        links = [NSMutableDictionary new];
        NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        for (NSTextCheckingResult *match in matches) {
            if (match.numberOfRanges < 3) {
                continue;
            }
            NSString *url = [string substringWithRange:[match rangeAtIndex:1]];
            NSString *rel = [string substringWithRange:[match rangeAtIndex:2]];
            [links setObject:url forKey:rel];
        }
    }
    return self;
}

- (NSString *)linkForRel:(NSString *)rel
{
    return [links objectForKey:rel];
}

@end
