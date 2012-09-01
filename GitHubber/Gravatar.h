#import <Foundation/Foundation.h>

@interface Gravatar : NSObject

- (id)initWithGravatarId:(NSString *)_gravatarId;
+ (id)gravatarWithId:(NSString *)_gravatarId;

- (NSURL *)imageURLWithSize:(NSUInteger)size;

@end
