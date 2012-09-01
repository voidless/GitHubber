#import <Foundation/Foundation.h>

@class User;

@interface Repository : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSNumber *forks;
@property (nonatomic, strong) NSNumber *watchers;

@property (nonatomic, strong) User *owner;

@end
