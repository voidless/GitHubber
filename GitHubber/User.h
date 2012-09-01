#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface User : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *avatarUrl;

+ (RKObjectMapping *)objectMapping;

@end
