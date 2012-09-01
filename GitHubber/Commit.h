#import <Foundation/Foundation.h>

@class User;
@class RKObjectMapping;

@interface Commit : NSObject

@property (nonatomic, strong) NSString *sha;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) User *author;

+ (RKObjectMapping *)objectMapping;

@end
