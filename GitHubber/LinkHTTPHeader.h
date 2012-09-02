#import <Foundation/Foundation.h>

@interface LinkHTTPHeader : NSObject

+ (LinkHTTPHeader *)linkHTTPHeaderFromHeaders:(NSDictionary *)headers;
- (id)initWithHeaderString:(NSString *)string;

- (NSString *)linkForRel:(NSString *)rel;

@end
