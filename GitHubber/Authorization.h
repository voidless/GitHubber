#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface Authorization : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSArray *scopes;

+ (RKObjectMapping *)objectMapping;
+ (RKObjectMapping *)inverseMapping;

@end
