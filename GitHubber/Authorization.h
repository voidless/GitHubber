#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface Authorization : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSArray *scopes;

+ (RKObjectMapping *)objectMapping;
+ (RKObjectMapping *)inverseMapping;

@end
